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


module Font = struct

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


  type page = {
    mutable glyph   : Glyph.t IntMap.t;
    mutable glyph_b : Glyph.t IntMap.t;
    mutable kerning : int IIMap.t;
    mutable texture : Texture.Texture2D.t;
    mutable modified: bool;
    shelf   : Shelf.t;
    spacing : int;
  }

  type t = (page IntMap.t) ref

  type code = [`Char of char | `Code of int]


  (** Internal functions *)
  let load_size t s = Obj.magic ()

  let get_size t s = 
    try IntMap.find s !t
    with Not_found -> 
      load_size t s

  let load_glyph t s c b = 
    let page  = load_size t s in 
    let glyph = Obj.magic () in
    if b then 
      page.glyph_b <- IntMap.add c glyph page.glyph_b
    else
      page.glyph   <- IntMap.add c glyph page.glyph;
    page.modified <- true;
    glyph

  let load_kerning t s (c1, c2) = 
    let page = load_size t s in
    let kern = 0 in
    page.kerning <- IIMap.add (c1, c2) kern page.kerning;
    kern

  let code_to_int = function
    |`Char c -> Char.code c
    |`Code i -> i


  (** Exposed functions *)
  let load s = ()

  let glyph t c size bold = 
    let glyphs = 
      if bold then (get_size t size).glyph_b
      else (get_size t size).glyph
    in
    try IntMap.find (code_to_int c) glyphs
    with Not_found -> 
      load_glyph t size (code_to_int c) bold

  let kerning t c1 c2 s = 
    let k = (get_size t s).kerning in
    try IIMap.find (code_to_int c1, code_to_int c2) k
    with Not_found -> 
      load_kerning t s (code_to_int c1, code_to_int c2)

  let spacing t i =
    (get_size t i).spacing

  let texture t i = 
    (get_size t i).texture

  let update t s = 
    let page = get_size t s in
    if page.modified then begin
      page.texture <- Shelf.texture page.shelf;
      page.modified <- false
    end

end


