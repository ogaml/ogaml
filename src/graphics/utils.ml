let trybind res f = 
  match res with
  | Ok t -> f t
  | Error e -> Error e

let (>>=) = trybind

let bind res f = 
  match res with
  | Ok t -> Ok (f t)
  | Error e -> Error e

let (>>>=) = bind
