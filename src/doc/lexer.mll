{
  open Parser

  exception SyntaxError of string

  let h_add k e t = Hashtbl.add t k e; t

  let keywords_table =
    Hashtbl.create 19 
    |> h_add "module"   MODULE
    |> h_add "val"      VAL
    |> h_add "type"     TYPE
    |> h_add "end"      END
    |> h_add "sig"      SIG
    |> h_add "exception"EXN
    |> h_add "of"       OF
    |> h_add "with"     WITH
    |> h_add "functor"  FUNCTOR
    |> h_add "and"      AND

}

let newline = ('\013' * '\010')

let blank = [' ' '\009' '\012']

let integers = ['0'-'9']

let lowercase = ['a'-'z']

let uppercase  = ['A'-'Z']

let identchar = ['A'-'Z' 'a'-'z' '_' '0'-'9']

let symbolchar = ['>' '<' '=' '*' '+' '-' '/' '&' '|' '!']

rule token = parse
  | blank +
    {token lexbuf}
  | newline
    {Lexing.new_line lexbuf; token lexbuf}
  | eof
    {EOF}
  | lowercase identchar *
    {try Hashtbl.find keywords_table (Lexing.lexeme lexbuf)
     with Not_found -> LIDENT (Lexing.lexeme lexbuf)}
  | uppercase identchar *
    {try Hashtbl.find keywords_table (Lexing.lexeme lexbuf)
     with Not_found -> UIDENT (Lexing.lexeme lexbuf)}
  | '(' symbolchar * ')' {OPERATOR (Lexing.lexeme lexbuf)}
  | "(*"   {COMMENT (read_comment (Buffer.create 13) lexbuf)}
  | "(**"  {DOCCOMMENT (read_comment (Buffer.create 13) lexbuf)}
  | "(***" {TITLECOMMENT (read_comment (Buffer.create 13) lexbuf)}
  | "'"  {APOSTROPHE}
  | "`"  {QUOTE}
  | "?"  {QMARK}
  | "("  {LPAREN}
  | ")"  {RPAREN}
  | "*"  {STAR}
  | ":"  {COLON}
  | ","  {COMMA}
  | ";"  {SEMICOLON}
  | "="  {EQUALS}
  | "{"  {LBRACE}
  | "}"  {RBRACE}
  | "["  {LBRACK}
  | "]"  {RBRACK}
  | "|"  {PIPE}
  | "."  {DOT}
  | "->" {ARROW}
  | "<"  {LOWER}
  | ">"  {GREATER}
  | _  {raise (SyntaxError ("Syntax Error, unknown char."))}

and read_comment buf = parse
  | "*)"      { Buffer.contents buf }
  | newline   { Lexing.new_line lexbuf; 
                Buffer.add_char buf '\n'; 
                read_comment buf lexbuf }
  | '*'  
    { 
      Buffer.add_char buf '*'; 
      read_comment buf lexbuf 
    }
  | [^ '*' '\r' '\n']+
    { 
      Buffer.add_string buf (Lexing.lexeme lexbuf);
      read_comment buf lexbuf
    }
  | eof { raise (SyntaxError ("Comment not terminated")) }
  | _   { assert false }


