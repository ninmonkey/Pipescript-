Basic.Template
--------------




### Synopsis
Basic Template Transpiler.



---


### Description

Allows PipeScript to generate Basic, Visual Basic, and Visual Basic Scripts.

Because Basic only allow single-line comments, this is done using a pair of comment markers.

A single line comment, followed by a { (or PipeScript { ) begins a block of pipescript.

A single line comment, followed by a } (or PipeScript } ) ends a block of pipescript.

Only commented lines within this block will be interpreted as PipeScript.
        
```VBScript    
rem {

Uncommented lines between these two points will be ignored

rem # Commented lines will become PipeScript / PowerShell.
rem param($message = "hello world")
rem "CreateObject(`"WScript.Shell`").Popup(`"$message`")" 
rem }
```



---


### Examples
#### EXAMPLE 1
```PowerShell
Invoke-PipeScript {
    $VBScript = '    
rem {
```
Uncommented lines between these two points will be ignored

rem # Commented lines will become PipeScript / PowerShell.
rem param($message = "hello world")
rem "CreateObject(`"WScript.Shell`").Popup(`"$message`")" 
rem }
'

    [OutputFile('.\HelloWorld.ps1.vbs')]$VBScript
}

Invoke-PipeScript .\HelloWorld.ps1.vbs


---


### Parameters
#### **CommandInfo**

The command information.  This will include the path to the file.






|Type           |Required|Position|PipelineInput |
|---------------|--------|--------|--------------|
|`[CommandInfo]`|true    |named   |true (ByValue)|



#### **AsTemplateObject**

If set, will return the information required to dynamically apply this template to any text.






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|true    |named   |false        |



#### **Parameter**

A dictionary of parameters.






|Type           |Required|Position|PipelineInput|
|---------------|--------|--------|-------------|
|`[IDictionary]`|false   |named   |false        |



#### **ArgumentList**

A list of arguments.






|Type          |Required|Position|PipelineInput|
|--------------|--------|--------|-------------|
|`[PSObject[]]`|false   |named   |false        |





---


### Syntax
```PowerShell
Basic.Template -CommandInfo <CommandInfo> [-Parameter <IDictionary>] [-ArgumentList <PSObject[]>] [<CommonParameters>]
```
```PowerShell
Basic.Template -AsTemplateObject [-Parameter <IDictionary>] [-ArgumentList <PSObject[]>] [<CommonParameters>]
```
