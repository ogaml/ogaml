
type t = {width : int; height : int; data : Bytes.t}

let clamp f a b = min b (max f a)

let convert c = Char.chr (int_of_float (c *. 255.))

let inverse c = (float_of_int (Char.code c)) /. 255.

let input_16bit_le str i =
  (Char.code str.[i]) + 256 * (Char.code str.[i+1])

let input_32bit_le str i =
  (Char.code str.[i]) + 256 * ((Char.code str.[i+1]) 
                      + 256 * ((Char.code str.[i+2])
                      + 256 * ( Char.code str.[i+3])))

let read_file filename =
  let chan = open_in filename in
  let len = in_channel_length chan in
  let str = Bytes.create len in
  really_input chan str 0 len;
  close_in chan; str

let ext filename = 
  let n = String.length filename in
  let i = String.rindex filename '.' in
  String.sub filename (i+1) (n-i-1)

let parse_bmp str = 
  let data_pos = 
    let tmp = input_32bit_le str 10 in
    if tmp = 0 then 54 else 0
  in
  let width  = input_32bit_le str 18 in
  let height = input_32bit_le str 22 in
  let bpp  = input_16bit_le str 28 in
  let size = 
    let tmp = input_32bit_le str 34 in
    if tmp = 0 then width * height * (bpp / 8) else tmp
  in
  let data = Bytes.make size '\000' in
  for i = 0 to size - 1 do
    match i mod 4 with
    | 0 -> Bytes.set data (i+2) str.[data_pos + i]
    | 1 -> Bytes.set data (i  ) str.[data_pos + i]
    | 2 -> Bytes.set data (i-2) str.[data_pos + i]
    | _ -> Bytes.set data (i  ) str.[data_pos + i]
  done;
  {width; height; data}

let is_valid_bmp str = 
  str.[0] = 'B' && str.[1] = 'M'

let create = function
  |`File s -> 
    if ext s = "bmp" then begin
      let dat = read_file s in
      if is_valid_bmp dat then
        parse_bmp dat
      else
        raise (Invalid_argument (Printf.sprintf "Invalid bmp image : %s" s))
    end else
      raise (Invalid_argument (Printf.sprintf "Unknown image extension : %s" s))
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

