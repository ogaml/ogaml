open OgamlMath
open OgamlCore
open OgamlUtils
open Result.Operators


module Fx = struct

  type t = {
    font       : Font.t;
    size       : int;
    chars      : ((float * Font.code * Font.Glyph.t) * Color.t) list ;
    vertices   : VertexArray.t ;
    advance    : Vector2f.t ;
    boundaries : FloatRect.t
  }

  type ('a,'b) it = 'a -> 'b -> ('b -> 'b) -> 'b

  type ('a,'b,'c) full_it = ('a,'b) it * 'b * ('b -> 'c)

  let forall c =
    (fun _ v k -> k (c :: v)),
    [],
    (fun x -> x)

  let foreach f =
    (fun e v k ->
      k ((f e) :: v)),
    [],
    List.rev

  (* Keeps the first component of a pair list while reversing it. *)
  (* let rec revpi1 l k =
    match l with
    | (e,_) :: r -> revpi1 r (e :: k)
    | [] -> k *)

  let foreachi f =
    (fun e (v,i) k ->
      k ((f e i) :: v, i+1)),
    ([],0),
    (fun (l,_) -> List.rev l)

  (* Checks if i is code for blank space. *)
  let isblankspace i = Char.(
       i = code ' '
    || i = code '\t'
    || i = code '\n'
  )

  (* Cons the value as many times as there are elements in the first list *)
  let rec guarded_cons v w l =
    match w with
    | _ :: wr -> guarded_cons v wr (v :: l)
    | [] -> l

  let foreachword f default =
    (fun e (v,h) k ->
      match e with
      | `Code i when isblankspace i ->
        begin match h with
          | [] -> k (default :: v, [])
          | h  -> k (default :: (guarded_cons (f (List.rev h)) h v), [])
        end
      | _ -> k (v, e :: h)),
    ([],[]),
    (fun (v,h) ->
      List.rev
        (begin match h with
          | [] -> v
          | h  -> guarded_cons (f (List.rev h)) h v
        end))

  (* This function has type ('a,'b) it -> 'b -> 'a list -> 'b *)
  let rec iter f v = function
    | e :: r -> f e v (fun v -> iter f v r)
    | [] -> v

  (* This function has type ('a,'b,'c) full_it -> 'a list -> 'c *)
  let full_iter (it,init,conv) l =
    conv (iter it init l)

  (* A function to lift a (Font.code,'b) it to a
   * (float * Font.code * Font.Glyph.t,'b) it *)
  let lift f = fun (kern,code,glyph) -> f code

  let full_lift (it,init,conv) = (lift it, init, conv)

  let create (type s) (module M : RenderTarget.T with type t = s) 
             ~target
             ~text
             ~position
             ~font
             ~(colors : (Font.code,'b,Color.t list) full_it)
             ~size
             () =
    UTF8String.from_string text >>>= fun utf8 ->
    let length = UTF8String.length utf8 in
    let rec fold i =
      if i >= length then []
      else if i = length - 1 then begin
        let code = (`Code (UTF8String.get utf8 i |> Result.assert_ok)) in
        let glyph = Font.glyph font code size false in
        [0.,code,glyph]
      end
      else begin
        let code = (`Code (UTF8String.get utf8 i |> Result.assert_ok)) in
        let code' = (`Code (UTF8String.get utf8 (i+1) |> Result.assert_ok)) in
        let glyph = Font.glyph font code size false in
        let kern = Font.kerning font code code' size in
        (kern,code,glyph) :: (fold (i+1))
      end
    in
    let chars = fold 0 in
    (* Compute the list of colours. *)
    let color_list = full_iter (full_lift colors) chars in
    let chars = List.combine chars color_list in
    let vertices,advance,width =
      let lift v = Vector3f.lift v in
      List.fold_left
        (fun (source, advance_vec, line_width) ((kern,code,glyph),color) ->
         match code with
         | `Code i when i = Char.code '\n' ->
           source,
           Vector2f.({
             x = 0. ;
             y = advance_vec.y +. (Font.spacing font size)
           }),
           max advance_vec.Vector2f.x line_width
         | code ->
           let bearing = Font.Glyph.bearing glyph in
           let bearingX = Vector2f.({ x = bearing.x ; y = 0. })
           and bearingY = Vector2f.({ x = 0. ; y = bearing.y }) in
           let (width, height) =
             let rect = Font.Glyph.rect glyph in
             let open FloatRect in
             Vector2f.({ x = rect.width ; y = 0. }),
             Vector2f.({ x = 0. ; y = rect.height })
           in
           let corner = Vector2f.(
             add advance_vec (add position (sub bearingX bearingY))
           ) in
           let uv = Font.Glyph.uv glyph in
           let (uvx,uvy,uvw,uvh) =
             let open FloatRect in
             uv.x, uv.y, uv.width, uv.height
           in
           let v1 =
             VertexArray.SimpleVertex.create
               ~position:(lift corner)
               ~uv:Vector2f.({ x = uvx ; y = uvy })
               ~color
               ()
           and v2 =
             VertexArray.SimpleVertex.create
               ~position:(lift Vector2f.(add corner width))
               ~uv:Vector2f.({ x = uvx +. uvw ; y = uvy })
               ~color
               ()
           and v3 =
             VertexArray.SimpleVertex.create
               ~position:(lift Vector2f.(add corner (add width height)))
               ~uv:Vector2f.({ x = uvx +. uvw ; y = uvy +. uvh })
               ~color
               ()
           and v4 =
             VertexArray.SimpleVertex.create
               ~position:(lift Vector2f.(add corner height))
               ~uv:Vector2f.({ x = uvx ; y = uvy +. uvh })
               ~color
               ()
           in
           VertexArray.Source.(source <<< v1 <<< v2 <<< v3 <<< v3 <<< v1 <<< v4),
           Vector2f.(
             add advance_vec { x = Font.Glyph.advance glyph +. kern ; y = 0. }
           ),
           line_width
        )
        (
          Ok (VertexArray.Source.empty ~size:((UTF8String.length utf8) * 6) ()),
          Vector2f.zero,
          0.
        )
        chars
      |> fun (source, advance, line_width) -> 
          let source = Result.assert_ok source in
          let vbo = VertexArray.Buffer.static (module M) target source in 
          (VertexArray.create (module M) target [VertexArray.Buffer.unpack vbo],
          advance,
          max advance.Vector2f.x line_width)
    in
    let boundaries = {
      FloatRect.x      = position.Vector2f.x ;
      FloatRect.y      = position.Vector2f.y
                       -. (Font.ascent font size) ;
      FloatRect.width  = width ;
      FloatRect.height = advance.Vector2f.y
                       +. (Font.ascent font size)
                       -. (Font.descent font size)
    } in
    {
      font     ;
      size     ;
      chars    ;
      vertices ;
      advance  ;
      boundaries
    }

  let draw (type s) (module M : RenderTarget.T with type t = s) 
           ?parameters:(parameters = DrawParameter.make
           ~antialiasing:false
           ~depth_test:DrawParameter.DepthTest.None
           ~blend_mode:DrawParameter.BlendMode.alpha ())
           ~text ~target () =
    let context = M.context target in
    let program = Context.LL.text_drawing context in
    Font.texture (module M) target text.font >>>= fun texture ->
    let size = Vector2f.from_int (M.size target) in
    let index = Font.size_index text.font text.size |> Result.assert_ok in
    let tsize = 
      Texture.Texture2DArray.size texture
      |> Vector3i.project
      |> Vector2f.from_int
    in
    let uniform =
      Ok (Uniform.empty)
      >>= Uniform.vector2f "window_size" size
      >>= Uniform.vector2f "atlas_size" tsize
      >>= Uniform.texture2Darray "atlas" texture
      >>= Uniform.int "atlas_offset" index
      |> Result.assert_ok
    in
    let vertices = text.vertices in
    VertexArray.draw (module M)
          ~target
          ~vertices
          ~program
          ~parameters
          ~uniform
          ~mode:DrawMode.Triangles ()
    |> Result.assert_ok

  let advance text = text.advance

  let boundaries text = text.boundaries

end

type t = {
  font       : Font.t;
  size       : int;
  chars      : (float * Font.code * Font.Glyph.t) list;
  vertices   : VertexArray.SimpleVertex.T.s VertexArray.Vertex.t list;
  advance    : Vector2f.t ;
  boundaries : FloatRect.t
}

let create ~text ~position ~font ?color:(color=(`RGB Color.RGB.black)) ~size ?bold:(bold = false) () =
  UTF8String.from_string text >>>= fun utf8 ->
  let length = UTF8String.length utf8 in
  let rec iter i =
    if i >= length then []
    else if i = length - 1 then begin
      let code = (`Code (UTF8String.get utf8 i |> Result.assert_ok)) in
      let glyph = Font.glyph font code size bold in
      [0.,code,glyph]
    end
    else begin
      let code = (`Code (UTF8String.get utf8 i |> Result.assert_ok)) in
      let code' = (`Code (UTF8String.get utf8 (i+1) |> Result.assert_ok)) in
      let glyph = Font.glyph font code size bold in
      let kern = Font.kerning font code code' size in
      (kern,code,glyph) :: (iter (i+1))
    end
  in
  let chars = iter 0 in
  let vertices,advance,width =
    let lift v = Vector3f.lift v in
    List.fold_left
      (fun (lvtx, advance_vec, line_width) (kern,code,glyph) ->
       match code with
       | `Code i when i = Char.code '\n' ->
         lvtx,
         Vector2f.({
           x = 0. ;
           y = advance_vec.y +. (Font.spacing font size)
         }),
         max advance_vec.Vector2f.x line_width
       | code ->
         let bearing = Font.Glyph.bearing glyph in
         let bearingX = Vector2f.({ x = bearing.x ; y = 0. })
         and bearingY = Vector2f.({ x = 0. ; y = bearing.y }) in
         let (width, height) =
           let rect = Font.Glyph.rect glyph in
           let open FloatRect in
           Vector2f.({ x = rect.width ; y = 0. }),
           Vector2f.({ x = 0. ; y = rect.height })
         in
         let corner = Vector2f.(
           add advance_vec (add position (sub bearingX bearingY))
         ) in
         let uv = Font.Glyph.uv glyph in
         let (uvx,uvy,uvw,uvh) =
           let open FloatRect in
           uv.x, uv.y, uv.width, uv.height
         in
         let v1 =
           VertexArray.SimpleVertex.create
             ~position:(lift corner)
             ~uv:Vector2f.({ x = uvx ; y = uvy })
             ~color
             ()
         and v2 =
           VertexArray.SimpleVertex.create
             ~position:(lift Vector2f.(add corner width))
             ~uv:Vector2f.({ x = uvx +. uvw ; y = uvy })
             ~color
             ()
         and v3 =
           VertexArray.SimpleVertex.create
             ~position:(lift Vector2f.(add corner (add width height)))
             ~uv:Vector2f.({ x = uvx +. uvw ; y = uvy +. uvh })
             ~color
             ()
         and v4 =
           VertexArray.SimpleVertex.create
             ~position:(lift Vector2f.(add corner height))
             ~uv:Vector2f.({ x = uvx ; y = uvy +. uvh })
             ~color
             ()
         in
         v1 :: v2 :: v3 :: v3 :: v1 :: v4 :: lvtx,
         Vector2f.(
           add advance_vec { x = Font.Glyph.advance glyph +. kern ; y = 0. }
         ),
         line_width
      )
      (
        [],
        Vector2f.zero,
        0.
      )
      chars
    |> fun (lvtx, advance, line_width) -> lvtx,
                                          advance,
                                          max advance.Vector2f.x line_width
  in
  let boundaries = {
    FloatRect.x      = position.Vector2f.x ;
    FloatRect.y      = position.Vector2f.y
                     -. (Font.ascent font size) ;
    FloatRect.width  = width ;
    FloatRect.height = advance.Vector2f.y
                     +. (Font.ascent font size)
                     -. (Font.descent font size)
  } in
  {
    font     ;
    size     ;
    chars    ;
    vertices ;
    advance  ;
    boundaries
  }


let draw (type s) (module M : RenderTarget.T with type t = s) 
         ?parameters:(parameters = DrawParameter.make
         ~antialiasing:false
         ~depth_test:DrawParameter.DepthTest.None
         ~blend_mode:DrawParameter.BlendMode.alpha ())
         ~text ~target () =
  let context = M.context target in
  let program = Context.LL.text_drawing context in
  Font.texture (module M) target text.font >>>= fun texture ->
  let size = Vector2f.from_int (M.size target) in
  let index = Font.size_index text.font text.size |> Result.assert_ok in
  let tsize = 
    Texture.Texture2DArray.size texture
    |> Vector3i.project
    |> Vector2f.from_int
  in
  let uniform =
    Ok Uniform.empty
    >>= Uniform.vector2f "window_size" size
    >>= Uniform.vector2f "atlas_size" tsize
    >>= Uniform.texture2Darray "atlas" texture
    >>= Uniform.int "atlas_offset" index
    |> Result.assert_ok
  in
  let vertices = 
    let vtx = text.vertices in
    let src = VertexArray.Source.empty
      ~size:32 () 
    in
    Result.List.iter (VertexArray.Source.add src) vtx |> Result.assert_ok;
    let vbo = VertexArray.Buffer.(unpack (static (module M) target src)) in
    VertexArray.create (module M) target [vbo]
  in
  VertexArray.draw
        (module M)
        ~target
        ~vertices
        ~program
        ~parameters
        ~uniform
        ~mode:DrawMode.Triangles ()
  |> Result.assert_ok

let to_source text src = 
  Result.List.iter (VertexArray.Source.add src) text.vertices

let map_to_source text f src = 
  Result.List.iter (fun v -> VertexArray.Source.add src (f v)) text.vertices

let advance text = text.advance

let boundaries text = text.boundaries
