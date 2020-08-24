module Parser

#For module ForGitbook to display debug info.
mutable struct U
  src::String
  lastLine::Array{Int,1}
  warning::Array{String,1} 
end

global _U=U("",[0,0],[])

function setLastLine(x1=_U.lastLine[1],x2=_U.lastLine[2])
  _U.lastLine[1]=x1
  _U.lastLine[2]=x2
end
function incLastLine1()
  setLastLine(_U.lastLine[1]+1)
end
function incLastLine2()
  setLastLine(_U.lastLine[1], _U.lastLine[2]+1)
end

global Conf=Main.Conf
global User=Main.User




# Process one src file.
function main(src::String,dest::String)
  local destH,inMLB,MLB,m_MLB
  destH="" # To hold the content of the output file.
  inMLB=false # Flag, true if we are reading multi line code.
  open(src,"r") do f
    
    # Process one line.
    for i in enumerate(eachline(f))
      setLastLine(i[1],0)
      local H,R,m
      local line =i[2]

      # Process one inline code
      @assert checkPrewalkChar(line) @error line,"for example,$(Conf.prewalkChar)||$(Conf.prewalkChar)"
      line= processPrewalk(line)
      while true
        b_match,line= decDegreeOfPrewalk(line)
        if !b_match;break;end
        line= processPrewalkBlock(line)
      end

      # Find multi line julia code block.
      # Process the found block.
      # Note that the return value of a multi line block is not used.
      local pwBrackets=(open="\\[#",close="#]")
      local  (open,close) =pwBrackets # ["\\[#","#]"] 
      local genRgx=(op_cl)->eval(Meta.parse(
       """ r"^\\s{0,}($(op_cl))\\s{0,}\$" """
      ))

      if inMLB
        m=match(genRgx(open),line)
        @assert m==nothing @error _U.lastLine
        m=match(genRgx(close),line)
        
        inMLB= m==nothing
        if inMLB
          MLB*="\n"*line
        else          
          local e=evalML(MLB) 
          continue            
        end
      else

        m=match(genRgx(close),line)
        @assert m==nothing @error _U.lastLine
        m=match(genRgx(open),line)
          inMLB= m!=nothing          
          if inMLB;MLB="";end
      end
      if inMLB;continue;end
      
      destH*="\n"*line
      
    end
      @assert !inMLB _U.lastLine
  end

  # Output all output lines to the output file.
  open(dest,"w") do f
    write(f,removeEmptyChar(destH))
  end
end
  
# Process a multi line block.
function evalML(S::String)
  Main.Lggng.log( "enter: evalML, "*S)
  
  @assert nothing==match(r"#=",S) @error "Multi line code cannot contain #=."
  local LL=split(S,"\n")
  local SS=[]
  local subBlock=""

  # Divide all lines into sub blocks which are delimited single line comments.
  # (Using a multi line comment #= =# is against the grammar. )
  for line in LL
    local rc=r"^(\s{0,}#.{0,})$"
    if nothing!=match(rc,line)
      if subBlock!="";push!(SS,subBlock);subBlock=""
      else continue
      end
    else subBlock*="\n"*line
    end
  end
  
  if length(subBlock)>0 ; push!(SS,subBlock); subBlock="";end
  Main.Lggng.log( "mid: evalML, $(SS)")

  local HH=[] 

  # Process each subBlock
  for i in eachindex(SS)
    
    incLastLine2()
    
    try evalMP(SS[i])
    catch err
      function onCatch(S,isML)  
        println("Source code:")
        println("$(S)")    
        println("isMultiLine: $(isML)") 
        
      end
      onCatch(SS[i],true)
      @error err,i
      @assert false & (err!=nothing)
    end
    
  end #for
  
end # function

# User use emptyChar to separate 2 chars grammatically but lexically.
# All emptyChar must be removed before being evaluated and before being output.
function removeEmptyChar(s)
  return replace(s,r""*Conf.emptyChar=>"")
end

# Evaluate julia code in the user's namespace, module User.
function evalMP(s)
 Main.Lggng.log( "enter: evalMP, "*s)
 s=removeEmptyChar(s)
  local mp=nothing
 
  try mp=Meta.parse(s) 
  catch err
    # Check if the cause of err is "a new line".
    local m=match(r"extra token after end of expression","$(err)")
    if m!=nothing
      # Try parse again after replacing a newline with ";".
      mp=Meta.parse(replace(s,r"\n"=>";"))
    else 
      @error (err,s) 
    end    
  end 

  e=User.evalQ(mp) 
  Main.Lggng.log( "exit: evalMP, $(e)")
  return e
end

#=
# Return the number of matches for the args.
function countRgx(s::String,r::Regex,n::Int)
  local sr=replace(s,r=>"")
  return (length(s)-length(sr))/n
end
=#

# Check the typical errorneous pattern against user's code.
function checkPrewalkChar(line::String)
  local m=match(r""*Conf.prewalkChar*r"[|]{1,}"*Conf.prewalkChar,line)
  return m==nothing
  r=r""*"@"*r"[|]{1,}"*"@"
end

# Replace all prewalkChar of degree one with the value of _prewalk.
# It is important if typeof(_prewalk) accepts simple indexing.
# For example, Array or Tuple accepts simple indexing.
function processPrewalk(line::String)
  Main.Lggng.log( "enter: processPrewalk, "*line)
  
  # To simplfy the logic in terms of Regex.
  line=" $(line) "

  # Get the value of _prewalk.
  local Prewalk_=  User.evalS("_prewalk")
  local bArray= typeof(Prewalk_)<:Array
  
  if bArray
    Prewalk_=Iterators.Stateful(Prewalk_)
  end

  local r=genRgx("([^$(Conf.delChar)])$(Conf.prewalkChar)([^$(Conf.delChar)])")
    
  local H,R="",line
  # Process each prewalkChar.
  while length(R )>0
    local m=match(r,R)
    if m!=nothing
      H*=R[1:m.offset]*
      "$((bArray ? popfirst!(Prewalk_) : Prewalk_ ))"
      R=R[m.offsets[2]:end]    
    else
      H*=R
      break
    end
  end
  
  # Remove spaces from the head and tail which we have added around at the top line.
  H=H[nextind(H,1):prevind(H,lastindex(H))]

  Main.Lggng.log( "exit: processPrewalk, $(H)")
  return H
end

# For each prewalkChar, reduce the number of bars which accompany it.
function decDegreeOfPrewalk(line::String)
  Main.Lggng.log( "enter: decDegreeOfPrewalk, "*line)
  
  local open,close =Conf.prewalkChar*"|","|"*Conf.prewalkChar
  local ropen,rclose=r""*open,r""*close
  local b=false
  for r in [ropen,rclose]
    if nothing!=match(r,line)
      b=true
      line =replace(line,r=>Conf.prewalkChar)
    end
  end
  
  Main.Lggng.log( "exit: decDegreeOfPrewalk, $(b),$(line)")
  return b,line
end

function genRgx(s)
  return eval(Meta.parse(""" r"$(s)" """))
end

# Process a block between prewalkChars of degree one. 
function processPrewalkBlock(line::String)
  Main.Lggng.log( "enter: processPrewalkBlock, "*line)
  
  # To simplfy our code in terms of Regex.
  line=" $(line) "
  
  # Define a Regex to find delimiters.
  local r=genRgx("[^"*Conf.delChar*"]")*Conf.prewalkChar*genRgx("([^"*Conf.delChar*"])")

  # We replace all delimiters with maxchar.
  local maxchar="\U10FFFF"
  local H,R="",line
  local cnt=0
  while length(R)>0
    local m=match(r,R)
    if m!=nothing
      H*= R[1:m.offset]*maxchar
      R= R[m.offsets[1]:end]
      cnt+=1
    else
      H*=R
      break;
    end    
  end
  @assert cnt%2==0 @error ("odd number of active prewalkChar(s)",line)

  H=H[nextind(H,1):prevind(H,lastindex(H))]

  # Find and process each block.
  r=genRgx("$(maxchar)([^$(maxchar)]{0,})($(maxchar))")
  local line2=""
  local nextidx=1
  local pre=nothing
  for m in eachmatch(r,H)
      line2*=H[nextidx:prevind(H,m.offset)]*"$(User.evalS( m[1] ))"
      nextidx=nextind(H,m.offsets[2])    
  end
  line2*=H[nextidx:end]
  
  Main.Lggng.log( "exit: processPrewalkBlock, $(line2)")
  return line2
end

end # module

