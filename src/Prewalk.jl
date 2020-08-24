module Prewalk

Dic=Dict([
  "gitbook"=>"""
  A Gitbook template project was generated successfully.
  \$>cd gitbook
  \$>gitbook serve
  """,
  "gitbook_man"=>""" 
  A Gitbook template project was generated successfully.
  It is also a short manual on how to use Prewalk in your Gitbook project. So it's good to read through the contents before clearing them away.
  
  \$>cd gitbook_man
  \$>gitbook serve
  """
])
function template(destdir=nothing;which="gitbook")
  if destdir==nothing;destdir=pwd();end
  @assert which in ["gitbook","gitbook_man"] 
  local desc=Dic[which]
  srcdir=@__DIR__
  srcdir=srcdir*"\\template\\"*which
  destdir=destdir*"\\"*which
  println("src: "*srcdir)
  println("dest: "*destdir)
  cp(srcdir,destdir)  
  println("OK")
  print(desc)
end
end