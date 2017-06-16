type t = {
  msaa : int;
  depth : int;
  stencil : int;
  resizable : bool;
  fullscreen : bool;
  framerate : int option
}

let create ?depth:(depth = 24)
           ?stencil:(stencil = 0)
           ?msaa:(msaa = 0)
           ?resizable:(resizable = true)
           ?fullscreen:(fullscreen = false) 
           ?framerate_limit () =
  {
    msaa;
    depth;
    stencil;
    resizable;
    fullscreen;
    framerate = framerate_limit
  }

let aa_level t = t.msaa

let depth_bits t = t.depth

let stencil_bits t = t.stencil

let resizable t = t.resizable

let framerate_limit t = t.framerate

let fullscreen t = t.fullscreen
