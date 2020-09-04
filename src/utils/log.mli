type level = Trace | Debug | Info | Warn | Error | Fatal

type t

val create : ?output:out_channel -> ?level:level -> ?color:bool -> ?short:bool -> unit -> t

val stdout : t

val stderr : t

val set_level : t -> level -> unit

val log : t -> level -> ('a, out_channel, unit) format -> 'a

val trace : t -> ('a, out_channel, unit) format -> 'a

val debug : t -> ('a, out_channel, unit) format -> 'a

val info  : t -> ('a, out_channel, unit) format -> 'a

val warn  : t -> ('a, out_channel, unit) format -> 'a

val error : t -> ('a, out_channel, unit) format -> 'a

val fatal : t -> ('a, out_channel, unit) format -> 'a

