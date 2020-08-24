module Conf # Namespace for configurations.
    rootDir=join(splitpath(@__DIR__)[1:end-1],"\\") # The dir where you put SUMMARY.md.
    
    prewalkChar='🏣'  #\:post_office:
    emptyChar='🔰'    #\:beginner:
    delChar='|' 
    DEBUG="debug" in ARGS
    for c in [prewalkChar,emptyChar,delChar]
      @assert typeof(c)==Char @error typeof(c),"It must be Char."
    end
end
global DIR = (@__DIR__)
include("pkg/forGitbook.jl")

module User # Namespace for user's code.
include("pkg/user.eval.jl")
if isfile("../jl/user.jl")
  include("../jl/user.jl")
end
end


include("pkg/parser.jl")
ForGitbook.init(User,Parser)

function getAllPwMdFromSummaryMd()
# This code only for a particular Gitbook senario.
# Open SUMMARY.md
# gather all dest files into an array IN A SORTED ORDER.

  local destArr=[]
  open("$(Conf.rootDir)/SUMMARY.md") do f
  #  open(Main.Conf.rootDir*"/SUMMARY.md") do f
    #find all entry of pw.md files in SUMMARY.md
    local r1=r"\]\s{0,}\((\S{1,}\.pw\.md)\)\s{0,}$"
    for i in enumerate(eachline(f))
      local idx,line=i[1],i[2]
      H,R=("",line)
      local m=match(r1,line)
      if m!=nothing
        local destPwMd=String(m[1])
        #local srcMd=destToSrc(destMd)
        #src_dest=[  Main.Conf.rootDir*"/"*md for md in [srcMd,destMd]]
        push!(destArr,destPwMd)
      end      
    end
  end
  return destArr
end

#As a rare case, the user also compile jl.svg files.
#pw.svg files are stored also in "md" directory.
#pw.svg files are processed after all pw.md files.
function getAllSVG()
  local srcArr=[]
  local destArr=[]  
  local mdImg="md"
  for (root, dirs, files) in walkdir("$(Conf.rootDir)/$(mdImg)")
    #to match to all file name if with the extension as .jl.svg
    local r=r"\.jl\.svg$"
    
    for file in files
      local m=match(r,file)
      if m!=nothing
        local src=  root*"/"*file
        #local dest=replace(src,r=>s".pw.svg")
        push!(srcArr,src)          
      end
    end    
end
return srcArr
end

function changeExt(file::String,rgxSubst::Pair{Regex,SubstitutionString{String}}
  )
    #for the file name, replace the extension through rgxSubst
    local newext=replace(file,rgxSubst)
    @assert file!=newext @error file,rgxSubst
    return newext
  
end

function run()
  local ok=false

  local destArr=getAllPwMdFromSummaryMd()
  if Conf.DEBUG;@show destArr;end
  destArr=[ (changeExt(dest,r"\.pw\.md$"=> s".jl.md"),dest) for dest in destArr]
  ok=Main.ForGitbook.build(destArr)

  local srcArr=getAllSVG()
  if Conf.DEBUG;@show srcArr;end
  srcArr=[ (src,changeExt(src,r"\.jl\.svg$"=> s".pw.svg")) for src in srcArr]
  ok&=Main.ForGitbook.build(srcArr)

  return ok
end

module Lggng
global LOG=[]
function log(s)
  push!(LOG,s)
  if length(LOG)>20;deleteat!(Lggng.LOG,1:10);end
end
end

@show Conf.prewalkChar
begin
local ok=run()
  if !ok 
    for lg in Lggng.LOG 
      println(lg)
    end
  end
end


