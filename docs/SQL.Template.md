SQL.Template
------------




### Synopsis
SQL Template Transpiler.



---


### Description

Allows PipeScript to generate SQL.

PipeScript can be embedded in multiline or singleline format

In multiline format, PipeScript will be embedded within: `/*{...}*/`

In single line format

-- { or -- PipeScript{  begins a PipeScript block

-- } or -- }PipeScript  ends a PipeScript block

```SQL    
-- {

Uncommented lines between these two points will be ignored

--  # Commented lines will become PipeScript / PowerShell.
-- param($message = 'hello world')
-- "-- $message"
-- }
```



---


### Examples
#### EXAMPLE 1
```PowerShell
Invoke-PipeScript {
    $SQLScript = '    
-- {
```
Uncommented lines between these two points will be ignored

--  # Commented lines will become PipeScript / PowerShell.
-- param($message = "hello world")
-- "-- $message"
-- }
'

    [OutputFile('.\HelloWorld.ps1.sql')]$SQLScript
}

Invoke-PipeScript .\HelloWorld.ps1.sql


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
SQL.Template -CommandInfo <CommandInfo> [-Parameter <IDictionary>] [-ArgumentList <PSObject[]>] [<CommonParameters>]
```
```PowerShell
SQL.Template -AsTemplateObject [-Parameter <IDictionary>] [-ArgumentList <PSObject[]>] [<CommonParameters>]
```
