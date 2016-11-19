
type os =
  | Windows
  | Linux
  | OSX

let os = OSX

let resources_dir = Cocoa.resource_path () ^ "/"

let canonical_path s = Cocoa.realpath s
