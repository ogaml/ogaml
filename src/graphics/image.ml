
exception Load_error of string

type t = {width : int; height : int; data : Bytes.t}

let clamp f a b = min b (max f a)

let convert c = Char.chr (int_of_float (c *. 255.))

let inverse c = (float_of_int (Char.code c)) /. 255.

external stbi_load_from_file : string -> (string * int * int) option = "caml_image_load_from_file"

external stbi_load_error : unit -> string = "caml_image_load_error"

let create = function
  |`File s -> begin
    match stbi_load_from_file s with
    |None -> 
      let msg = Printf.sprintf "Failed to load image file %s. Reason : %s" 
                               s (stbi_load_error()) 
      in raise (Load_error msg)
    |Some (s,x,y) -> begin
      {width = x; height = y; data = s}
    end
  end
  |`Empty (width, height, color) ->
    let img = 
      {
        width ; 
        height; 
        data = Bytes.make (width * height * 4) '\000'
      }
    in
    let r,g,b,a = 
      let c = Color.rgb color in
      convert c.Color.RGB.r, 
      convert c.Color.RGB.g, 
      convert c.Color.RGB.b,
      convert c.Color.RGB.a
    in
    for i = 0 to (width * height * 4) - 1 do
      if i mod 4 = 0 then
        Bytes.set img.data i r
      else if i mod 4 = 1 then
        Bytes.set img.data i g
      else if i mod 4 = 2 then
        Bytes.set img.data i b
      else
        Bytes.set img.data i a
    done; img

let size img = (img.width, img.height)

let set img x y c = 
  let r,g,b,a =
    let c = Color.rgb c in
    convert c.Color.RGB.r, 
    convert c.Color.RGB.g, 
    convert c.Color.RGB.b,
    convert c.Color.RGB.a
  in
  Bytes.set img.data (x * 4 * img.height + y * 4    ) r;
  Bytes.set img.data (x * 4 * img.height + y * 4 + 1) g;
  Bytes.set img.data (x * 4 * img.height + y * 4 + 2) b;
  Bytes.set img.data (x * 4 * img.height + y * 4 + 3) a

let get img x y =
  Color.RGB.(
    {r = inverse img.data.[x * 4 * img.height + y * 4 + 0];
     g = inverse img.data.[x * 4 * img.height + y * 4 + 1];
     b = inverse img.data.[x * 4 * img.height + y * 4 + 2];
     a = inverse img.data.[x * 4 * img.height + y * 4 + 3]})

let data img = img.data

