
(** [pp hierarchy modulename fields] *)
val pp : string list -> string -> AST.module_field list -> ASTpp.module_data

val to_html : ASTpp.module_data -> string

val parse_from_file : string -> AST.module_field list

(** [gen directory file] *)
val gen : string -> string -> ASTpp.module_data
