open OgamlMath

exception Image_error of string

(* Note : data is stored in row-major order, starting from the bottom-left 
 * corner to avoid having to flip the image when creating a texture.
 * However, all accesses are done relatively to the top-left corner to be consistent
 * with the usual 2D conventions. *)
type t = {width : int; height : int; data : Bytes.t}

let clamp f a b = min b (max f a)

let convert c = Char.chr (int_of_float (c *. 255.))

let inverse c = (float_of_int (Char.code c)) /. 255.

external stbi_load_from_file : string -> (string * int * int) option = "caml_image_load_from_file"

external stbi_load_error : unit -> string = "caml_image_load_error"

external stbi_write_png : string -> (int * int) -> int -> int -> Bytes.t -> unit = "caml_image_write_png"

let create = function
  |`File s -> begin
    (* stb_image automatically flips the image so that it is stored in 
     * the correct order *)
    match stbi_load_from_file s with
    |None -> 
      let msg = Printf.sprintf "Failed to load image file %s. Reason : %s" 
                               s (stbi_load_error()) 
      in raise (Image_error msg)
    |Some (s,x,y) -> begin
      {width = x; height = y; data = s}
    end
  end
  |`Empty ({Vector2i.x = width; y = height}, color) ->
    let img = 
      {
        width ; 
        height; 
        data = Bytes.make (width * height * 4) '\000'
      }
    in
    let r,g,b,a = 
      let c = Color.to_rgb color in
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
  |`Data ({Vector2i.x = width; y = height}, data) -> 
    if Bytes.length data <> width * height * 4 then
      raise (Image_error "Create from data: invalid length of data");
    {width; height; data}

let size img = 
  OgamlMath.Vector2i.({x = img.width; y = img.height})

let set img v c = 
  let open Vector2i in
  let r,g,b,a =
    let c = Color.to_rgb c in
    convert c.Color.RGB.r, 
    convert c.Color.RGB.g, 
    convert c.Color.RGB.b,
    convert c.Color.RGB.a
  in
  try 
    Bytes.set img.data ((img.height - v.y - 1) * 4 * img.width + v.x * 4    ) r;
    Bytes.set img.data ((img.height - v.y - 1) * 4 * img.width + v.x * 4 + 1) g;
    Bytes.set img.data ((img.height - v.y - 1) * 4 * img.width + v.x * 4 + 2) b;
    Bytes.set img.data ((img.height - v.y - 1) * 4 * img.width + v.x * 4 + 3) a;
  with
    Invalid_argument _ -> raise (Image_error "Set : index out of bounds")

let get img v =
  let open Vector2i in
  try 
    Color.RGB.(
    {r = inverse img.data.[(img.height - v.y - 1) * 4 * img.width + v.x * 4 + 0];
     g = inverse img.data.[(img.height - v.y - 1) * 4 * img.width + v.x * 4 + 1];
     b = inverse img.data.[(img.height - v.y - 1) * 4 * img.width + v.x * 4 + 2];
     a = inverse img.data.[(img.height - v.y - 1) * 4 * img.width + v.x * 4 + 3]})
  with
    Invalid_argument _ -> raise (Image_error "Get : index out of bounds")

let mirror_data img = 
  let img_rev = create (`Empty (size img, `RGB Color.RGB.black)) in
  for x = 0 to img.width - 1 do
    for y = 0 to img.height - 1 do
      let c = get img Vector2i.({x; y}) in
      set img_rev Vector2i.({x; y = img.height - 1 - y}) (`RGB c);
    done
  done;
  img_rev

let save img filename =
  (* Since stb_image_write does not offer a way to flip the image when writing,
   * we need to flip it ourselves. *)
  let img_rev = mirror_data img in
  stbi_write_png filename (img.width,img.height) 4 0 img_rev.data 

let data img = img.data

let mipmap img lvl = 
  let new_width  = img.width  lsr lvl in
  let new_height = img.height lsr lvl in
  let new_img    = create (`Empty ({Vector2i.x = new_width; y = new_height}, `RGB Color.RGB.black)) in
  for x = 0 to new_width - 1 do
    for y = 0 to new_height - 1 do
      set new_img {Vector2i.x; y} 
        (`RGB (get img {Vector2i.x = x lsl lvl; y = y lsl lvl}))
    done;
  done;
  new_img

let blit src ?rect dest pos = 
  let rect = 
    match rect with
    |None   -> OgamlMath.(IntRect.create Vector2i.zero (size src))
    |Some r -> r
  in
  let off = Vector2i.sub pos (IntRect.position rect) in
  try 
    OgamlMath.IntRect.iter rect 
      (fun v -> set dest (Vector2i.add v off) (`RGB (get src v)))
  with Image_error _ -> raise (Image_error "Blit : rectangle out of bounds")

let pad img ?offset:(offset = Vector2i.zero) ?color:(color = `RGB Color.RGB.black) size = 
  let new_img = create (`Empty (size,color)) in
  for i = offset.Vector2i.x to size.Vector2i.x - 1 do
    for j = offset.Vector2i.y to size.Vector2i.y - 1 do
      get new_img Vector2i.({x = i - offset.Vector2i.x; y = j - offset.Vector2i.y})
      |> (fun c -> `RGB c)
      |> set new_img Vector2i.({x = i; y = j})
    done;
  done;
  new_img

