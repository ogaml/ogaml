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

  type t = {advance : float;
            bearing : OgamlMath.Vector2f.t;
               rect : OgamlMath.FloatRect.t;
                 uv : OgamlMath.FloatRect.t}

  let advance t = t.advance

  let bearing t = t.bearing

  let rect t = t.rect

  let uv t = t.uv

end

exception Font_error of string

module Shelf = struct

  type t = {
    mutable full   : Image.t;
    mutable row    : Image.t;
            width  : int;
    mutable height : int;
    mutable row_width  : int;
    mutable row_height : int;
    mutable pad : int
  }

  let create width = {
    full   = Image.create (`Empty (Vector2i.zero,(`RGB Color.RGB.transparent)));
    row    = Image.create (`Empty (Vector2i.zero,(`RGB Color.RGB.transparent)));
    width;
    height = 0;
    row_width  = 0;
    row_height = 0;
    pad = 2;
  }

  let add s glyph =
    let size = Image.size glyph in
    let w,h  = size.Vector2i.x, size.Vector2i.y in
    if s.row_width + w + s.pad <= s.width then begin
      let new_height = max s.row_height h in
      let new_row = 
        Image.create 
          (`Empty (Vector2i.({x = s.row_width + w + s.pad; y = new_height}),`RGB Color.RGB.transparent)) 
      in
      Image.blit s.row new_row Vector2i.({x = 0; y = 0});
      Image.blit glyph new_row Vector2i.({x = s.row_width + s.pad; y = 0});
      s.row <- new_row;
      s.row_height <- new_height;
      s.row_width <- s.row_width + w + s.pad;
      IntRect.({x = s.row_width - w;
                y = s.height + s.pad;
                width  = w;
                height = h})
    end else if s.height + s.row_height + s.pad >= 2048 then begin
      raise (Font_error "Font texture overflow")
    end else begin
      let new_full = 
        Image.create 
          (`Empty (Vector2i.({x = s.width; y = s.height + s.row_height + s.pad}),(`RGB Color.RGB.transparent))) 
      in
      Image.blit s.full new_full Vector2i.({x = 0; y = 0});
      Image.blit s.row new_full Vector2i.({x = 0; y = s.height + s.pad});
      s.full <- new_full;
      s.row  <- glyph;
      s.height <- (s.height + s.row_height + s.pad);
      s.row_width <- w;
      s.row_height <- h;
      IntRect.({x = 0;
                y = s.height;
                width  = w;
                height = h})
    end

  let total_height s = 
    s.height + s.row_height + s.pad

  let image height s =
    let global = Image.create (`Empty (Vector2i.({x = s.width; y = height}), `RGB Color.RGB.transparent)) in
    Image.blit s.full global Vector2i.zero;
    Image.blit s.row global Vector2i.({x = 0; y = s.height + s.pad});
    global

end


module Internal = struct

  type t

  external load : string -> t = "caml_stb_load_font"

  external is_valid : t -> bool = "caml_stb_isvalid"

  external kern : t -> int -> int -> int = "caml_stb_kern_advance"

  external scale : t -> int -> float = "caml_stb_scale"

  external metrics : t -> (int * int * int) = "caml_stb_metrics"

  external char_h_metrics : t -> int -> (int * int) = "caml_stb_hmetrics"

  external char_box : t -> int -> IntRect.t = "caml_stb_box"

  external bitmap : t -> int -> float -> (Bytes.t * int * int) = "caml_stb_bitmap"

  external render_bitmap : 
    t -> int -> int -> float -> (Bytes.t * int * int) 
    = "caml_stb_render_bitmap"

  let convert_1chan_bitmap bmp =
    let s = Bytes.length bmp in
    let bts = Bytes.make (s * 4) '\000' in
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
  mutable kerning : float IIMap.t;
  mutable index   : int; (* Index of the page in the texture array *)
  mutable modified: bool;
  shelf   : Shelf.t;
  scale   : float;
  spacing : float;
  ascent  : float;
  descent : float
}


type t = {
  mutable pages    : page IntMap.t;
  mutable nindex   : int;
  mutable texture  : Texture.Texture2DArray.t option;
  mutable height   : int;
          internal : Internal.t
}


type code = [`Char of char | `Code of int]


(** Internal functions *)

let scale_int i f = (float_of_int i *. f)

let load_size (t : t) s =
  let scale = Internal.scale t.internal s in
  let (ascent, descent, linegap) = Internal.metrics t.internal in
  let new_page =
    {
      glyph    = IntMap.empty;
      glyph_b  = IntMap.empty;
      kerning  = IIMap.empty;
      index    = t.nindex;
      modified = false;
      shelf    = Shelf.create 2048;
      spacing  = scale_int linegap scale;
      ascent   = scale_int ascent  scale;
      descent  = scale_int descent scale;
      scale;
    }
  in
  t.nindex <- t.nindex + 1;
  t.texture <- None;
  t.pages <- IntMap.add s new_page t.pages;
  new_page


let get_size (t : t) s =
  try IntMap.find s t.pages
  with Not_found ->
    load_size t s

(* For debugging purposes *)
let print_bitmap bmp w h = 
  Printf.printf "------- Printing bitmap of size %i %i -------\n%!" w h;
  for i = 0 to h-1 do
    for j = 0 to w-1 do
      if Char.code bmp.[i*w + j] >= 200 then 
        print_string "#"
      else
        print_string "."
    done;
    print_endline "";
  done

let load_glyph_return (t : t) s c b oversampling =
  let page  = get_size t s in
  let glyph =
    let (advance, lbear) = Internal.char_h_metrics t.internal c in
    let rect = Internal.char_box t.internal c in
    let (bmp,w,h) = Internal.render_bitmap t.internal c oversampling page.scale in
    let bmp = Internal.convert_1chan_bitmap bmp in
    let uv = Shelf.add page.shelf (Image.create (`Data (Vector2i.({x = w; y = h}),bmp))) in
    {
      Glyph.advance = scale_int advance page.scale;
      Glyph.bearing = Vector2f.({x = scale_int lbear page.scale;
                                 y = scale_int (rect.IntRect.y + rect.IntRect.height) page.scale});
      Glyph.rect = FloatRect.({x = scale_int rect.IntRect.x page.scale;
                               y = scale_int rect.IntRect.y page.scale;
                               width  = scale_int rect.IntRect.width  page.scale;
                               height = scale_int rect.IntRect.height page.scale;
                             });
      Glyph.uv = FloatRect.from_int uv
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

let oversampling_of_size s = min 4 ((80 + s - 1)/s)

(** Exposed functions *)
let load s =
  if not (Sys.file_exists s) then
    raise (Font_error (Printf.sprintf "File not found : %s" s));
  let internal = Internal.load s in
  if not (Internal.is_valid internal) then
    raise (Font_error (Printf.sprintf "Invalid font file : %s" s));
  {
    pages  = IntMap.empty;
    nindex = 0;
    height = 0;
    texture = None;
    internal
  }


let glyph (t : t) c size bold =
  let glyphs =
    if bold then (get_size t size).glyph_b
    else (get_size t size).glyph
  in
  try IntMap.find (code_to_int c) glyphs
  with Not_found ->
    load_glyph_return t size (code_to_int c) bold (oversampling_of_size size)


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
  (ascent t i) -. (descent t i) +. (linegap t i)

let rebuild_page_texture (type s) (module M : RenderTarget.T with type t = s) target t height page = 
  let i_layer = page.index in
  let layer = 
    match t.texture with
    | None   -> assert false
    | Some t -> Texture.Texture2DArray.layer t i_layer
  in
  let mipmap = 
    Texture.Texture2DArrayLayer.mipmap layer 0
  in
  Texture.Texture2DArrayLayerMipmap.write
    mipmap
    IntRect.({x = 0; y = 0; width = 2048; height})
    (Shelf.image height page.shelf)

let rebuild_full_texture (type s) (module M : RenderTarget.T with type t = s) target t height = 
  let rec insert (w, elt) = function
    | []               -> [w,elt]
    | (w', e')::t as l -> if w < w' then (w,elt)::l
                          else (w',e')::(insert (w,elt) t)
  in
  let l_imgs = IntMap.fold (fun _ page l -> 
    let index = page.index in
    let img   = Shelf.image height page.shelf in
    insert (index, img) l) t.pages []
  in
  let l_imgs_strip = List.map (fun (_,i) -> `Image i) l_imgs in
  let texture = 
    if l_imgs_strip = [] then 
      Texture.Texture2DArray.create (module M) target 
        ~mipmaps:`None [`Empty Vector2i.zero]
    else 
      Texture.Texture2DArray.create (module M) target 
        ~mipmaps:`None l_imgs_strip
  in
  Texture.Texture2DArray.minify  texture Texture.MinifyFilter.Linear;
  Texture.Texture2DArray.magnify texture Texture.MagnifyFilter.Linear;
  t.texture <- Some texture

let texture (type s) (module M : RenderTarget.T with type t = s) target t =
  let mod_pages, max_height = IntMap.fold (fun _ page (l,h) ->
    if page.modified then begin
      page.modified <- false;
      (page :: l, max (Shelf.total_height page.shelf) h)
    end else (l, h)
  ) t.pages ([], t.height)
  in
  if t.height < max_height || t.texture = None then begin
    rebuild_full_texture (module M) target t max_height;
    t.height <- max_height
  end else if mod_pages <> [] then begin
    List.iter (fun p -> rebuild_page_texture (module M) target t max_height p) mod_pages
  end;
  match t.texture with
  | None -> assert false
  | Some t -> t

let size_index t s = 
  try 
    let page = IntMap.find s t.pages in
    page.index
  with
    Not_found -> raise (Font_error "Font size's index not found")
    
