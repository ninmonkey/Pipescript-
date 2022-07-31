
Pipescript
----------
### Synopsis
The Core PipeScript Transpiler

---
### Description

The Core PipeScript Transpiler.

This will convert various portions in the PowerShell Abstract Syntax Tree from their PipeScript syntax into regular PowerShell.

It will run other converters as directed by the source code.

---
### Related Links
* [.>Pipescript.Function](.>Pipescript.Function.md)
* [.>Pipescript.AttributedExpression](.>Pipescript.AttributedExpression.md)
---
### Examples
#### EXAMPLE 1
```PowerShell
{
    function [explicit]ExplicitOutput {
        "whoops"
        return 1
    }
} | .>PipeScript
```

#### EXAMPLE 2
```PowerShell
{        
    [minify]{
        # Requires PSMinifier (this comment will be minified away)
        "blah"
            "de"
                "blah"
    }
} | .>PipeScript
```

#### EXAMPLE 3
```PowerShell
.\PipeScript.psx.ps1 -ScriptBlock {
    [bash]{param([string]$Message) $message}
}
```

#### EXAMPLE 4
```PowerShell
.\PipeScript.psx.ps1 -ScriptBlock {
    [explicit]{1;2;3;echo 4} 
}
```

#### EXAMPLE 5
```PowerShell
{
    function [ProxyCommand<'Get-Process'>]GetProcessProxy {}
} | .>PipeScript
```

---
### Parameters
#### **ScriptBlock**

A ScriptBlock that will be transpiled.



|Type               |Requried|Postion|PipelineInput |
|-------------------|--------|-------|--------------|
|```[ScriptBlock]```|true    |named  |true (ByValue)|
---
#### **Transpiler**

One or more transpilation expressions that apply to the script block.



|Type            |Requried|Postion|PipelineInput|
|----------------|--------|-------|-------------|
|```[String[]]```|false   |named  |false        |
---
### Syntax
```PowerShell
Pipescript -ScriptBlock <ScriptBlock> [-Transpiler <String[]>] [<CommonParameters>]
```
---

