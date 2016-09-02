type comment_token = 
  | PP_CommentString of string
  | PP_Inline  of string
  | PP_EOL     
  | PP_Related of string

and comment = 
  comment_token list

and module_field =
  | PP_Title of string
  | PP_Comment of comment
  | PP_Type of type_param option * string * type_expr option * comment
  | PP_Val of string * type_expr * comment
  | PP_Exn of string * type_expr option * comment
  | PP_Functor of functor_data * comment

and functor_data = AST.mfunctor

and variance = AST.variance

and type_param = AST.type_param

and type_expr = AST.type_expr

and module_data = 
  {
    modulename : string;
    description : string;
    submodules : module_data list;
    signatures : module_data list;
    contents : module_field list
  }

