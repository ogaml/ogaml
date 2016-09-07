
(** [parse_from_file filename] *)
val parse_from_file : string -> AST.module_field list

(** [preprocess modulename fields] *)
val preprocess : string -> AST.module_field list -> ASTpp.module_data

(** [preprocess_file filename] *)
val preprocess_file : string -> ASTpp.module_data

(** highlighting header *)
val highlight_init_code : string

(** [gen directory moduledata] *)
val gen : string -> ASTpp.module_data -> unit
