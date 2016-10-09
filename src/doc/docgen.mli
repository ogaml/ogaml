
(** [parse_from_file filename] *)
val parse_from_file : string -> AST.module_field list

(** [preprocess modulename fields] *)
val preprocess : string -> AST.module_field list -> ASTpp.module_data

(** [preprocess_file filename] *)
val preprocess_file : string -> ASTpp.module_data

(** [gen_header root modulename] *)
val gen_header : string -> string -> string

(** [gen_main root module] *)
val gen_main : string -> ASTpp.module_data -> string

(** [gen_index_main root modules examplefile] *)
val gen_index_main : string -> ASTpp.module_data list -> string -> string

(** [gen_aside root modules] *)
val gen_aside : string -> ASTpp.module_data option -> ASTpp.module_data list -> string

