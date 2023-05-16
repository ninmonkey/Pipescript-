function New-PipeScript {
    <#
    .Synopsis
        Creates new PipeScript.
    .Description
        Creates new PipeScript and PowerShell ScriptBlocks.
    .EXAMPLE
        New-PipeScript -Parameter @{a='b'}
    .EXAMPLE
        New-PipeScript -Parameter ([Net.HttpWebRequest].GetProperties()) -ParameterHelp @{
            Accept='
HTTP Accept.
HTTP Accept indicates what content types the web request will accept as a response.
'
        }
    .EXAMPLE
        New-PipeScript -Parameter @{"bar"=@{
            Name = "foo"
            Help = 'Foobar'
            Attributes = "Mandatory","ValueFromPipelineByPropertyName"
            Aliases = "fubar"
            Type = "string"
        }}
    #>
    [Alias('New-ScriptBlock')]
    param(
    # Defines one or more parameters for a ScriptBlock.
    # Parameters can be defined in a few ways:
    # * As a ```[Collections.Dictionary]``` of Parameters
    # * As the ```[string]``` name of an untyped parameter.
    # * As a ```[ScriptBlock]``` containing only parameters.
    [Parameter(ValueFromPipelineByPropertyName)]
    [ValidateScript({
        if ($_ -isnot [ScriptBlock]) { return $true }
        $statementCount = 0
        $statementCount += $_.Ast.DynamicParamBlock.Statements.Count
        $statementCount += $_.Ast.BeginBlock.Statements.Count
        $statementCount += $_.Ast.ProcessBlock.Statements.Count
        $statementCount += $_.Ast.EndBlock.Statements.Count
        if ($statementCount) {
            throw "ScriptBlock should have no statements"
        } else { 
            return $true
        }
    })]
    [ValidateScript({
    $validTypeList = [System.Collections.IDictionary],[System.String],[System.Object[]],[System.Management.Automation.ScriptBlock],[System.Reflection.PropertyInfo],[System.Reflection.PropertyInfo[]],[System.Reflection.ParameterInfo],[System.Reflection.ParameterInfo[]],[System.Reflection.MethodInfo],[System.Reflection.MethodInfo[]]
    $thisType = $_.GetType()
    $IsTypeOk =
        $(@( foreach ($validType in $validTypeList) {
            if ($_ -as $validType) {
                $true;break
            }
        }))
    if (-not $isTypeOk) {
        throw "Unexpected type '$(@($thisType)[0])'.  Must be 'System.Collections.IDictionary','string','System.Object[]','scriptblock','System.Reflection.PropertyInfo','System.Reflection.PropertyInfo[]','System.Reflection.ParameterInfo','System.Reflection.ParameterInfo[]','System.Reflection.MethodInfo','System.Reflection.MethodInfo[]'."
    }
    return $true
    })]
    
    $Parameter,
    # The dynamic parameter block.
    [Parameter(ValueFromPipelineByPropertyName)]
    [ValidateScript({
        if ($_ -isnot [ScriptBlock]) { return $true }
        if ($_.Ast.DynamicParamBlock -or $_.Ast.BeginBlock -or $_.Ast.ProcessBlock) {
            throw "ScriptBlock should not have any named blocks"
        }
        return $true    
    })]
    [ValidateScript({
        if ($_ -isnot [ScriptBlock]) { return $true }
        if ($_.Ast.ParamBlock.Parameters.Count) {
            throw "ScriptBlock should not have parameters"
        }
        return $true    
    })]
    [Alias('DynamicParameterBlock')]
    [ScriptBlock]
    $DynamicParameter,
    # The begin block.
    [Parameter(ValueFromPipelineByPropertyName)]
    [ValidateScript({
        if ($_ -isnot [ScriptBlock]) { return $true }
        if ($_.Ast.DynamicParamBlock -or $_.Ast.BeginBlock -or $_.Ast.ProcessBlock) {
            throw "ScriptBlock should not have any named blocks"
        }
        return $true    
    })]
    [ValidateScript({
        if ($_ -isnot [ScriptBlock]) { return $true }
        if ($_.Ast.ParamBlock.Parameters.Count) {
            throw "ScriptBlock should not have parameters"
        }
        return $true    
    })]
    [Alias('BeginBlock')]
    [ScriptBlock]
    $Begin,
    # The process block.
    [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]    
    [Alias('ProcessBlock','ScriptBlock')]
    [ScriptBlock]
    $Process,
    # The end block.
    [Parameter(ValueFromPipelineByPropertyName)]
    [ValidateScript({
        if ($_ -isnot [ScriptBlock]) { return $true }
        if ($_.Ast.DynamicParamBlock -or $_.Ast.BeginBlock -or $_.Ast.ProcessBlock) {
            throw "ScriptBlock should not have any named blocks"
        }
        return $true    
    })]
    [ValidateScript({
        if ($_ -isnot [ScriptBlock]) { return $true }
        if ($_.Ast.ParamBlock.Parameters.Count) {
            throw "ScriptBlock should not have parameters"
        }
        return $true    
    })]
    [Alias('EndBlock')]
    [ScriptBlock]
    $End,
    # The script header.
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]
    $Header,
    # If provided, will automatically create parameters.
    # Parameters will be automatically created for any unassigned variables.
    [Alias('AutoParameterize','AutoParameters')]
    [switch]
    $AutoParameter,
    # The type used for automatically generated parameters.
    # By default, ```[PSObject]```.
    [type]
    $AutoParameterType = [PSObject],
    # If provided, will add inline help to parameters.
    [Collections.IDictionary]
    $ParameterHelp,
    <#
    If set, will weakly type parameters generated by reflection.
    1. Any parameter type implements IList should be made a [PSObject[]]
    2. Any parameter that implements IDictionary should be made an [Collections.IDictionary]
    3. Booleans should be made into [switch]es
    4. All other parameter types should be [PSObject]
    #>
    [Alias('WeakType', 'WeakParameters', 'WeaklyTypedParameters', 'WeakProperties', 'WeaklyTypedProperties')]
    [switch]
    $WeaklyTyped,
    # The name of the function to create.
    [string]
    $FunctionName,
    # The type or namespace the function to create.  This will be ignored if -FunctionName is not passed.
    # If the function type is not function or filter, it will be treated as a function namespace.
    [Alias('FunctionNamespace','CommandNamespace')]
    [string]
    $FunctionType = 'function',
    # A description of the script's functionality.  If provided with -Synopsis, will generate help.
    [string]
    $Description,
    # A short synopsis of the script's functionality.  If provided with -Description, will generate help.
    [string]
    $Synopsis,
    # A list of examples to use in help.  Will be ignored if -Synopsis and -Description are not passed.
    [Alias('Examples')]
    [string[]]
    $Example,
    # A list of links to use in help.  Will be ignored if -Synopsis and -Description are not passed.
    [Alias('Links')]
    [string[]]
    $Link,
    # A list of attributes to declare on the scriptblock.
    [string[]]
    $Attribute,
    # If set, will not transpile the created code.
    [switch]
    $NoTranspile
    )
    begin {
        $ParametersToCreate    = [Ordered]@{}
        $parameterScriptBlocks = @()
        $allDynamicParameters  = @()
        $allBeginBlocks        = @()
        $allEndBlocks          = @()
        $allProcessBlocks      = @()
        $allHeaders            = @()
        ${?<EmptyParameterBlock>} = '^[\s\r\n]{0,}param\(' -replace '\)[\s\r\n]{0,}$'
        filter embedParameterHelp {
                    if ($_ -notmatch '^\s\<\#' -and $_ -notmatch '^\s\#') {
                        $commentLines = @($_ -split '(?>\r\n|\n)')
                        if ($commentLines.Count -gt 1) {
                            '<#' + [Environment]::NewLine + "$_".Trim() + [Environment]::newLine + '#>'
                        } else {
                            "# $_"
                        }
                    } else {
                        $_
                    }
                
        }
    }
    process {
        if ($Synopsis -and $Description) {
            function indentHelpLine {
                            foreach ($line in $args -split '(?>\r\n|\n)') {
                                (' ' * 4) + $line.TrimEnd()
                            }
                        
            }
            $helpHeader = @(
                "<#"
                ".Synopsis"
                indentHelpLine $Synopsis
                ".Description"
                indentHelpLine $Description
                
                foreach ($helpExample in $Example) {
                    ".Example"
                    indentHelpLine $helpExample
                }
                foreach ($helplink in $Link) {
                    ".Link"
                    indentHelpLine $helplink
                } 
                "#>"
            ) -join [Environment]::Newline
            $allHeaders += $helpHeader
        }
        
        if ($Attribute) {
            $allHeaders += $Attribute
        }
        # If -Parameter was passed, we will need to define parameters.
        if ($parameter) {
            # this will end up populating an [Ordered] dictionary, $parametersToCreate.
            # However, for ease of use, -Parameter can be very flexible.
            # The -Parameter can be a dictionary of parameters.
            if ($Parameter -is [Collections.IDictionary]) {
                $parameterType = ''
                # If it is, walk thur each parameter in the dictionary
                foreach ($EachParameter in $Parameter.GetEnumerator()) {
                    # Continue past any parameters we already have
                    if ($ParametersToCreate.Contains($EachParameter.Key)) {
                        continue
                    }
                    # If the parameter is a string and the value is not a variable
                    if ($EachParameter.Value -is [string] -and $EachParameter.Value -notlike '*$*') {
                        $parameterName = $EachParameter.Key
                        $ParametersToCreate[$EachParameter.Key] =
                            @(
                                if ($parameterHelp -and $parameterHelp[$eachParameter.Key]) {
                                    $parameterHelp[$eachParameter.Key] | embedParameterHelp
                                }
                                $parameterAttribute = "[Parameter(ValueFromPipelineByPropertyName)]"
                                $parameterType
                                '$' + $parameterName
                            ) -ne ''
                    }
                    # If the value is a string and the value contains variables
                    elseif ($EachParameter.Value -is [string]) {
                        # embed it directly.
                        $ParametersToCreate[$EachParameter.Key] = $EachParameter.Value
                    }                    
                    # If the value is a ScriptBlock
                    elseif ($EachParameter.Value -is [ScriptBlock]) {
                        # Embed it
                        $ParametersToCreate[$EachParameter.Key] =
                            # If there was a param block on the script block
                            if ($EachParameter.Value.Ast.ParamBlock) {
                                # embed the parameter block (except for the param keyword)
                                $EachParameter.Value.Ast.ParamBlock.Extent.ToString() -replace
                                    ${?<EmptyParameterBlock>}
                            } else {
                                # Otherwise
                                '[Parameter(ValueFromPipelineByPropertyName)]' + (
                                $EachParameter.Value.ToString() -replace
                                    "\`$$($eachParameter.Key)[\s\r\n]$" -replace # Replace any trailing variables
                                    ${?<EmptyParameterBlock>}  # then replace any empty param blocks.
                                )
                            }
                    }
                    # If the value was an array
                    elseif ($EachParameter.Value -is [Object[]]) {
                        $ParametersToCreate[$EachParameter.Key] = # join it's elements by newlines
                            $EachParameter.Value -join [Environment]::Newline
                    }
                    elseif ($EachParameter.Value -is [Collections.IDictionary] -or 
                        $EachParameter.Value -is [PSObject]) {
                        $parameterMetadata = $EachParameter.Value
                        $parameterName = $EachParameter.Key
                        if ($parameterMetadata.Name) {
                            $parameterName = $parameterMetadata.Name
                        }
                        
                        $parameterAttributeParts = @()
                        $ParameterOtherAttributes = @()
                        $attrs = 
                            if ($parameterMetadata.Attributes) { $parameterMetadata.Attributes }
                            elseif ($parameterMetadata.Attribute) { $parameterMetadata.Attribute }
                        $aliases =
                            if ($parameterMetadata.Alias) { $parameterMetadata.Alias }
                            elseif ($parameterMetadata.Aliases) { $parameterMetadata.Aliases }
                        [string]$parameterHelpText =
                            if ($parameterMetadata.Help) { $parameterMetadata.Help}                            
                        $aliasAttribute = @(foreach ($alias in $aliases) {
                            $alias -replace "'","''"                            
                        }) -join "','"
                        if ($aliasAttribute) {
                            $aliasAttribute = "[Alias('$aliasAttribute')]"
                        }
                        
                        foreach ($attr in $attrs) {
                            if ($attr -notmatch '^\[') {
                                $parameterAttributeParts += $attr
                            } else {
                                $ParameterOtherAttributes += $attr
                            }
                        }
                        $parameterType = 
                            if ($parameterMetadata.Type) {$parameterMetadata.Type }
                            elseif ($parameterMetadata.ParameterType) {$parameterMetadata.ParameterType }
                        $ParametersToCreate[$parameterName] = @(
                            if ($ParameterHelpText) {
                                $ParameterHelpText | embedParameterHelp
                            }
                            if ($parameterAttributeParts) {
                                "[Parameter($($parameterAttributeParts -join ','))]"
                            }
                            if ($aliasAttribute) {
                                $aliasAttribute
                            }
                            if ($parameterType -as [type]) {
                                "[$(($parameterType -as [type]).FullName -replace '^System\.')]"
                            }
                            elseif ($parameterType) {
                                "[PSTypeName('$($parameterType -replace '^System\.')')]"
                            }
                            
                            if ($ParameterOtherAttributes) {
                                $ParameterOtherAttributes
                            }
                            '$' + ($parameterName -replace '^$')
                        ) -join [Environment]::newLine
                    }
                }
            }
            # If the parameter was a string
            elseif ($Parameter -is [string])
            {
                # treat it as  parameter name
                $ParametersToCreate[$Parameter] =
                    @(
                    if ($parameterHelp -and $parameterHelp[$Parameter]) {
                        $parameterHelp[$Parameter] | embedParameterHelp
                    }
                    "[Parameter(ValueFromPipelineByPropertyName)]"
                    "`$$Parameter"
                    ) -join [Environment]::NewLine
            }
            # If the parameter is a [ScriptBlock]
            elseif ($parameter -is [scriptblock])
            {
                # add it to a list of parameter script blocks.
                $parameterScriptBlocks +=
                    if ($parameter.Ast.ParamBlock) {
                        $parameter
                    }
            }
            # If the -Parameter was provided via reflection
            elseif ($parameter -is [Reflection.PropertyInfo] -or
                $parameter -as [Reflection.PropertyInfo[]] -or
                $parameter -is [Reflection.ParameterInfo] -or
                $parameter -as [Reflection.ParameterInfo[]] -or
                $parameter -is [Reflection.MethodInfo] -or
                $parameter -as [Reflection.MethodInfo[]]
            ) {
                # check to see if it's a method
                if ($parameter -is [Reflection.MethodInfo] -or
                    $parameter -as [Reflection.MethodInfo[]]) {
                    $parameter = @(foreach ($methodInfo in $parameter) {
                        $methodInfo.GetParameters() # if so, reflect the method's parameters
                    })
                }
                # Walk over each parameter
                foreach ($prop in $Parameter) {
                    # If it is a property info that cannot be written, skip.
                    if ($prop -is [Reflection.PropertyInfo] -and -not $prop.CanWrite) { continue }
                    # Determine the reflected parameter type.
                    $paramType =
                        if ($prop.ParameterType) {
                            $prop.ParameterType
                        } elseif ($prop.PropertyType) {
                            $prop.PropertyType
                        } else {
                            [PSObject]
                        }
                    $ParametersToCreate[$prop.Name] =
                        @(
                            if ($parameterHelp -and $parameterHelp[$prop.Name]) {
                                $parameterHelp[$prop.Name] | embedParameterHelp
                            }
                            $parameterAttribute = "[Parameter(ValueFromPipelineByPropertyName)]"
                            $parameterAttribute
                            if ($paramType -eq [boolean]) {
                                "[switch]"
                            } elseif ($WeaklyTyped) {
                                if ($paramType.GetInterface([Collections.IDictionary])) {
                                    "[Collections.IDictionary]"
                                }
                                elseif ($paramType.GetInterface([Collections.IList])) {
                                    "[PSObject[]]"
                                }
                                else {
                                    "[PSObject]"
                                }
                            }
                            else {
                                "[$($paramType -replace '^System\.')]"
                            }
                            '$' + $prop.Name
                        ) -ne ''
                }
            }
        }
        # If there is header content,
        if ($header) {
            $allHeaders += $Header
        }
        # dynamic parameters,
        if ($DynamicParameter) {
            $allDynamicParameters += $DynamicParameter
        }
        # begin,
        if ($Begin) {
            $allBeginBlocks += $begin
        }
        # process,
        if ($process) {
            if ($process.BeginBlock -or 
                $process.ProcessBlock -or 
                $process.DynamicParameterBlock -or 
                $Process.ParamBlock) {
                if ($process.DynamicParameterBlock) {
                    $allDynamicParameters += $process.DynamicParameterBlock
                }
                if ($process.ParamBlock) {
                    $parameterScriptBlocks += $Process
                }
                if ($Process.BeginBlock) {
                    $allBeginBlocks += $Process.BeginBlock -replace ${?<EmptyParameterBlock>}
                }
                if ($process.ProcessBlock) {
                    $allProcessBlocks += $process.ProcessBlock
                }
                if ($process.EndBlock) {
                    $allEndBlocks += $Process.EndBlock -replace ${?<EmptyParameterBlock>}
                }
            } else {
                $allProcessBlocks += $process -replace ${?<EmptyParameterBlock>}
            }            
        }
        # or end blocks.
        if ($end) {
            # accumulate them.
            $allEndBlocks += $end
        }
        # If -AutoParameter was passed
        if ($AutoParameter) {
            # Find all of the variable expressions within -Begin, -Process, and -End
            $variableDefinitions = $Begin, $Process, $End |
                Where-Object { $_ } |
                Search-PipeScript -AstType VariableExpressionAST |
                Select-Object -ExpandProperty Result
            foreach ($var in $variableDefinitions) {
                # Then, see where those variables were assigned
                $assigned = $var.GetAssignments()
                # (if they were assigned, keep moving)
                if ($assigned) { continue }
                # If there were not assigned
                $varName = $var.VariablePath.userPath.ToString()
                # add it to the list of parameters to create.
                $ParametersToCreate[$varName] = @(
                    @(
                    "[Parameter(ValueFromPipelineByPropertyName)]"
                    "[$($AutoParameterType.FullName -replace '^System\.')]"
                    "$var"
                    ) -join [Environment]::NewLine
                )
            }
        }
    }
    end {
        # Take all of the accumulated parameters and create a parameter block
        $newParamBlock =
            "param(" + [Environment]::newLine +
            $(@(foreach ($toCreate in $ParametersToCreate.GetEnumerator()) {
                $toCreate.Value -join [Environment]::NewLine
            }) -join (',' + [Environment]::NewLine)) +
            [Environment]::NewLine +
            ')'
        # If any parameters were passed in as ```[ScriptBlock]```s,
        if ($parameterScriptBlocks) {
            $parameterScriptBlocks += [ScriptBlock]::Create($newParamBlock)
            # join them with the new parameter block.
            $newParamBlock = $parameterScriptBlocks | Join-PipeScript -IncludeBlockType param
        }
        
        # If we provided a -FunctionName, we'll be declaring a function.
        $functionDeclaration =
            # If the -FunctionType is function or filter
            if ($functionName -and $functionType -in 'function', 'filter') {
                # we declare it naturally.
                "$functionType $FunctionName  {"
            } elseif ($FunctionName) {
                # Otherwise, we declare it as a command namespace
                "$functionType function $functionName {"
                # (which means we have to transpile).
                $NoTranspile = $false
            }
        # Create the script block by combining together the provided parts.
        $ScriptToBe = "$(if ($functionDeclaration) { "$functionDeclaration"})
$($allHeaders -join [Environment]::Newline)
$newParamBlock
$(if ($allDynamicParameters) {
    @(@("dynamicParam {") + $allDynamicParameters + '}') -join [Environment]::Newline
})
$(if ($allBeginBlocks) {
    @(@("begin {") + $allBeginBlocks + '}') -join [Environment]::Newline
})
$(if ($allProcessBlocks) {
    @(@("process {") + $allProcessBlocks + '}') -join [Environment]::Newline
})
$(if ($allEndBlocks -and -not $allBeginBlocks -and -not $allProcessBlocks) {
    $allEndBlocks -join [Environment]::Newline
} elseif ($allEndBlocks) {
    @(@("end {") + $allEndBlocks + '}') -join [Environment]::Newline
})
$(if ($functionDeclaration) { '}'}) 
"
        $createdScriptBlock = [scriptblock]::Create($ScriptToBe)
        # If -NoTranspile was passed, 
        if ($createdScriptBlock -and $NoTranspile) {
            $createdScriptBlock # output the script as-is
        } elseif ($createdScriptBlock) { # otherwise            
            $createdScriptBlock | .>PipeScript # output the transpiled script.
        }
    }
}
