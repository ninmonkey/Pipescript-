CSharp.Template
---------------




### Synopsis
C# Template Transpiler.



---


### Description

Allows PipeScript to Generate C#.

Multiline comments with /*{}*/ will be treated as blocks of PipeScript.

Multiline comments can be preceeded or followed by 'empty' syntax, which will be ignored.

The C# Inline Transpiler will consider the following syntax to be empty:

* ```String.Empty```
* ```null```
* ```""```
* ```''```



---


### Examples
#### EXAMPLE 1
```PowerShell
{
    $CSharpLiteral = @'
namespace TestProgram/*{Get-Random}*/ {
public static class Program {
    public static void Main(string[] args) {
        string helloMessage = /*{
            '"hello"', '"hello world"', '"hey there"', '"howdy"' | Get-Random
        }*/ string.Empty; 
        System.Console.WriteLine(helloMessage);
    }
}
}    
'@
```
[OutputFile(".\HelloWorld.ps1.cs")]$CSharpLiteral
}

$AddedFile = .> .\HelloWorld.ps1.cs
$addedType = Add-Type -TypeDefinition (Get-Content $addedFile.FullName -Raw) -PassThru
$addedType::Main(@())
#### EXAMPLE 2
```PowerShell
// HelloWorld.ps1.cs
namespace TestProgram {
    public static class Program {
        public static void Main(string[] args) {
            string helloMessage = /*{
                '"hello"', '"hello world"', '"hey there"', '"howdy"' | Get-Random
            }*/ string.Empty; 
            System.Console.WriteLine(helloMessage);
        }
    }
}
```



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
CSharp.Template -CommandInfo <CommandInfo> [-Parameter <IDictionary>] [-ArgumentList <PSObject[]>] [<CommonParameters>]
```
```PowerShell
CSharp.Template -AsTemplateObject [-Parameter <IDictionary>] [-ArgumentList <PSObject[]>] [<CommonParameters>]
```
