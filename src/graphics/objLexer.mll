{
  open ObjParser

  exception SyntaxError of string

  let h_add k e t = Hashtbl.add t k e; t

  let keywords_table =
    Hashtbl.create 19 
    |> h_add "v"   VERTEX
    |> h_add "vt"  UV
    |> h_add "vn"  NORMAL
    |> h_add "vp"  PARAM
    |> h_add "f"   FACE
    |> h_add "off" OFF
    |> h_add "usemtl"  USEMTL
    |> h_add "mtllib"  MATLIB
    |> h_add "o"       OBJECT
    |> h_add "g"       GROUP
    |> h_add "s"       SMOOTH

}

let newline = ('\013'* '\010')
let blank = [' ' '\009' '\012']
let lowercase = ['a'-'z' '_']
let uppercase = ['A'-'Z']
let firstchar = ['A'-'Z' 'a'-'z' '_' '\'']
let identchar = ['A'-'Z' 'a'-'z' '_' '\'' '0'-'9' '.']
let lowercase_latin1 = ['a'-'z' '\223'-'\246' '\248'-'\255' '_']
let uppercase_latin1 = ['A'-'Z' '\192'-'\214' '\216'-'\222']
let identchar_latin1 =
  ['A'-'Z' 'a'-'z' '_' '\192'-'\214' '\216'-'\246' '\248'-'\255' '\'' '0'-'9']
let symbolchar =
  ['!' '$' '%' '&' '*' '+' '-' '.' '/' ':' '<' '=' '>' '?' '@' '^' '|' '~']
let decimal_literal =
  ['-']? ['0'-'9'] ['0'-'9' '_']*
let hex_literal =
  '0' ['x' 'X'] ['0'-'9' 'A'-'F' 'a'-'f']['0'-'9' 'A'-'F' 'a'-'f' '_']*
let oct_literal =
  '0' ['o' 'O'] ['0'-'7'] ['0'-'7' '_']*
let bin_literal =
  '0' ['b' 'B'] ['0'-'1'] ['0'-'1' '_']*
let int_literal =
  decimal_literal | hex_literal | oct_literal | bin_literal
let float_literal =
  ['-']? ['0'-'9'] ['0'-'9' '_']*
  ('.' ['0'-'9' '_']* )?
  (['e' 'E'] ['+' '-']? ['0'-'9'] ['0'-'9' '_']* )?

rule token = parse
  | blank +
    {token lexbuf}
  | newline
    {Lexing.new_line lexbuf; token lexbuf}
  | eof
    {EOF}
  | firstchar identchar *
    {try Hashtbl.find keywords_table (Lexing.lexeme lexbuf)
     with Not_found -> STRING (Lexing.lexeme lexbuf)}
  | int_literal 
    {INT (int_of_string (Lexing.lexeme lexbuf))}
  | float_literal 
    {FLOAT (float_of_string (Lexing.lexeme lexbuf))}
  | "[" 
    {LEFTBRACKET}
  | "]" 
    {RIGHTBRACKET}
  | "/" 
    {SLASH}
  | "#" [ ^ '\r' '\n']* newline
    {Lexing.new_line lexbuf; token lexbuf}
  | _  {raise (SyntaxError ("Syntax Error, unknown char."))}



