
global _prewalk=nothing
function subToString(s)
  if typeof(s) <:SubString
    return String(s)
  else 
    return s
  end
end #function
function evalQ(q)
  return subToString( eval(q))
end
function evalS(s)
  s=Main.Parser.removeEmptyChar(s)
return subToString( eval(Meta.parse(s)))
end




