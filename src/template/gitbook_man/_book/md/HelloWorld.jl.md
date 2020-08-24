### Inline julia code

<br/>
🏣|"Hello World"*"!"^3|🏣
<br/>

### Multi line julia code block 1

[#
exp1=collect(1:2:7)
exp2=collect(1:10)
exp1,exp2=[ "$(exp)"[2:end-1] for exp in [exp1,exp2]]
#]

- 🏣|exp1|🏣
- 🏣|exp2|🏣

### Multi line julia code block 2

[#
x=1
#
y=(
  1,
  2
)
#]

### Use JlWalk with Katex
$$ \{🏣|exp1|🏣\}\subset \{🏣|exp2|🏣\} $$

### Escape JlWalk brackets

[#
num1_7="123-45#67"
r=replace(num1_7, r"[-🏣|"#"|🏣]"=>"") 
#]

🏣|r|🏣

### Examples of preprocessed julia code


- Hello world🏣|"!"^10|🏣
- 🏣|| 1+2==🏣|"123"[end]|🏣 ||🏣

[#
x=sqrt(2)
#]

- 🏣|x|🏣


[#
using Printf
#]

🏣||Printf.@sprintf(""" 🏣|"%s,"^4|🏣 """, 1:4...)🏣||