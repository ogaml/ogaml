open OgamlMath

type t = {
  chars    : (Font.code * Font.Glyph.t) list ;
  vertices : VertexArray.static VertexArray.t
}

let create ~text ~position ~font ~size ~bold =
  let length = String.length text in
  let rec iter i =
    if i >= length then []
    else begin
      let code = (`Char text.[i]) in
      let glyph = Font.glyph font code size bold in
      (code,glyph) :: (iter (i+1))
    end
  in
  let chars = iter 0 in
  let vertices,advance =
    let lift v = Vector3f.lift (Vector2f.from_int v) in
    List.fold_left
      (fun (source, advance_vec) (_,glyph) ->
        let bearing = Font.Glyph.bearing glyph in
        let bearingX = Vector2i.({ x = bearing.x ; y = 0 })
        and bearingY = Vector2i.({ x = 0 ; y = bearing.y }) in
        let (width, height) =
          let rect = Font.Glyph.rect glyph in
          let open IntRect in
          Vector2i.({ x = rect.width ; y = 0 }),
          Vector2i.({ x = 0 ; y = rect.height })
        in
        let corner = Vector2i.(
          add advance_vec (add position (sub bearingX bearingY))
        ) in
        let uv = Font.Glyph.uv glyph in
        let (uvx,uvy,uvw,uvh) =
          let open IntRect in
          let f = float_of_int in
          (* TODO Normalize *)
          f uv.x , f uv.y , f uv.width , f uv.height
        in
        let v1 =
          VertexArray.Vertex.create
            ~position:(lift corner)
            ~texcoord:Vector2f.({ x = uvx ; y = uvy })
            ()
        and v2 =
          VertexArray.Vertex.create
            ~position:(lift Vector2i.(add corner width))
            ~texcoord:Vector2f.({ x = uvx +. uvw ; y = uvy })
            ()
        and v3 =
          VertexArray.Vertex.create
            ~position:(lift Vector2i.(add corner (add width height)))
            ~texcoord:Vector2f.({ x = uvx +. uvw ; y = uvy +. uvh })
            ()
        and v4 =
          VertexArray.Vertex.create
            ~position:(lift Vector2i.(add corner height))
            ~texcoord:Vector2f.({ x = uvx ; y = uvy +. uvh })
            ()
        in
        VertexArray.Source.(
          source << v1 << v2 << v3
                 << v3 << v4 << v1
        ),
        Vector2i.(add advance_vec { x = Font.Glyph.advance glyph ; y = 0 })
      )
      (
        VertexArray.Source.(
          empty
            ~position:"position"
            ~texcoord:"uv"
            ~size:(String.length text)
            ()
        ),
        Vector2i.zero
      )
      chars
    |> fun (source, advance) -> VertexArray.static source, advance
  in
  {
    chars ;
    vertices ;
  }
