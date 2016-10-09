type token =
  | EOF
  | STRING of (string)
  | INT of (int)
  | FLOAT of (float)
  | VERTEX
  | UV
  | NORMAL
  | FACE
  | PARAM
  | USEMTL
  | MATLIB
  | OBJECT
  | GROUP
  | SMOOTH
  | OFF
  | LEFTBRACKET
  | RIGHTBRACKET
  | SLASH

open Parsing;;
let _ = parse_error;;
let yytransl_const = [|
    0 (* EOF *);
  260 (* VERTEX *);
  261 (* UV *);
  262 (* NORMAL *);
  263 (* FACE *);
  264 (* PARAM *);
  265 (* USEMTL *);
  266 (* MATLIB *);
  267 (* OBJECT *);
  268 (* GROUP *);
  269 (* SMOOTH *);
  270 (* OFF *);
  271 (* LEFTBRACKET *);
  272 (* RIGHTBRACKET *);
  273 (* SLASH *);
    0|]

let yytransl_block = [|
  257 (* STRING *);
  258 (* INT *);
  259 (* FLOAT *);
    0|]

let yylhs = "\255\255\
\001\000\003\000\003\000\004\000\004\000\005\000\005\000\006\000\
\007\000\007\000\007\000\008\000\008\000\008\000\008\000\009\000\
\009\000\010\000\010\000\011\000\011\000\012\000\012\000\013\000\
\013\000\014\000\014\000\015\000\015\000\015\000\015\000\015\000\
\015\000\015\000\015\000\015\000\015\000\002\000\002\000\000\000"

let yylen = "\002\000\
\002\000\001\000\001\000\004\000\005\000\003\000\004\000\004\000\
\002\000\003\000\004\000\001\000\003\000\004\000\005\000\004\000\
\005\000\004\000\002\000\004\000\002\000\004\000\002\000\004\000\
\002\000\002\000\002\000\001\000\001\000\001\000\001\000\001\000\
\001\000\001\000\001\000\001\000\001\000\000\000\002\000\002\000"

let yydefred = "\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\040\000\000\000\028\000\029\000\
\030\000\031\000\032\000\033\000\034\000\035\000\036\000\037\000\
\000\000\002\000\003\000\000\000\000\000\000\000\000\000\000\000\
\000\000\021\000\000\000\019\000\000\000\023\000\000\000\025\000\
\000\000\026\000\027\000\001\000\039\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\007\000\008\000\000\000\000\000\000\000\011\000\020\000\018\000\
\022\000\024\000\005\000\000\000\014\000\017\000\015\000"

let yydgoto = "\002\000\
\013\000\014\000\028\000\015\000\016\000\017\000\018\000\032\000\
\019\000\020\000\021\000\022\000\023\000\024\000\025\000"

let yysindex = "\008\000\
\060\255\000\000\012\255\012\255\012\255\010\255\012\255\005\255\
\006\255\007\255\009\255\023\255\000\000\011\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\060\255\000\000\000\000\012\255\012\255\012\255\255\254\010\255\
\012\255\000\000\016\255\000\000\029\255\000\000\031\255\000\000\
\033\255\000\000\000\000\000\000\000\000\012\255\012\255\012\255\
\002\255\010\255\012\255\019\255\020\255\022\255\024\255\012\255\
\000\000\000\000\025\255\037\255\010\255\000\000\000\000\000\000\
\000\000\000\000\000\000\039\255\000\000\000\000\000\000"

let yyrindex = "\000\000\
\047\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\047\000\000\000\000\000\000\000\000\000\000\000\001\000\000\000\
\023\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\033\000\000\000\
\000\000\000\000\043\000\000\000\000\000\000\000\000\000\053\000\
\000\000\000\000\013\000\000\000\063\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000"

let yygindex = "\000\000\
\000\000\025\000\254\255\000\000\000\000\000\000\000\000\224\255\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000"

let yytablesize = 332
let yytable = "\050\000\
\012\000\029\000\030\000\059\000\033\000\034\000\036\000\038\000\
\001\000\040\000\044\000\031\000\013\000\026\000\027\000\049\000\
\052\000\061\000\060\000\035\000\037\000\039\000\009\000\041\000\
\042\000\046\000\047\000\048\000\070\000\053\000\051\000\054\000\
\006\000\055\000\063\000\064\000\043\000\065\000\069\000\066\000\
\071\000\068\000\010\000\056\000\057\000\058\000\038\000\000\000\
\062\000\045\000\000\000\000\000\004\000\067\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\016\000\003\000\
\004\000\005\000\006\000\007\000\008\000\009\000\010\000\011\000\
\012\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\012\000\000\000\012\000\012\000\012\000\012\000\
\012\000\012\000\012\000\012\000\012\000\012\000\013\000\000\000\
\013\000\013\000\013\000\013\000\013\000\013\000\013\000\013\000\
\013\000\013\000\009\000\009\000\009\000\009\000\009\000\009\000\
\009\000\009\000\009\000\009\000\006\000\006\000\006\000\006\000\
\006\000\006\000\006\000\006\000\006\000\006\000\010\000\010\000\
\010\000\010\000\010\000\010\000\010\000\010\000\010\000\010\000\
\004\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
\004\000\004\000\016\000\016\000\016\000\016\000\016\000\016\000\
\016\000\016\000\016\000\016\000"

let yycheck = "\032\000\
\000\000\004\000\005\000\002\001\007\000\001\001\001\001\001\001\
\001\000\001\001\000\000\002\001\000\000\002\001\003\001\017\001\
\001\001\050\000\017\001\015\001\015\001\015\001\000\000\015\001\
\002\001\028\000\029\000\030\000\061\000\001\001\033\000\001\001\
\000\000\001\001\016\001\016\001\014\001\016\001\002\001\016\001\
\002\001\017\001\000\000\046\000\047\000\048\000\000\000\255\255\
\051\000\025\000\255\255\255\255\000\000\056\000\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\000\000\004\001\
\005\001\006\001\007\001\008\001\009\001\010\001\011\001\012\001\
\013\001\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\002\001\255\255\004\001\005\001\006\001\007\001\
\008\001\009\001\010\001\011\001\012\001\013\001\002\001\255\255\
\004\001\005\001\006\001\007\001\008\001\009\001\010\001\011\001\
\012\001\013\001\004\001\005\001\006\001\007\001\008\001\009\001\
\010\001\011\001\012\001\013\001\004\001\005\001\006\001\007\001\
\008\001\009\001\010\001\011\001\012\001\013\001\004\001\005\001\
\006\001\007\001\008\001\009\001\010\001\011\001\012\001\013\001\
\004\001\005\001\006\001\007\001\008\001\009\001\010\001\011\001\
\012\001\013\001\004\001\005\001\006\001\007\001\008\001\009\001\
\010\001\011\001\012\001\013\001"

let yynames_const = "\
  EOF\000\
  VERTEX\000\
  UV\000\
  NORMAL\000\
  FACE\000\
  PARAM\000\
  USEMTL\000\
  MATLIB\000\
  OBJECT\000\
  GROUP\000\
  SMOOTH\000\
  OFF\000\
  LEFTBRACKET\000\
  RIGHTBRACKET\000\
  SLASH\000\
  "

let yynames_block = "\
  STRING\000\
  INT\000\
  FLOAT\000\
  "

let yyact = [|
  (fun _ -> failwith "parser")
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'obj_list) in
    Obj.repr(
# 15 "model/objParser.mly"
                (_1)
# 223 "model/objParser.ml"
               : ObjAST.t list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : int) in
    Obj.repr(
# 19 "model/objParser.mly"
       (float_of_int _1)
# 230 "model/objParser.ml"
               : 'float_lit))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : float) in
    Obj.repr(
# 20 "model/objParser.mly"
         (_1)
# 237 "model/objParser.ml"
               : 'float_lit))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'float_lit) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'float_lit) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'float_lit) in
    Obj.repr(
# 25 "model/objParser.mly"
    (ObjAST.Vertex OgamlMath.Vector3f.({x = _2; y = _3; z = _4}))
# 246 "model/objParser.ml"
               : 'vertex))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'float_lit) in
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'float_lit) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'float_lit) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'float_lit) in
    Obj.repr(
# 27 "model/objParser.mly"
    (ObjAST.Vertex OgamlMath.Vector3f.({x = _2; y = _3; z = _4}))
# 256 "model/objParser.ml"
               : 'vertex))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'float_lit) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'float_lit) in
    Obj.repr(
# 32 "model/objParser.mly"
    (ObjAST.UV OgamlMath.Vector2f.({x = _2; y = _3}))
# 264 "model/objParser.ml"
               : 'uv))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'float_lit) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'float_lit) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'float_lit) in
    Obj.repr(
# 34 "model/objParser.mly"
    (ObjAST.UV OgamlMath.Vector2f.({x = _2; y = _3}))
# 273 "model/objParser.ml"
               : 'uv))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'float_lit) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'float_lit) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'float_lit) in
    Obj.repr(
# 39 "model/objParser.mly"
    (ObjAST.Normal OgamlMath.Vector3f.({x = _2; y = _3; z = _4} |> normalize))
# 282 "model/objParser.ml"
               : 'normal))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'float_lit) in
    Obj.repr(
# 44 "model/objParser.mly"
    (ObjAST.Param)
# 289 "model/objParser.ml"
               : 'param))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'float_lit) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'float_lit) in
    Obj.repr(
# 46 "model/objParser.mly"
    (ObjAST.Param)
# 297 "model/objParser.ml"
               : 'param))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'float_lit) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'float_lit) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'float_lit) in
    Obj.repr(
# 48 "model/objParser.mly"
    (ObjAST.Param)
# 306 "model/objParser.ml"
               : 'param))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : int) in
    Obj.repr(
# 53 "model/objParser.mly"
    (OgamlMath.Vector3i.({x = _1; y = 0; z = 0}))
# 313 "model/objParser.ml"
               : 'triple))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : int) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : int) in
    Obj.repr(
# 55 "model/objParser.mly"
    (OgamlMath.Vector3i.({x = _1; y = _3; z = 0}))
# 321 "model/objParser.ml"
               : 'triple))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : int) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : int) in
    Obj.repr(
# 57 "model/objParser.mly"
    (OgamlMath.Vector3i.({x = _1; y = 0; z = _4}))
# 329 "model/objParser.ml"
               : 'triple))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 4 : int) in
    let _3 = (Parsing.peek_val __caml_parser_env 2 : int) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : int) in
    Obj.repr(
# 59 "model/objParser.mly"
    (OgamlMath.Vector3i.({x = _1; y = _3; z = _5}))
# 338 "model/objParser.ml"
               : 'triple))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'triple) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'triple) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'triple) in
    Obj.repr(
# 64 "model/objParser.mly"
    (ObjAST.Tri (_2,_3,_4))
# 347 "model/objParser.ml"
               : 'face))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'triple) in
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'triple) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'triple) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'triple) in
    Obj.repr(
# 66 "model/objParser.mly"
    (ObjAST.Quad (_2,_3,_4,_5))
# 357 "model/objParser.ml"
               : 'face))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 1 : string) in
    Obj.repr(
# 71 "model/objParser.mly"
    (ObjAST.Mtllib _3)
# 364 "model/objParser.ml"
               : 'mtllib))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 73 "model/objParser.mly"
    (ObjAST.Mtllib _2)
# 371 "model/objParser.ml"
               : 'mtllib))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 1 : string) in
    Obj.repr(
# 78 "model/objParser.mly"
    (ObjAST.Usemtl _3)
# 378 "model/objParser.ml"
               : 'usemtl))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 80 "model/objParser.mly"
    (ObjAST.Usemtl _2)
# 385 "model/objParser.ml"
               : 'usemtl))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 1 : string) in
    Obj.repr(
# 85 "model/objParser.mly"
    (ObjAST.Object _3)
# 392 "model/objParser.ml"
               : 'objct))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 87 "model/objParser.mly"
    (ObjAST.Object _2)
# 399 "model/objParser.ml"
               : 'objct))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 1 : string) in
    Obj.repr(
# 92 "model/objParser.mly"
    (ObjAST.Group _3)
# 406 "model/objParser.ml"
               : 'group))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 94 "model/objParser.mly"
    (ObjAST.Group _2)
# 413 "model/objParser.ml"
               : 'group))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : int) in
    Obj.repr(
# 99 "model/objParser.mly"
    (ObjAST.Smooth (Some _2))
# 420 "model/objParser.ml"
               : 'smooth))
; (fun __caml_parser_env ->
    Obj.repr(
# 101 "model/objParser.mly"
    (ObjAST.Smooth None)
# 426 "model/objParser.ml"
               : 'smooth))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'vertex) in
    Obj.repr(
# 105 "model/objParser.mly"
           (_1)
# 433 "model/objParser.ml"
               : 'obj_field))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'uv) in
    Obj.repr(
# 106 "model/objParser.mly"
           (_1)
# 440 "model/objParser.ml"
               : 'obj_field))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'normal) in
    Obj.repr(
# 107 "model/objParser.mly"
           (_1)
# 447 "model/objParser.ml"
               : 'obj_field))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'param) in
    Obj.repr(
# 108 "model/objParser.mly"
           (_1)
# 454 "model/objParser.ml"
               : 'obj_field))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'face) in
    Obj.repr(
# 109 "model/objParser.mly"
           (_1)
# 461 "model/objParser.ml"
               : 'obj_field))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'mtllib) in
    Obj.repr(
# 110 "model/objParser.mly"
           (_1)
# 468 "model/objParser.ml"
               : 'obj_field))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'usemtl) in
    Obj.repr(
# 111 "model/objParser.mly"
           (_1)
# 475 "model/objParser.ml"
               : 'obj_field))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'objct) in
    Obj.repr(
# 112 "model/objParser.mly"
           (_1)
# 482 "model/objParser.ml"
               : 'obj_field))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'group) in
    Obj.repr(
# 113 "model/objParser.mly"
           (_1)
# 489 "model/objParser.ml"
               : 'obj_field))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'smooth) in
    Obj.repr(
# 114 "model/objParser.mly"
           (_1)
# 496 "model/objParser.ml"
               : 'obj_field))
; (fun __caml_parser_env ->
    Obj.repr(
# 118 "model/objParser.mly"
    ([])
# 502 "model/objParser.ml"
               : 'obj_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'obj_field) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'obj_list) in
    Obj.repr(
# 119 "model/objParser.mly"
                       (_1 :: _2)
# 510 "model/objParser.ml"
               : 'obj_list))
(* Entry file *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
|]
let yytables =
  { Parsing.actions=yyact;
    Parsing.transl_const=yytransl_const;
    Parsing.transl_block=yytransl_block;
    Parsing.lhs=yylhs;
    Parsing.len=yylen;
    Parsing.defred=yydefred;
    Parsing.dgoto=yydgoto;
    Parsing.sindex=yysindex;
    Parsing.rindex=yyrindex;
    Parsing.gindex=yygindex;
    Parsing.tablesize=yytablesize;
    Parsing.table=yytable;
    Parsing.check=yycheck;
    Parsing.error_function=parse_error;
    Parsing.names_const=yynames_const;
    Parsing.names_block=yynames_block }
let file (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 1 lexfun lexbuf : ObjAST.t list)
