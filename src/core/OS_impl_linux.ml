
type os = 
  | Windows 
  | Linux
  | OSX

let os = Linux

let resources_dir = ""

let canonical_path s = X11.Utils.realpath s
