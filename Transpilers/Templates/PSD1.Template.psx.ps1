<#
.SYNOPSIS
    PSD1 Template Transpiler.
.DESCRIPTION
    Allows PipeScript to generate PSD1.

    Multiline comments blocks enclosed with {} will be treated as Blocks of PipeScript.

    Multiline comments can be preceeded or followed by single-quoted strings, which will be ignored.

    * ```''```
    * ```{}```
#>
[ValidatePattern('\.psd1$')]
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
    $startComment = '<\#' # * Start Comments ```\*```
    $endComment   = '\#>' # * End Comments   ```/*```
    $Whitespace   = '[\s\n\r]{0,}'
    # * IgnoredContext (single-quoted strings)
    $IgnoredContext = "
    (?<ignore>
        (?>'((?:''|[^'])*)')
        [\s - [ \r\n ] ]{0,}
    ){0,1}"
    # * StartRegex     ```$IgnoredContext + $StartComment + '{' + $Whitespace```
    $startRegex = [Regex]::New("(?<PSStart>${IgnoredContext}${startComment}\{$Whitespace)", 'IgnorePatternWhitespace')
    # * EndRegex       ```$whitespace + '}' + $EndComment + $ignoredContext```
    $endRegex   = "(?<PSEnd>$Whitespace\}${endComment}[\s-[\r\n]]{0,}${IgnoredContext})"

    # Create a splat containing arguments to the core inline transpiler
    $Splat      = [Ordered]@{
        StartPattern  = $startRegex
        EndPattern    = $endRegex
    }
}

process {
    # Add parameters related to the file
    $Splat.SourceFile = $commandInfo.Source -as [IO.FileInfo]
    $Splat.SourceText = [IO.File]::ReadAllText($commandInfo.Source)
    if ($Parameter) { $splat.Parameter = $Parameter }
    if ($ArgumentList) { $splat.ArgumentList = $ArgumentList }

    # If we are being used within a keyword,
    if ($AsTemplateObject) {
        $splat # output the parameters we would use to evaluate this file.
    } else {
        # Otherwise, call the core template transpiler
        .>PipeScript.Template @Splat # and output the changed file.
    }
}
