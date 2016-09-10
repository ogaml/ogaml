
(* The type of tokens. *)

type token = 
  | VERTEX
  | UV
  | USEMTL
  | STRING of (string)
  | SMOOTH
  | SLASH
  | RIGHTBRACKET
  | PARAM
  | OFF
  | OBJECT
  | NORMAL
  | MATLIB
  | LEFTBRACKET
  | INT of (int)
  | GROUP
  | FLOAT of (float)
  | FACE
  | EOF

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val file: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (ObjAST.t list)
