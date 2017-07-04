
type os = 
  | Windows 
  | Linux
  | OSX

let os = Windows

let resources_dir = ""

let canonical_path s = Windows.Utils.get_full_path s
