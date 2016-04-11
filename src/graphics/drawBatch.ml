
type t = {
  mutable curr_program : Program.t option;
  mutable curr_params  : DrawParameter.t option;
  mutable curr_source  : VASourceInternal.Source.t option;
  mutable curr_uniform : Uniform.t option;
  mutable curr_flush   : 
    VASourceInternal.Source.t ->
    program    : Program.t ->
    uniform    : Uniform.t ->
    parameters : DrawParameter.t -> unit
}

let create () = {
  curr_program = None;
  curr_params  = None;
  curr_source  = None;
  curr_uniform = None;
  curr_flush   = 
    fun src ~program ~uniform ~parameters -> ()
}

let empty t = 
  t.curr_program <- None;
  t.curr_params  <- None;
  t.curr_source  <- None;
  t.curr_uniform <- None

let flush t = 
  match t.curr_source, t.curr_program, t.curr_params, t.curr_uniform with
  | None, _, _, _ | _, None, _, _ | _, _, None, _ | _, _, _, None -> ()
  | Some src, Some prg, Some prm, Some unf ->
    t.curr_flush src ~program:prg ~uniform:unf ~parameters:prm;
    empty t

let set_flush_function t f = t.curr_flush <- f

let rec buffer t ~program ~parameters ~source ~uniform = 
   match t.curr_source, t.curr_program, t.curr_params, t.curr_uniform with
  | None, _, _, _ | _, None, _, _ | _, _, None, _ | _, _, _, None -> 
    t.curr_source  <- Some source;
    t.curr_program <- Some program;
    t.curr_params  <- Some parameters;
    t.curr_uniform <- Some uniform
  | Some src, Some prg, Some prm, Some unf ->
    if prg = program && parameters = prm && uniform = unf then begin
       try VASourceInternal.Source.append src source |> ignore
       with VASourceInternal.Invalid_source _ -> begin
          flush t;
          buffer t ~program ~parameters ~source ~uniform
       end
    end else begin
      flush t;
      buffer t ~program ~parameters ~source ~uniform
    end

 
