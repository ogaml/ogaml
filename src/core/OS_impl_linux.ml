
type os = 
  | Windows 
  | Linux
  | OSX

let os = Linux

let resources_dir = ""

let canonical_path s = 
  if Sys.file_exists s then
    X11.Utils.realpath s
  else
    invalid_arg ("File not found : " ^ s)
