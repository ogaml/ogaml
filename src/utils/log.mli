
type level = Debug | Warn | Error | Info | Fatal

type t

val create : ?output:out_channel -> ?debug:bool -> ?color:bool -> ?short:bool -> unit -> t

val stdout : t

val stderr : t

val log : t -> level -> ('a, out_channel, unit) format -> 'a

val debug : t -> ('a, out_channel, unit) format -> 'a

val warn  : t -> ('a, out_channel, unit) format -> 'a

val error : t -> ('a, out_channel, unit) format -> 'a

val info  : t -> ('a, out_channel, unit) format -> 'a

val fatal : t -> ('a, out_channel, unit) format -> 'a

