%token EOF
%token <string> LIDENT
%token <string> UIDENT
%token <string> COMMENT
%token <string> DOCCOMMENT
%token <string> TITLECOMMENT
%token <string> OPERATOR
%token APOSTROPHE QUOTE QMARK LPAREN RPAREN
%token STAR COLON SEMICOLON EQUALS
%token LBRACE RBRACE LBRACK RBRACK
%token PIPE DOT ARROW COMMA
%token MODULE VAL TYPE END SIG EXN OF
%token LOWER GREATER

%start <AST.module_field list> file
%%

file:
  |m = module_content; EOF {m}
  ;

module_field:
  |s = DOCCOMMENT
    {AST.Documentation s}
  |s = TITLECOMMENT
    {AST.Title s}
  |TYPE; t = LIDENT 
    {AST.AbstractType (None, t)}
  |TYPE; p = type_param; t = LIDENT 
    {AST.AbstractType (Some p,t)}
  |TYPE; t = LIDENT; EQUALS; e = type_expr 
    {AST.ConcreteType (None,t,e)}
  |TYPE; p = type_param; t = LIDENT; EQUALS; e = type_expr 
    {AST.ConcreteType (Some p,t,e)}
  |VAL; t = LIDENT; COLON; e = delim_value_type
    {AST.Value (t,e)}
  |VAL; op = OPERATOR; COLON; e = delim_value_type
    {AST.Value (op,e)}
  |EXN; t = UIDENT 
    {AST.Exn (t, None)}
  |EXN; t = UIDENT; OF; e = delim_value_type
    {AST.Exn (t, Some e)}
  |MODULE; t = UIDENT; COLON; SIG; m = module_content; END
    {AST.Module (t, m)}
  ;

module_content:
  | {[]}
  | m = module_field; c = module_content {m::c}
  ;

type_param:
  |LPAREN; s = type_params; RPAREN {AST.ParamTuple s}
  |APOSTROPHE; s = LIDENT {AST.Polymorphic s}
  ;

type_params:
  | s = type_param {[s]}
  | s = type_param; COMMA; t = type_params {s::t}
  ;

atomic_type:
  | m = UIDENT; DOT; a = atomic_type {AST.ModuleType(m,a)}
  | a = LIDENT {AST.AtomType(a)}
  ;

value_type:
  | t = atomic_type {t}
  | APOSTROPHE; v = LIDENT {AST.PolyType v}
  | LBRACE; r = record_content; RBRACE {AST.Record r}
  | LBRACK; LOWER; r = vp_content; RBRACK {AST.PolyVariant (AST.Lower, r)}
  | LBRACK; GREATER; r = vp_content; RBRACK {AST.PolyVariant (AST.Greater, r)}
  | LBRACK; r = vp_content; RBRACK {AST.PolyVariant (AST.Equals, r)}
  | LPAREN; t = delim_value_type; RPAREN {t}
  | r = value_type; t = atomic_type {AST.ParamType (r,t)}
  ;

delim_value_type:
  | t = value_type {t}
  | t1 = funparam_type; ARROW; t2 = delim_value_type {AST.Arrow (t1,t2)}
  | t = tuple_type {AST.TypeTuple t}
  ;

funparam_type:
  | t = value_type {t}
  | n = LIDENT; COLON; t = value_type {AST.NamedParam(n,t)}
  | QMARK; n = LIDENT; COLON; t = value_type {AST.OptionalParam(n,t)}
  ;

tuple_type:
  | t = value_type; STAR; t2 = value_type {[t;t2]}
  | t = value_type; STAR; t2 = tuple_type {t::t2}
  ;

type_expr:
  | t = variant {AST.Variant t}
  | PIPE; t = variant {AST.Variant t}
  | v = delim_value_type {v}
  ;

optional_comment:
  | s = COMMENT {Some s}
  | {None}

record_content:
  | s = LIDENT; COLON; t = delim_value_type; opt = optional_comment {[opt,s,t]}
  | s = LIDENT; COLON; t = delim_value_type; SEMICOLON; opt = optional_comment; c = record_content {(opt,s,t)::c}
  ;

variant:
  | u = UIDENT; opt = optional_comment {[(opt,u,None)]}
  | u = UIDENT; OF; t = delim_value_type; opt = optional_comment {[(opt,u,Some t)]}
  | u = UIDENT; opt = optional_comment; PIPE; v = variant {(opt,u,None) :: v}
  | u = UIDENT; OF; t = delim_value_type; opt = optional_comment; PIPE; v = variant {(opt,u,Some t) :: v}
  ;

vp_content:
  | QUOTE; u = UIDENT {[u,None]}
  | QUOTE; u = UIDENT; OF; t = delim_value_type {[u, Some t]}
  | QUOTE; u = UIDENT; PIPE; v = vp_content {(u,None) :: v}
  | QUOTE; u = UIDENT; OF; t = delim_value_type; PIPE; v = vp_content {(u,Some t) :: v}
  ;

