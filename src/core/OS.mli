
type os =
  | Windows
  | Linux
  | OSX

val os : os

val resources_dir : string

val canonical_path : string -> string
