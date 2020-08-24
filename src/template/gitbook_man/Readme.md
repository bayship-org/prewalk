> If you are reading this Readme in Github, some part will not be in good condition. 


 [Document](https://bayship-org.github.io/gitbook/prewalk/index.html "Document")

[Github](https://github.com/bayship-org/prewalk "Github")
 

### What is Prewalk?

Prewalk is a string interpolation tool into any text files. For example, latex source files, markdown files, or source code files of any programming languages. 

Though in the rest we focus on how to use Prewalk for markdown files in Gitbook projects. Some samples are also included for Katex and SVG in Gitbook.

### Notation
All jl.md files are your source files to be compliled into pw.md files which will be displayed in your Gitbook project. For example:

- test.jl.md
- test.pw.md

The same holds for jl.svg files.

- test.jl.svg
- test.pw.svg

Here follows notations for important directories.

- $InstallDir: the directory to install $Gitbook template.
- $Gitbook: the root directory of the template.
- $Gitbook/md: put all your source files here.
  - jl.md and jl.svg. 
- $Gitbook/jl: put all your julia source files here.
  - If you need own libraries.
- $Gitbook/julia: to customize Prewalk, edit jl files here.
  


### How to install
The template for gitbook is in Prewalk/src/template/gitbook
To generalte Gitbook template, open a julia REPL:

```
pkg> add Prewalk
julia> using Prewalk
julia> cd("$InstallDir")
julia> Prewalk.template()
```

Back to the OS terminal.
```
$> cd $InstallDir/$Gitbook
$> gitbook serve
```
Open your browser at localhost:4000 by default.

### Add an md file

Suppose you want to add a new markdown file, "$Gitbook/md/test.md". As a downside of the template project, the file name must be "test.pw.md".

Add an entry of "test.pw.md" into "$Gitbook/SUMMARY.md". Though do not create "$Gitbook/md/test.pw.md" in the file system as Prewalk will create it.

```
# Summary
(README.md)
[TEST](md/test.pw.md)
```

Instead you need to create "$Gitbook/md/test.jl.md". Put the following code in "test.jl.md".

```
### Hello world

🏣| "Hello world" |🏣
```

The special character,'🏣', is called prewalkChar. You can type prewalkChar by:

- Open julia REPL.
- type "\:post_office:".
- type TAB.

If you do not like the default prewalkChar, you can change it in "$Gitbook/julia/main.jl" at "module Conf.prewalkChar".

After compiling all jl.md files,we expect:
```
### Hello world

Hello world
```

### Complile jl.md files

To compile all jl.md files:

```
$> cd $Gitbook
$> julia julia/main.jl
$> gitbook serve #If it does not auto reload.
```

Note that all jl.md files are compiled in the order of entries in SUMMARY.md. It implies that just one change in some jl.md file will trigger compiling all jl.md files.


### More complex example
For $Gitbook/md/.../test.jl.md, Prewalk evaluates julia code in the following order. Note that these files, 1. to 3., are not necessary. And all jl file is evaluated exactly once.

1. $Gitbook/jl/user.jl
2. $Gitbook/md/.../_.jl
3. $Gitbook/md/.../test.jl
4. $Gitbook/md/.../test.jl.md

For the following code:
```
[#
x=10
#]

### Hello world

🏣| "Hello world"*"!"^x |🏣 
```

We expect:
```
### Hello world

Hello world!!!!!!!!!! 
```

The form of prewalkChar, 🏣|, is said degree 1 because one bar accompanies 🏣. Theoretically degrees of 🏣 ranges from zero to the infinite. As a major drawback of Prewalk, 🏣| and |🏣 are equivalent for Prewalk's recognition. That is, the followings are equivalent.

- 🏣| "123" |🏣
-  🏣| "123" 🏣|


Line by line, Prewalk evaluates 🏣 in the accending order of degrees.

For the following code:
```
[#
_prewalk=123
#]

### Hello world

🏣  
```

We expect:
```
123
```
That is, Prewalk substitutes the value of the reserved variable,_prewalk, into 🏣 if typeof(_prewalk) is such that does not accept simple indexing.
Meanwile if _prewalk does:

```
[#
_prewalk=(1,2,3)
#]

### Hello world

🏣 < 🏣 < 🏣  
```

We expect:
```
1 < 2 < 3
```

Although the following code is practically nonsense:
```
[#
using Printf
#]
🏣|| Printf.@sprintf(""" 🏣|"%s,"^4|🏣 """, 1:4...) ||🏣
```

We expect:
```
1,2,3,4
```

Sometimes you may need to type a prewalkChar followed by a bar not for denoting the degree. For such a case, you may use emptyChar, 🔰. For example, 🏣🔰|. To type emptyChar:

- Open julia REPL.
- Type "\:beginner:".
- Type TAB.

### Some typical errors

```
[#
x=1
y=(
  1
)
#]
```

It results an error because the first new line needs to be replaced with ";" whereas the rest new lines are to be ignored.
To fix the problem, you use a comment as follows.

```
[#
x=1
#
y=(
  1
)
#]
```

The following code also results an error because multi line comments are not supported.

```
[#
x=1
#=
=#
y=(
  1
)
#]
```


### Use JlWalk with Katex

Roughly speaking, all Katex expressions is a latex expressions between pairs of double dollar symbols. In the rest, we denote it as:

- DoubleDollars latex_expression DoubleDollars


For the following code, where all "DoubleDollars" is to be replace with &#36;&#36;:

```
DoubleDollars \{ 🏣|exp1|🏣 \} \subset \{ 🏣|exp2|🏣 \} DoubleDollars
```

We expect:

> $$\{1, 3, 5, 7\}\subset \{1, 2, 3, 4, 5, 6, 7, 8, 9, 10\}$$


### Prerequisites

First of all, you need Gitbook cli installed.
- [Gitbook cli][1]
[1]: https://www.npmjs.com/package/gitbook-cli

<br/>

> KaTeX is a cross-browser JavaScript library that displays mathematical notation in web browsers. 

<br/>

>Katex handles only a limited subset of LaTeX's mathematics notation.

For example, the following Katex expression $$1$$ will be printed as $$2$$. 

1. \$\$ a \in A \$\$
2. $$a\in A$$. 







