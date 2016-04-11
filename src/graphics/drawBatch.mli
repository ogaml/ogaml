
type t

val create : unit -> t

val set_flush_function : 
  t ->
  (VASourceInternal.Source.t ->
  program    : Program.t ->
  uniform    : Uniform.t ->
  parameters : DrawParameter.t -> unit) -> unit

val buffer : 
  t -> 
  program:Program.t ->
  parameters:DrawParameter.t ->
  source:VASourceInternal.Source.t ->
  uniform:Uniform.t -> unit

val flush : t -> unit

val empty : t -> unit
