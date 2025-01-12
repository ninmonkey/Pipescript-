<#
.SYNOPSIS
    Aspect Transpiler
.DESCRIPTION
    The Aspect Transpiler allows for any Aspect command to be embedded inline anywhere the aspect is found.

.EXAMPLE
    Import-PipeScript {
        aspect function SayHi {
            if (-not $args) { "Hello World"}
            else { $args }
        }
        function Greetings {
            SayHi
            SayHi "hallo Welt"
        }
    }

    Greetings
#>
[ValidateScript({
    $validating = $_

    # If we are not validating a command, it cannot be an aspect.
    if ($validating -isnot [Management.Automation.Language.CommandAst]) { return $false }
    
    # Determine the aspect name
    $aspectName = "Aspect?$(@($validating.CommandElements)[0])"
    # and see if we have any matching commands
    $aspectCommand = @($ExecutionContext.SessionState.InvokeCommand.GetCommands($aspectName, 'Function,Alias', $true))
    # If we do, this is a valid aspect.
    return ($aspectCommand.Length -as [bool])
})]
param(
# An Aspect Command.  Aspect Commands are embedded inline.
[Parameter(Mandatory,ValueFromPipeline)]
[Management.Automation.Language.CommandAst]
$AspectCommandAst
)

process {
    $aspectName = "Aspect?$(@($AspectCommandAst.CommandElements)[0])"
    $aspectCommands = @($ExecutionContext.SessionState.InvokeCommand.GetCommands($aspectName, 'Function,Alias', $true))
    
    if (-not $aspectCommands) { return }
    if ($aspectCommands.Length -gt 1) { return }

    $aspectCommand = $aspectCommands[0]

    $aspectScriptBlock = 
        if ($aspectCommand -is [Management.Automation.AliasInfo]) {
            $resolvedCommand = $aspectCommand.ResolvedCommand
            while ($resolvedCommand.ResolvedCommand) {
                $resolvedCommand  = $resolvedCommand.ResolvedCommand
            }
            $resolvedCommand.ScriptBlock
        } else {
            $aspectCommand.ScriptBlock
        }
    
    if (-not $aspectScriptBlock) { return }

    $firstElement, $restOfElements = @($aspectCommandAst.CommandElements)
    
    $InvocationOperator = 
        if ($AspectCommandAst.Parent.InvocationOperator -eq 'Dot') {
            '.'
        } else {
            '&'
        }    

    [ScriptBlock]::Create(
"
# $aspectCommand
$InvocationOperator { $aspectScriptBlock } $restOfElements
".Trim()
    )
}
