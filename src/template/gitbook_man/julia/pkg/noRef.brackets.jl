# Currently NOT USED.

# Quadlex
# All multi line nested code is to be parsed line by line.
module Brackets
# S: a string containing brackets.
# We gather all brackets on the input string S whcih is meant to compose the language grammar, e.g., for x=f("()") , the inner brackets are not working as brackets of the language grammar.
# bracketGramar: for all bracket B, define a list of brackets which can follow B on S. 
# stack: brackets are stored , last in last out 

function getBrackets(S::String,bracketGramar::Array)
  local stack=[(sym=:nothing,counter=0)]
  local brackets=[]
  local indS=1
  local counter=1
  while length(S)>0
    
    local toSort=[]
    local  f_rgx_ret
    for f_rgx in bracketGramar[stack[end].sym]
      f_rgx_ret=f_rgx(S)
      f_rgx_ret.counter=counter
      counter+=1 
      if f_rgx_ret!=nothing
        push!(toSort,(f_rgx_ret.idxFrom,f_rgx_ret))
      end
    end
  
    if length(toSort)==0 
      @assert length(stack)==1 @error stack
      break
    end

    sort!(toSort,(x)->x[1])    
    f_rgx_ret=toSort[1]
    local bClose= f_rgx_ret.sym==stack[end].sym & f_rgx_ret.bClose in [true,nothing]
    local indS_next=nextind(S, f_rgx_ret.idxTo)
    S=S[indS_next:end]
    f_rgx_ret.pair = bClose ? stack[end].counter : nothing
    
    f_rgx_ret.depth = bClose ? length(stack) : length(stack)+1
    f_rgx_ret.bClose = bClose
    f_rgx_ret.indFrom += indS-1
    f_rgx_ret.indTo += indS-1
    indS += indS_next-1

    if bClose
      deleteat!(stack,lastindex(stack))      
    else
      push!(stack,(sym=f_rgx_ret.sym,counter=f_rgx_ret.counter)) 
    end  
    push!(brackets,f_rgx_ret)
    @assert length(S)>0 | length(stack)==1 @error stack
  end

  local brackets2=[]
  for br in brackets
    if !br.bClose
      for brC in brackets
        if brC.pair==br.counter
          br.pair=brC.counter
          push!(brackets2,(br,brC))
          break
        end
      end
    end
  end

  return brackets2
end

function getBracket(from::Int,to::Int,S::String,brackets::Array)
  local last=nothing
  for br in brackets
    if br[1].idxTo<from & to<br[2].idxFrom & !br[1].isString
      last=br
      continue
    else
      if last != nothing & last[2].to < br[1].from
      break
      end
    end 
  end  
  return last
end #function
end # module