type t = {
  position  : Vector2f.t ;
  origin    : Vector2f.t ;
  rotation  : float ;
  scale     : Vector2f.t ;
}

let create ?(position=Vector2f.zero) ?(origin=Vector2f.zero) ?(rotation=0.) 
  ?(scale=Vector2f.{x = 1.; y = 1.}) () =
  {position; origin; rotation; scale}

let position t = 
  t.position

let origin t = 
  t.origin

let rotation t = 
  t.rotation

let scale t = 
  t.scale

let compose ?(translation=Vector2f.zero) ?(rotation=0.) 
  ?(scaling=Vector2f.{x = 1.; y = 1.}) t = 
  {
    position = Vector2f.add t.position translation;
    rotation = t.rotation +. rotation;
    scale = Vector2f.{x = scaling.x *. t.scale.x; y = scaling.y *. t.scale.y};
    origin = t.origin
  }

let translate dp t = 
  compose ~translation:dp t

let rotate angle t = 
  compose ~rotation:angle t

let rescale scaling t = 
  compose ~scaling t

let set ?position ?origin ?rotation ?scale t =
  {
    position = (match position with Some p -> p | None -> t.position);
    origin = (match origin with Some p -> p | None -> t.origin);
    rotation = (match rotation with Some p -> p | None -> t.rotation);
    scale = (match scale with Some p -> p | None -> t.scale);
  }

let apply transform point =
  (* Scaling *)
  Vector2f.({
    x = (point.x -. transform.origin.x) *. transform.scale.x;
    y = (point.y -. transform.origin.y) *. transform.scale.y;
  })
  |> fun point ->
  (* Rotation *)
  Vector2f.({
    x = cos(transform.rotation) *. point.x -.
        sin(transform.rotation) *. point.y;
    y = sin(transform.rotation) *. point.x +.
        cos(transform.rotation) *. point.y;
  })
  |> fun point ->
  (* Translation *)
  Vector2f.add point transform.position
