module rec Display : sig
  
  exception X_display_error of string

  type t

  val create : unit -> t

  val screen : t -> int -> Screen.t
  
end = struct

  exception X_display_error of string

  type t = {
    socket  : Unix.file_descr;
    screens : Screen.t array
  }

  let create () = 
    let skt = Unix.socket Unix.PF_UNIX Unix.SOCK_STREAM 0 in
    let add = Unix.ADDR_UNIX "/tmp/.X11-unix/X0" in
    Unix.connect skt add;
    let buf = Bytes.create 4096 in
    let msg = Printf.sprintf "B%c%c%c%c%c%c%c%c%c%c%c" 
      '\000' '\000' '\011' '\000' '\000'
      '\000' '\000' '\000' '\000' '\000' '\000'
    in
    Unix.send skt msg 0 12 [] |> ignore;
    Unix.recv skt buf 0 4096 [] |> ignore;
    if Bytes.get buf 0 = '\000' then begin
      let length = Char.code (Bytes.get buf 1) in
      let reason = Bytes.sub buf 8 length in
      let msg = 
        Printf.sprintf 
          "Connection to X server refused. Reason : %s" 
          reason 
      in
      raise (X_display_error msg)
    end;
    {socket = skt; screens = [||]}

  let screen t i = 
    try t.screens.(i)
    with Invalid_argument _ -> 
      let msg = Printf.sprintf "Unable to access screen n°%i" i in
      raise (X_display_error msg)

end



and Screen : sig

  type t

  val root : t -> Window.t

end = struct

  type t = {
    root    : Window.t;
    size_px : (int * int);
    size_mm : (int * int)
  }

  let root t = t.root

end



and Window : sig

  type t 

end = struct

  type t = int

end

