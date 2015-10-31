
type t = {width : int; height : int; data : float array}

let create = function
  |`File s -> {width = 0; height = 0; data = [||]}
  |`Empty (width, height, color) ->
    let img = 
      {
        width ; 
        height; 
        data = Array.make (width * height * 4) 0.
      }
    in
    let r,g,b,a = 
      let c = Color.rgb color in
      c.Color.RGB.r, 
      c.Color.RGB.g, 
      c.Color.RGB.b,
      c.Color.RGB.a
    in
    for i = 0 to (width * height * 4) - 1 do
      if i mod 4 = 0 then
        img.data.(i) <- r
      else if i mod 4 = 1 then
        img.data.(i) <- g
      else if i mod 4 = 2 then
        img.data.(i) <- b
      else
        img.data.(i) <- a
    done; img

let size img = (img.width, img.height)

let set img x y c = 
  let r,g,b,a =
    let c = Color.rgb c in
    c.Color.RGB.r, 
    c.Color.RGB.g, 
    c.Color.RGB.b,
    c.Color.RGB.a
  in
  img.data.(x * 4 * img.height + y * 4    ) <- r;
  img.data.(x * 4 * img.height + y * 4 + 1) <- g;
  img.data.(x * 4 * img.height + y * 4 + 2) <- b;
  img.data.(x * 4 * img.height + y * 4 + 3) <- a

let get img x y =
  Color.RGB.(
    {r = img.data.(x * 4 * img.height + y * 4 + 0);
     g = img.data.(x * 4 * img.height + y * 4 + 1);
     b = img.data.(x * 4 * img.height + y * 4 + 2);
     a = img.data.(x * 4 * img.height + y * 4 + 3)})

let data img = img.data

