type comment_token = 
  | PP_CommentString of string
  | PP_Inline  of string
  | PP_EOL     
  | PP_Related of string

and comment = 
  comment_token list

and type_data = 
  {
    tparam : type_param option;
    tname : string;
    texpr : type_expr option;
    tmembers : (string * comment) list;
    tenum : (string * comment) list
  }

and module_field =
  | PP_Title of string
  | PP_Comment of comment
  | PP_Type of type_data * comment
  | PP_Val of string * type_expr * comment
  | PP_Exn of string * type_expr option * comment
  | PP_Functor of functor_data * comment

and functor_data = 
  {
    fname : string;
    fargs : (string * string) list;
    fsign : string;
    fcons : (string * type_expr) list
  }

and variance = AST.variance

and type_param = AST.type_param

and type_expr = 
  | PP_ModType of string * type_expr
  | PP_AtomType of string
  | PP_Record of (string * type_expr) list
  | PP_PolyVariant of variance * ((string * type_expr option) list)
  | PP_PolyType of string
  | PP_Arrow of type_expr * type_expr
  | PP_TypeTuple of type_expr list
  | PP_NamedParam of string * type_expr
  | PP_OptionalParam of string * type_expr
  | PP_Variant of (string * type_expr option) list
  | PP_ParamType of (type_expr list * type_expr)

and module_data = 
  {
    hierarchy : string list;
    modulename : string;
    description : comment;
    submodules : module_data list;
    signatures : module_data list;
    contents : module_field list
  }

