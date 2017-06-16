
type os =
  | Windows
  | Linux
  | OSX

let os = OSX

let resources_dir = Cocoa.resource_path () ^ "/"

let canonical_path s = 
  if Sys.file_exists s then
    Cocoa.realpath s
  else
    invalid_arg ("File not found : " ^ s)
