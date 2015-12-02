
type t = {
          color  : Color.t;
          clears : bool;
          depth  : bool;
          stencil: bool
         }

let create ?color:(color = `RGB Color.RGB.black)
           ?clear_color:(clear_color = true)
           ?depth:(depth = true)
           ?stencil:(stencil = false) () =
    {
     color;
     clears = clear_color;
     depth;
     stencil
    }

let color t = t.color

let color_clearing t = t.clears

let depth_testing t = t.depth

let stenciling t = t.stencil

let to_ll t = OgamlCore.LL.ContextSettings.create ()
