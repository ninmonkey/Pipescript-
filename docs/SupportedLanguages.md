These are all of the transpilers currently included in PipeScript:



|Language                                                                  |Synopsis                        |Pattern                         |
|--------------------------------------------------------------------------|--------------------------------|--------------------------------|
|[ADA.Template](Transpilers/Templates/ADA.Template.psx.ps1)                |ADA Template Transpiler.        |```\.ad[bs]$```                 |
|[Arduino.Template](Transpilers/Templates/Arduino.Template.psx.ps1)        |Arduino Template Transpiler.    |```\.(?>ino)$```                |
|[ATOM.Template](Transpilers/Templates/ATOM.Template.psx.ps1)              |ATOM Template Transpiler.       |```\.atom$```                   |
|[Bash.Template](Transpilers/Templates/Bash.Template.psx.ps1)              |Bash Template Transpiler.       |```\.sh$```                     |
|[Basic.Template](Transpilers/Templates/Basic.Template.psx.ps1)            |Basic Template Transpiler.      |```\.(?>bas\\|vbs{0,1})$```     |
|[Batch.Template](Transpilers/Templates/Batch.Template.psx.ps1)            |Batch Template Transpiler.      |```\.cmd$```                    |
|[Bicep.Template](Transpilers/Templates/Bicep.Template.psx.ps1)            |Bicep Template Transpiler.      |```\.bicep$```                  |
|[CPlusPlus.Template](Transpilers/Templates/CPlusPlus.Template.psx.ps1)    |C/C++ Template Transpiler.      |```\.(?>c\\|cpp\\|h\\|swig)$``` |
|[CSharp.Template](Transpilers/Templates/CSharp.Template.psx.ps1)          |C# Template Transpiler.         |```\.cs$```                     |
|[CSS.Template](Transpilers/Templates/CSS.Template.psx.ps1)                |CSS Template Transpiler.        |```\.s{0,1}css$```              |
|[Dart.Template](Transpilers/Templates/Dart.Template.psx.ps1)              |Dart Template Transpiler.       |```\.(?>dart)$```               |
|[Eiffel.Template](Transpilers/Templates/Eiffel.Template.psx.ps1)          |Eiffel Template Transpiler.     |```\.e$```                      |
|[Go.Template](Transpilers/Templates/Go.Template.psx.ps1)                  |Go Template Transpiler.         |```\.go$```                     |
|[HAXE.Template](Transpilers/Templates/HAXE.Template.psx.ps1)              |Haxe Template Transpiler.       |```\.hx$```                     |
|[HCL.Template](Transpilers/Templates/HCL.Template.psx.ps1)                |HCL Template Transpiler.        |```\.hcl$```                    |
|[HLSL.Template](Transpilers/Templates/HLSL.Template.psx.ps1)              |HLSL Template Transpiler.       |```\.hlsl$```                   |
|[HTML.Template](Transpilers/Templates/HTML.Template.psx.ps1)              |HTML PipeScript Transpiler.     |```\.htm{0,1}```                |
|[Java.Template](Transpilers/Templates/Java.Template.psx.ps1)              |Java Template Transpiler.       |```\.(?>java)$```               |
|[JavaScript.Template](Transpilers/Templates/JavaScript.Template.psx.ps1)  |JavaScript Template Transpiler. |```\.js$```                     |
|[Json.Template](Transpilers/Templates/Json.Template.psx.ps1)              |JSON PipeScript Transpiler.     |```\.json$```                   |
|[Kotlin.Template](Transpilers/Templates/Kotlin.Template.psx.ps1)          |Kotlin Template Transpiler.     |```\.kt$```                     |
|[Kusto.Template](Transpilers/Templates/Kusto.Template.psx.ps1)            |Kusto Template Transpiler.      |```\.kql$```                    |
|[Latex.Template](Transpilers/Templates/Latex.Template.psx.ps1)            |Latex Template Transpiler.      |```\.(?>latex\\|tex)$```        |
|[LUA.Template](Transpilers/Templates/LUA.Template.psx.ps1)                |LUA Template Transpiler.        |```\.lua$```                    |
|[Markdown.Template](Transpilers/Templates/Markdown.Template.psx.ps1)      |Markdown Template Transpiler.   |```\.(?>md\\|markdown\\|txt)$```|
|[ObjectiveC.Template](Transpilers/Templates/ObjectiveC.Template.psx.ps1)  |Objective Template Transpiler.  |```\.(?>m\\|mm)$```             |
|[OpenSCAD.Template](Transpilers/Templates/OpenSCAD.Template.psx.ps1)      |OpenSCAD Template Transpiler.   |```\.scad$```                   |
|[Perl.Template](Transpilers/Templates/Perl.Template.psx.ps1)              |Perl Template Transpiler.       |```\.(?>pl\\|pod)$```           |
|[PHP.Template](Transpilers/Templates/PHP.Template.psx.ps1)                |PHP Template Transpiler.        |```\.php$```                    |
|[PS1XML.Template](Transpilers/Templates/PS1XML.Template.psx.ps1)          |PS1XML Template Transpiler.     |```\.ps1xml$```                 |
|[PSD1.Template](Transpilers/Templates/PSD1.Template.psx.ps1)              |PSD1 Template Transpiler.       |```\.psd1$```                   |
|[Python.Template](Transpilers/Templates/Python.Template.psx.ps1)          |Python Template Transpiler.     |```\.py$```                     |
|[R.Template](Transpilers/Templates/R.Template.psx.ps1)                    |R Template Transpiler.          |```\.r$```                      |
|[Racket.Template](Transpilers/Templates/Racket.Template.psx.ps1)          |Racket Template Transpiler.     |```\.rkt$```                    |
|[Razor.Template](Transpilers/Templates/Razor.Template.psx.ps1)            |Razor Template Transpiler.      |```\.(cshtml\\|razor)$```       |
|[RSS.Template](Transpilers/Templates/RSS.Template.psx.ps1)                |RSS Template Transpiler.        |```\.rss$```                    |
|[Ruby.Template](Transpilers/Templates/Ruby.Template.psx.ps1)              |Ruby Template Transpiler.       |```\.rb$```                     |
|[Rust.Template](Transpilers/Templates/Rust.Template.psx.ps1)              |Rust Template Transpiler.       |```\.rs$```                     |
|[Scala.Template](Transpilers/Templates/Scala.Template.psx.ps1)            |Scala Template Transpiler.      |```\.(?>scala\\|sc)$```         |
|[SQL.Template](Transpilers/Templates/SQL.Template.psx.ps1)                |SQL Template Transpiler.        |```\.sql$```                    |
|[SVG.template](Transpilers/Templates/SVG.template.psx.ps1)                |SVG Template Transpiler.        |```\.svg$```                    |
|[TCL.Template](Transpilers/Templates/TCL.Template.psx.ps1)                |TCL/TK Template Transpiler.     |```\.t(?>cl\\|k)$```            |
|[TOML.Template](Transpilers/Templates/TOML.Template.psx.ps1)              |TOML Template Transpiler.       |```\.toml$```                   |
|[TypeScript.Template](Transpilers/Templates/TypeScript.Template.psx.ps1)  |TypeScript Template Transpiler. |```\.tsx{0,1}```                |
|[WebAssembly.Template](Transpilers/Templates/WebAssembly.Template.psx.ps1)|WebAssembly Template Transpiler.|```\.wat$```                    |
|[XAML.Template](Transpilers/Templates/XAML.Template.psx.ps1)              |XAML Template Transpiler.       |```\.xaml$```                   |
|[XML.Template](Transpilers/Templates/XML.Template.psx.ps1)                |XML Template Transpiler.        |```\.xml$```                    |
|[YAML.Template](Transpilers/Templates/YAML.Template.psx.ps1)              |Yaml Template Transpiler.       |```\.(?>yml\\|yaml)$```         |
