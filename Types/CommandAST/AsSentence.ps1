<#
.SYNOPSIS
    Maps Natural Language Syntax to PowerShell Parameters
.DESCRIPTION
    Maps a statement in natural language syntax to a set of PowerShell parameters.

    All parameters will be collected.
    
    For the purposes of natural language processing ValueFromPipeline will be ignored.
    
    The order the parameters is declared takes precedence over Position attributes.
#>
param()

# Because we want to have flexible open-ended arguments here, we do not hard-code any arguments.
# we parse them.
$IsRightToLeft   = $false
$SpecificCommands = @()
$specificCommandNames = @()
for ($argIndex =0 ; $argIndex -lt $args.Count; $argIndex++) {
    $arg = $args[$argIndex]    
    if ($arg -is [Management.Automation.CommandInfo]) {
        $SpecificCommands += $arg
        $specificCommandNames += $arg.Name
        continue
    }
    if ($arg -match '^[-/]{0,2}(?:Is)?RightToLeft$') {
        # If -RightToLeft was passed
        $IsRightToLeft = $true
        continue
    }

    $argCommands = @(
        $foundTranspiler = Get-Transpiler -TranspilerName $arg 
        if ($foundTranspiler) {
            foreach ($transpiler in $foundTranspiler) {
                if ($transpiler.Validate($arg)) { 
                    $transpiler
                }
            }
        } else {
            $ExecutionContext.SessionState.InvokeCommand.GetCommands($arg, 'All', $true)
        }
    )

    if ($argCommands) {        
        $SpecificCommands += $argCommands
        continue
    }
}


$mappedParameters = [Ordered]@{}
$sentence = [Ordered]@{
    PSTypeName='PipeScript.Sentence'
    Command   = $null
}


$commandAst = $this
$commandElements = @($commandAst.CommandElements)
# If we are going right to left, reverse the command elements


if ($IsRightToLeft) {
    [Array]::Reverse($commandElements)
}


$sentences = @()
if ($SpecificCommands) {    
    $potentialCommands = $SpecificCommands
    $potentialCommandNames = @($SpecificCommands | Select-Object -ExpandProperty Name)
} else {

    # The first command element should be the name of the command.
    $firstCommandElement = $commandElements[0]
    $commandName = ''
    $potentialCommandNames = @()
    $potentialCommands = 
        @(    
        if ($firstCommandElement.Value -and $firstCommandElement.StringConstantType -eq 'BareWord') {    
            $commandName = $firstCommandElement.Value            
            $foundTranspiler = Get-Transpiler -TranspilerName $commandName    
            if ($foundTranspiler) {
                foreach ($transpiler in $foundTranspiler) {
                    if ($transpiler.Validate($commandAst)) { 
                        $potentialCommandNames += $commandName
                        $transpiler
                    }
                }
            } else {
                foreach ($foundCmd in $ExecutionContext.SessionState.InvokeCommand.GetCommands($commandName, 'All', $true)) {
                    $foundCmd
                    $potentialCommandNames += $commandName
                }                
            }
        })

    if (-not $potentialCommands) {
        [PSCustomObject][Ordered]@{
            PSTypeName = 'PipeScript.Sentence'
            Keyword    = ''
            Command    = $null
            Arguments  = $commandElements[0..$commandElements.Length]
        }
    }
}

$mappedParameters = [Ordered]@{}

if (-not $Script:SentenceWordCache) {
    $Script:SentenceWordCache = @{}
}

$potentialCommandIndex = -1
foreach ($potentialCommand in $potentialCommands) {
    $potentialCommandIndex++
    $commandName = $potentialCommandName = $potentialCommandNames[$potentialCommandIndex]
    <#
    Each potential command can be thought of as a simple sentence with (mostly) natural syntax
    
    command <parametername> ...<parameterargument> (etc)     
        
    either more natural or PowerShell syntax should be allowed, for example:

    all functions can Quack {
        "quack"
    }

    would map to the command all and the parameters -Function and -Can (with the arguments Quack and {"quack"})

    Assuming -Functions was a `[switch]` or an alias to a `[switch]`, it will match that `[switch]` and only that switch.

    If -Functions was not a `[switch]`, it will match values from that point.

    If the parameter type is not a list or PSObject, only the next parameter will be matched.

    If the parameter type *is* a list or an PSObject, 
    or ValueFromRemainingArguments is present and no named parameters were found,
    then all remaining arguments will be matched until the next named parameter is found.
    
    _Aliasing is important_ when working with a given parameter.  The alias, _not_ the parameter name, will be what is mapped.

    #>

    # Cache the potential parameters
    $potentialParameters = $potentialCommand.Parameters

    # Assume the current parameter is empty,
    $currentParameter  = ''
    # the current parameter metadata is null,
    $currentParameterMetadata = $null
    # there is no current clause,
    $currentClause = @()
    # and there are no unbound parameters.            
    $unboundParameters = @()
    $clauses = @()

    # Walk over each command element in a for loop (we may adjust the index when we match)
    for ($commandElementIndex = 1 ;$commandElementIndex -lt $commandElements.Count; $commandElementIndex++) {
        $commandElement = $CommandElements[$commandElementIndex]
        # by default, we assume we haven't found a parameter.
        $parameterFound  = $false
        
        $barewordSequenece = 
            @(for ($cei = $commandElementIndex; $cei  -lt $commandElements.Count; $cei++) {
                if (
                    $commandElements[$cei] -isnot [Management.Automation.Language.StringConstantExpressionAst] -or 
                    $commandElements[$cei].StringConstantType -ne 'Bareword'
                ) { break }
                $commandElements[$cei].Value
            })

        # That assumption is quickly challenged if the AST type was CommandParameter
        if ($commandElement -is [Management.Automation.Language.CommandParameterAst]) {
            # If there were already clauses, finalize them before we start this clause
            if ($currentClause) {                
                $clauses += [PSCustomObject][Ordered]@{
                    PSTypeName    = 'PipeScript.Sentence.Clause'
                    Name          = if ($currentParameter) { $currentParameter} else { '' }
                    ParameterName = if ($currentParameterMetadata) { $currentParameterMetadata.Name } else { '' }
                    Words         = $currentClause
                }
            }

            $commandParameter = $commandElement
            # In that case, we know the name they want to use for the parameter                      
            $currentParameter = $commandParameter.ParameterName
            
            $currentClause = @($currentParameter)
            # We need to get the parameter metadata as well.
            $currentParameterMetadata = 
                # If it was the real name of a parameter, this is easy
                if ($potentialCommand.Parameters[$currentParameter]) {
                    $potentialCommand.Parameters[$currentParameter]
                    $parameterFound = $true
                }
                else {
                    # Otherwise, we need to search each parameter for aliases.
                    foreach ($cmdParam in $potentialCommand.Parameters.Values) {
                        if ($cmdParam.Aliases -contains $currentParameter) {
                            $parameterFound = $true
                            $cmdParam
                            break
                        }                            
                    }
                }
            
            # If the parameter had an argument
            if ($commandParameter.Argument) {
                # Use that argument
                if ($mappedParameters[$currentParameter]) {
                    $mappedParameters[$currentParameter] = @($mappedParameters[$currentParameter]) + @(
                        $commandParameter.Argument
                    )                    
                } else {
                    $mappedParameters[$currentParameter] = $commandParameter.Argument
                }
                # and move onto the next element.                
                $clauses += [PSCustomObject][Ordered]@{
                    PSTypeName    = 'PipeScript.Sentence.Clause'
                    Name          = if ($currentParameter) { $currentParameter} else { '' }
                    ParameterName = if ($currentParameterMetadata) { $currentParameterMetadata.Name } else { '' }
                    Words         = $currentClause
                }
                $currentParameter = ''
                $currentParameterMetadata = $null
                
                $currentClause = @()
                continue
            }
            # Since we have found a parameter, we advance the index.
            $commandElementIndex++
        }
        
        # If the command element was a bareword, it could also be the name of a parameter
        elseif ($barewordSequenece) {
            # We need to know the name of the parameter as it was written.
            # However, we also want to allow --parameters and /parameters,
            $potentialParameterName = $barewordSequenece[0]
            # therefore, we will compare against the potential name without leading dashes or slashes.
            
            $potentialBarewordList  =@(
                for (
                    $barewordSequenceIndex = $barewordSequenece.Length; 
                    $barewordSequenceIndex -ge 0;
                    $barewordSequenceIndex--
                ) {
                    $barewordSequenece[0..$barewordSequenceIndex] -join ' ' -replace '^[-/]{0,}'
                }
            )
            
            $dashAndSlashlessName   = $potentialParameterName -replace '^[-/]{0,}'

            # If no parameter was found but a parameter has ValueFromRemainingArguments, we will map to that.                        
            $valueFromRemainingArgumentsParameter = $null

            # Walk over each potential parameter in the command
            foreach ($potentialParameter in $potentialParameters.Values) {
                $parameterFound = $(
                    # otherwise, we have to check each alias.
                    :nextAlias foreach ($potentialAlias in $potentialParameter.Aliases) {
                        if ($potentialBarewordList -contains $potentialAlias) {
                            $potentialParameterName = $potentialAlias
                            $true
                            break
                        }                            
                    }
                    
                    # If the parameter name matches,
                    if ($potentialBarewordList -contains $potentialParameter.Name) {
                        $true # we've found it,
                    } else {
                        
                    }    
                )

                # If we found the parameter
                if ($parameterFound) {
                    if ($currentClause) {
                        $clauses += [PSCustomObject][Ordered]@{
                            PSTypeName    = 'PipeScript.Sentence.Clause'
                            Name          = if ($currentParameter) { $currentParameter} else { '' }
                            ParameterName = if ($currentParameterMetadata) { $currentParameterMetadata.Name } else { '' }
                            Words         = $currentClause
                        }                         
                    }

                    # keep track of of it and advance the index.
                    $currentParameter = $potentialParameterName                    
                    $currentParameterMetadata = $potentialParameter                    
                    
                    if ($currentParameter -match '\s') {
                        $barewordCount = @($currentParameter -split '\s').Length
                        $currentClause = @($commandElements[$commandElementIndex..($commandElementIndex + $barewordCount - 1)])
                        $commandElementIndex += $barewordCount                        
                    } else {
                        $commandElementIndex++
                        $currentClause = @($commandElement)
                    }
                    
                    break
                }
                else {
                    # If we did not, check the parameter for .ValueFromRemainingArguments
                    foreach ($attr in $potentialParameter.Attributes) {
                        if ($attr.ValueFromRemainingArguments) {
                            $valueFromRemainingArgumentsParameter = $potentialParameter
                            break
                        }
                    }                    
                }
            }
        }

        # If we have our current parameter, but it is a switch,
        if ($currentParameter -and $currentParameterMetadata.ParameterType -eq [switch]) {        
            $mappedParameters[$currentParameter] = $true # set it             
            if ($currentClause) {                
                $clauses += [PSCustomObject][Ordered]@{
                    PSTypeName    = 'PipeScript.Sentence.Clause'
                    Name          = if ($currentParameter) { $currentParameter} else { '' }
                    ParameterName = if ($currentParameterMetadata) { $currentParameterMetadata.Name } else { '' }
                    Words         = $currentClause
                }                                     
            }
            $currentParameter = '' # and clear the current parameter.
            $currentClause = @()
            $commandElementIndex--
            continue            
        }
        elseif ($currentParameter) {
            if ($mappedParameters.Contains($currentParameter) -and
                $currentParameter.ParameterType -isnot [Collections.IList] -and
                $currentParameter.ParameterType -isnot [PSObject]                
            ) {
                $clauses += [PSCustomObject][Ordered]@{
                    PSTypeName    = 'PipeScript.Sentence.Clause'
                    Name          = if ($currentParameter) { $currentParameter} else { '' }
                    ParameterName = if ($currentParameterMetadata) { $currentParameterMetadata.Name } else { '' }
                    Words         = $currentClause
                }
                $currentParameter = $null
                $currentParameterMetadata = $null
                $currentClause = @()
                $commandElementIndex--
                continue
            }
        }

        # Refersh our $commandElement, as the index may have changed.
        $commandElement = $CommandElements[$commandElementIndex]

        # If we have a ValueFromRemainingArguments but no current parameter mapped
        if ($valueFromRemainingArgumentsParameter -and -not $currentParameter) {
            # assume the ValueFromRemainingArguments parameter is the current parameter.
            $currentParameter = $valueFromRemainingArgumentsParameter.Name
            $currentParameterMetadata = $valueFromRemainingArgumentsParameter            
            $currentClause = @()
        }

        # If we have a current parameter
        if ($currentParameter) {
            
            # Map the current element to this parameter.
            
            
            $mappedParameters[$currentParameter] = 
                if ($mappedParameters[$currentParameter]) {
                    @($mappedParameters[$currentParameter]) + @($commandElement)
                } else {
                    if ($commandElement.Value) {
                        $commandElement.Value
                    } 
                    elseif ($commandElement -is [Management.Automation.Language.ScriptBlockExpressionAst]) {
                        [ScriptBlock]::Create($commandElement.Extent.ToString() -replace '^\{' -replace '\}$')
                    }
                    else {
                        $commandElement
                    }
                }
            $currentClause += $commandElement
            
            
        } else {
            # otherwise add the command element to our unbound parameters.
            $unboundParameters +=
                if ($commandElement.Value -and 
                    $commandElement -isnot [Management.Automation.Language.ExpandableStringExpressionAst]) {
                    $commandElement.Value
                } 
                elseif ($commandElement -is [ScriptBlockExpressionAst]) {
                    [ScriptBlock]::Create($commandElement.Extent.ToString() -replace '^\{' -replace '\}$')
                }
                else {
                    $commandElement
                }
            $currentClause += $commandElement
        }

    }

    if ($currentClause) {
        $clauses += [PSCustomObject][Ordered]@{
            PSTypeName    = 'PipeScript.Sentence.Clause'
            Name          = if ($currentParameter) { $currentParameter} else { '' }
            ParameterName = if ($currentParameterMetadata) { $currentParameterMetadata.Name } else { '' }
            Words         = $currentClause
        }                        
    }

    

    if ($potentialCommand -isnot [Management.Automation.ApplicationInfo] -and 
        @($mappedParameters.Keys) -match '^[-/]') {
        $keyIndex = -1
        :nextParameter foreach ($mappedParamName in @($mappedParameters.Keys)) {
            $keyIndex++
            $dashAndSlashlessName = $mappedParamName -replace '^[-/]{0,}'
            if ($potentialCommand.Parameters[$mappedParamName]) {
                continue
            } else {
                foreach ($potentialParameter in $potentialCommand.Parameters) {
                    if ($potentialParameter.Aliases -contains $mappedParamName) {
                        continue nextParameter
                    }
                }
                $mappedParameters.Insert($keyIndex, $dashAndSlashlessName, $mappedParameters[$mappedParamName])
                $mappedParameters.Remove($mappedParamName)                
            }

        }
    }

    $sentence = 
        [PSCustomObject]@{
            PSTypeName = 'PipeScript.Sentence'
            Keyword    = $potentialCommandName
            Command    = $potentialCommand
            Clauses    = $clauses
            Parameters = $mappedParameters
            Arguments  = $unboundParameters
        }
    $sentences+= $sentence
    $sentence
}