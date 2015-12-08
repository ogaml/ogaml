open OgamlMath


module IntMap = Map.Make (struct

  type t = int

  let compare (i1 : int) (i2 : int) = compare i1 i2

end)


module IIMap = Map.Make (struct

  type t = int * int

  let compare (i1 : t) (i2 : t) = compare i1 i2

end)


module Glyph = struct

  type t = {advance : int;
            bearing : OgamlMath.Vector2i.t;
               rect : OgamlMath.IntRect.t;
                 uv : OgamlMath.IntRect.t}

  let advance t = t.advance

  let bearing t = t.bearing

  let rect t = t.rect

  let uv t = t.uv

end


module Shelf = struct

  type t = {
    mutable full   : Image.t;
    mutable row    : Image.t;
            width  : int;
    mutable height : int;
    mutable row_width  : int;
    mutable row_height : int
  }

  let create width = {
    full   = Image.create (`Empty (0,0,(`RGB Color.RGB.transparent)));
    row    = Image.create (`Empty (0,0,(`RGB Color.RGB.transparent)));
    width;
    height = 0;
    row_width  = 0;
    row_height = 0;
  }

  let add s glyph =
    let size = Image.size glyph in
    let w,h  = size.Vector2i.x, size.Vector2i.y in
    if s.row_width + w <= s.width then begin
      let new_height = max s.row_height h in
      let new_row = Image.create (`Empty (s.row_width + w, new_height,`RGB Color.RGB.transparent)) in
      Image.blit s.row new_row Vector2i.({x = 0; y = 0});
      Image.blit glyph new_row Vector2i.({x = s.row_width; y = 0});
      s.row <- new_row;
      s.row_height <- new_height;
      s.row_width <- s.row_width + w;
      IntRect.({x = s.row_width - w;
                y = s.height;
                width  = w;
                height = h})
    end else begin
      let new_full = Image.create (`Empty (s.width,(s.height + s.row_height),(`RGB Color.RGB.transparent))) in
      Image.blit s.full new_full Vector2i.({x = 0; y = 0});
      Image.blit s.row new_full Vector2i.({x = 0; y = s.height});
      s.full <- new_full;
      s.row  <- glyph;
      s.height <- (s.height + s.row_height);
      s.row_width <- w;
      s.row_height <- h;
      IntRect.({x = 0;
                y = s.height;
                width  = w;
                height = h})
    end

  let texture s =
    let global = Image.create (`Empty (s.width, s.height + s.row_height, `RGB Color.RGB.transparent)) in
    Image.blit s.full global Vector2i.zero;
    Image.blit s.row global Vector2i.({x = 0; y = s.height});
    Texture.Texture2D.create (`Image global)

end


module Internal = struct

  type t

  external load : string -> t = "caml_stb_load_font"

  external kern : t -> int -> int -> int = "caml_stb_kern_advance"

  external scale : t -> int -> float = "caml_stb_scale"

  external metrics : t -> (int * int * int) = "caml_stb_metrics"

  external char_h_metrics : t -> int -> (int * int) = "caml_stb_hmetrics"

  external char_box : t -> int -> IntRect.t = "caml_stb_box"

  external bitmap : t -> int -> float -> (Bytes.t * int * int) = "caml_stb_bitmap"

  let convert_1chan_bitmap bmp =
    let s = Bytes.length bmp in
    let bts = Bytes.create (s * 4) in
    for i = 0 to s - 1 do
      Bytes.set bts (4*i+0) '\255';
      Bytes.set bts (4*i+1) '\255';
      Bytes.set bts (4*i+2) '\255';
      Bytes.set bts (4*i+3) bmp.[i]
    done;
    bts

end


type page = {
  mutable glyph   : Glyph.t IntMap.t;
  mutable glyph_b : Glyph.t IntMap.t;
  mutable kerning : int IIMap.t;
  mutable texture : Texture.Texture2D.t;
  mutable modified: bool;
  shelf   : Shelf.t;
  scale   : float;
  spacing : int;
  ascent  : int;
  descent : int
}


type t = {
  mutable pages : page IntMap.t;
        internal : Internal.t
}


type code = [`Char of char | `Code of int]


(** Internal functions *)

let scale_int i f = int_of_float (float_of_int i *. f)

let load_size (t : t) s =
  let scale = Internal.scale t.internal s in
  let (ascent, descent, linegap) = Internal.metrics t.internal in
  let new_page =
    {
      glyph    = IntMap.empty;
      glyph_b  = IntMap.empty;
      kerning  = IIMap.empty;
      texture  = Texture.Texture2D.create (`Image
                    (Image.create (`Empty (0,0,`RGB Color.RGB.transparent)))
                  );
      modified = false;
      shelf    = Shelf.create 1024;
      spacing  = scale_int linegap scale;
      ascent   = scale_int ascent  scale;
      descent  = scale_int descent scale;
      scale;
    }
  in
  t.pages <- IntMap.add s new_page t.pages;
  new_page


let get_size (t : t) s =
  try IntMap.find s t.pages
  with Not_found ->
    load_size t s


let load_glyph_return (t : t) s c b =
  let page  = get_size t s in
  let glyph =
    let (advance, lbear) = Internal.char_h_metrics t.internal c in
    let rect = Internal.char_box t.internal c in
    let (bmp,w,h) = Internal.bitmap t.internal c page.scale in
    let bmp = Internal.convert_1chan_bitmap bmp in
    let uv = Shelf.add page.shelf (Image.create (`Data (w,h,bmp))) in
    {
      Glyph.advance = scale_int advance page.scale;
      Glyph.bearing = Vector2i.({x = scale_int lbear page.scale;
                                 y = scale_int (rect.IntRect.y + rect.IntRect.height) page.scale});
      Glyph.rect = IntRect.({x = scale_int rect.IntRect.x page.scale;
                             y = scale_int rect.IntRect.y page.scale;
                             width  = scale_int rect.IntRect.width  page.scale;
                             height = scale_int rect.IntRect.height page.scale;
                            });
      Glyph.uv = uv
    }
  in
  if b then
    page.glyph_b <- IntMap.add c glyph page.glyph_b
  else
    page.glyph   <- IntMap.add c glyph page.glyph;
  page.modified <- true;
  glyph


let load_kerning t s (c1, c2) =
  let page = get_size t s in
  let kern = scale_int (Internal.kern t.internal c1 c2) page.scale in
  page.kerning <- IIMap.add (c1, c2) kern page.kerning;
  kern


let code_to_int = function
  |`Char c -> Char.code c
  |`Code i -> i


(** Exposed functions *)
let load s =
  {
    pages  = IntMap.empty;
    internal = Internal.load s
  }


let glyph (t : t) c size bold =
  let glyphs =
    if bold then (get_size t size).glyph_b
    else (get_size t size).glyph
  in
  try IntMap.find (code_to_int c) glyphs
  with Not_found ->
    load_glyph_return t size (code_to_int c) bold


let load_glyph (t : t) c s b = 
  glyph t c s b |> ignore


let kerning t c1 c2 s =
  let k = (get_size t s).kerning in
  try IIMap.find (code_to_int c1, code_to_int c2) k
  with Not_found ->
    load_kerning t s (code_to_int c1, code_to_int c2)


let ascent t i =
  (get_size t i).ascent


let descent t i =
  (get_size t i).descent


let linegap t i =
  (get_size t i).spacing


let spacing t i =
  (ascent t i) - (descent t i) + (linegap t i)


let texture t s =
  let page = get_size t s in
  if page.modified then begin
    page.texture <- Shelf.texture page.shelf;
    page.modified <- false
  end;
  page.texture


