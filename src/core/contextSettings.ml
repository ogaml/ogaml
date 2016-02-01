type t = {
  msaa : int;
  depth : int;
  stencil : int;
  resizable : bool;
  fullscreen : bool
}

let create ?depth:(depth = 24)
           ?stencil:(stencil = 0)
           ?msaa:(msaa = 0)
           ?resizable:(resizable = true)
           ?fullscreen:(fullscreen = false) () =
  {msaa;
   depth;
   stencil;
   resizable;
   fullscreen}

let aa_level t = t.msaa

let depth_bits t = t.depth

let stencil_bits t = t.stencil

let resizable t = t.resizable

let fullscreen t = t.fullscreen
