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

val file :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> ObjAST.t list
