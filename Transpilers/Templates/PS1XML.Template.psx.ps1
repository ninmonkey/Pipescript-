<#
.SYNOPSIS
    PS1XML Template Transpiler.
.DESCRIPTION
    Allows PipeScript to generate PS1XML.

    Multiline comments blocks like this ```<!--{}-->``` will be treated as blocks of PipeScript.
.EXAMPLE
    $typesFile, $typeDefinition, $scriptMethod = Invoke-PipeScript {

        types.ps1xml template '
        <Types>
            <!--{param([Alias("TypeDefinition")]$TypeDefinitions) $TypeDefinitions }-->
        </Types>
        '

        typeDefinition.ps1xml template '
        <Type>
            <!--{param([Alias("PSTypeName")]$TypeName) "<Name>$($typename)</Name>" }-->
            <!--{param([Alias("PSMembers","Member")]$Members) "<Members>$($members)</Members>" }-->
        </Type>
        '

        scriptMethod.ps1xml template '
        <ScriptMethod>
            <!--{param([Alias("Name")]$MethodName) "<Name>$($MethodName)</Name>" }-->
            <!--{param([ScriptBlock]$MethodDefinition) "<Script>$([Security.SecurityElement]::Escape("$MethodDefinition"))</Script>" }-->
        </ScriptMethod>
        '
    }


    $typesFile.Save("Test.types.ps1xml",
        $typeDefinition.Evaluate(@{
            TypeName='foobar'
            Members = 
                @($scriptMethod.Evaluate(
                    @{
                        MethodName = 'foo'
                        MethodDefinition = {"foo"}
                    }
                ),$scriptMethod.Evaluate(
                    @{
                        MethodName = 'bar'
                        MethodDefinition = {"bar"}
                    }
                ),$scriptMethod.Evaluate(
                    @{
                        MethodName = 'baz'
                        MethodDefinition = {"baz"}
                    }
                ))
        })
    )
#>
[ValidatePattern('\.ps1xml$')]
param(
# The command information.  This will include the path to the file.
[Parameter(Mandatory,ValueFromPipeline,ParameterSetName='TemplateFile')]
[Management.Automation.CommandInfo]
$CommandInfo,

# If set, will return the information required to dynamically apply this template to any text.
[Parameter(Mandatory,ParameterSetName='TemplateObject')]
[switch]
$AsTemplateObject,

# A dictionary of parameters.
[Collections.IDictionary]
$Parameter,

# A list of arguments.
[PSObject[]]
$ArgumentList
)

begin {
    # We start off by declaring a number of regular expressions:
    $startComment = '<\!--' # * Start Comments ```<!--```
    $endComment   = '-->'   # * End Comments   ```-->```
    $Whitespace   = '[\s\n\r]{0,}'
    # * StartRegex     ```$StartComment + '{' + $Whitespace```
    $startRegex = "(?<PSStart>${startComment}\{$Whitespace)"
    # * EndRegex       ```$whitespace + '}' + $EndComment```
    $endRegex   = "(?<PSEnd>$Whitespace\}${endComment}\s{0,})"
    
    # Create a splat containing arguments to the core inline transpiler
    $Splat      = [Ordered]@{
        StartPattern  = $startRegex
        EndPattern    = $endRegex
    }
}

process {
    # If we have been passed a command
    if ($CommandInfo) {
        # add parameters related to the file.
        $Splat.SourceFile = $commandInfo.Source -as [IO.FileInfo]
        $Splat.SourceText = [IO.File]::ReadAllText($commandInfo.Source)
    }
    
    if ($Parameter) { $splat.Parameter = $Parameter }
    if ($ArgumentList) { $splat.ArgumentList = $ArgumentList }

    $splat.ForeachObject = {
        $in = $_
        if (($in -is [string]) -or 
            ($in.GetType -and $in.GetType().IsPrimitive)) {
            $in
        } elseif ($in.ChildNodes) {
            foreach ($inChildNode in $in.ChildNodes) {
                if ($inChildNode.NodeType -ne 'XmlDeclaration') {
                    $inChildNode.OuterXml
                }
            }
        } else {
            $inXml = (ConvertTo-Xml -Depth 100 -InputObject $in)
            foreach ($inChildNode in $inXml.ChildNodes) {
                if ($inChildNode.NodeType -ne 'XmlDeclaration') {
                    $inChildNode.OuterXml
                }
            }
        }
    }

    # If we are being used within a keyword,
    if ($AsTemplateObject) {
        $splat # output the parameters we would use to evaluate this file.
    } else {
        # Otherwise, call the core template transpiler
        .>PipeScript.Template @Splat # and output the changed file.
    }
}