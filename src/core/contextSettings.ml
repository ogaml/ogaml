type t = {
  msaa : int;
  depth : int;
  stencil : int;
  resizable : bool;
  fullscreen : bool;
  framerate : int option;
  major_version : int option;
  minor_version : int option;
  forward_compatible : bool;
  debug : bool;
  core_profile : bool;
  compatibility_profile : bool
}

let create ?depth:(depth = 24)
           ?stencil:(stencil = 0)
           ?msaa:(msaa = 0)
           ?resizable:(resizable = true)
           ?fullscreen:(fullscreen = false) 
           ?framerate_limit 
           ?major_version
           ?minor_version
           ?(forward_compatible=false)
           ?(debug = false)
           ?(core_profile=false)
           ?(compatibility_profile=false) () =
  {
    msaa;
    depth;
    stencil;
    resizable;
    fullscreen;
    framerate = framerate_limit;
    major_version;
    minor_version;
    forward_compatible;
    debug;
    core_profile;
    compatibility_profile
  }

let aa_level t = t.msaa

let depth_bits t = t.depth

let stencil_bits t = t.stencil

let resizable t = t.resizable

let framerate_limit t = t.framerate

let fullscreen t = t.fullscreen

let major_version t = t.major_version

let minor_version t = t.minor_version

let forward_compatible t = t.forward_compatible

let debug t = t.debug

let core_profile t = t.core_profile

let compatibility_profile t = t.compatibility_profile
