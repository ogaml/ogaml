
type t = {
          color     : Color.t;
          depth     : int;
          stencil   : int;
          msaa      : int;
          resizable : bool
         }

let create ?color:(color = `RGB Color.RGB.black)
           ?depth:(depth = 24)
           ?stencil:(stencil = 0)
           ?msaa:(msaa = 0)
           ?resizable:(resizable = true) () =
    {
     color;
     depth;
     stencil;
     msaa;
     resizable
    }

let clearing_color t = t.color

let depth_bits t = t.depth

let stencil_bits t = t.stencil

let msaa t = t.msaa

let resizable t = t.resizable

let to_ll t =
  OgamlCore.LL.ContextSettings.create
    ~antialiasing:t.msaa
    ~depth_bits:t.depth
    ~stencil_bits:t.stencil
    ~resizable:t.resizable ()
