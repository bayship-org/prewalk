# pkg activate . 
# add Revise
# using Revise 
# using JlWalk
# https://medium.com/@thibaut.deveraux/how-to-start-creating-packages-for-julia-with-revise-jl-bdb47fd4ca5a


module ForGitbook

# Store all jl files already included to prevent including them more than once.
global jl_files=Dict([])

function init(User2,Parser2)
  global Parser=Parser2
  global User=User2 
end

function build(src_destArr)
# src_destArr holds pairs of src,dest file names.
# Read each src file then output a dest file.
  local lastProcessedFile=""
  local println_succ=(i=length(src_destArr))->begin
        println("="^10)
        println( "number of md files : $(length(src_destArr))" )
        println( "current md file: $(i)")
        println( "last successfully processed source path: $(lastProcessedFile=="" ? "none" : lastProcessedFile)")
        println( "last successfully processed source file: $(lastProcessedFile=="" ? "none" : basename(lastProcessedFile))")
        
        println("="^10)
        if length(Parser._U.warning)>0
          println("Warning")
          println("$(Parser._U.warning)")
          println("="^10)
        end
      end
  
  for i in eachindex(src_destArr)
    src,dest=src_destArr[i]
    #We include jl files related to src unless they have already been included.
    local dirjl=replace(src,r"[^\/]{1,}$"=>"")
    dirjl=replace(dirjl,r""*"\\"=>"/")*"_.jl"
    local jl=replace(src,r"\.[^\.]{1,}$"=>"")
    jl=replace(jl,r""*"\\"=>"/")  
    for myjl in [dirjl,jl]
      if isfile(myjl) 
        if !haskey(jl_files,myjl)
          User.evalS("include(\"$(myjl)\")")
          jl_files[myjl]=myjl
        end
      end
    end
    
    if !isfile(src)
      println("!isfile(src)") 
      @error src 
    end
    
    try
      Parser.main(src,dest)
      lastProcessedFile=src

    catch err 
      println_succ(i) 
              
      println("="^10)
      println( "By default, all indexing starts at 1.")
      println( "error path: " * src)
      println( "error file: " * basename(src))
      println( "error line: " * "$(Parser._U.lastLine[1])")
      println( "error inline: " * "$(Parser._U.lastLine[2])")
      println( "error message: $(err)")
      println("="^10)
      println("\nFAILED\n")
      println("="^10)
      return false
    end
      
  
  end
    println_succ()
    println("="^10)
    println("\nOK\n")
    println("="^10)
    return true
    
end

end # module
