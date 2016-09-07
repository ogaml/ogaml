open Html
open Docgen

let index =
  html
    (head ~title:"OGaml library" ())
    (body
      (h1 (text "OGAML") close)
      (h2 (text "A powerful OCaml multimedia library") close)
      (p 
        (text "Check out the ")
        (a ~href:"doc/doc.html"
          (text "documentation")
        close)
        (text " for more information about the modules of OGaml")
      close)
      (p
        (text "If you want to contribute or just see the sources of OGaml, check out our ")
        (a ~href:"https://github.com/ogaml/ogaml"
          (text "Github repository")
        close)
        (text ". This very website is also ")
        (a ~href:"https://github.com/ogaml/ogaml.github.io"
          (text "available on Github")
        close)
      close)
    body_end)

let rec comment_to_string = function
  | [] -> ""
  | ASTpp.PP_CommentString s :: t -> s ^ (comment_to_string t)
  | ASTpp.PP_EOL :: t -> " " ^ (comment_to_string t)
  | _ :: t -> comment_to_string t

let mk_entry modl = 
  let link = modl.ASTpp.modulename |> String.lowercase in
  let comm = comment_to_string modl.ASTpp.description in
  li
    (p
      (a ~href:(link ^ ".html") (text modl.ASTpp.modulename) close)
      (text comm)
    close)
  close

let mk_modules modules =
  let rec mk_aux cont = function
    | []   -> cont 
    | h::t -> mk_aux (cont (mk_entry h)) t
  in
  mk_aux ul modules

let welcome (modules : ASTpp.module_data list) =
  html
    (head ~title:"OGaml documentation" ())
    (body
      (main
        (h1 (text "Welcome on the documentation of OGaml") close)
        (h2 (text "Main modules") close)
        (Obj.magic (mk_modules modules) close)
      close)
    body_end)

let () = 
  if Array.length Sys.argv < 1 then begin
    print_endline "Usage : ./mkdoc <file1.mli> ... <fileN.mli>";
    exit 2
  end;
  if not (Sys.file_exists "html") then 
    Unix.mkdir "html" 0o777;
  let modules = 
    Array.to_list Sys.argv
    |> List.tl
    |> List.map (Docgen.preprocess_file)
  in
  List.iter (Docgen.gen "html/doc") modules;
  let output = open_out "html/index.html" in
  output_string output (export index);
  close_out output;
  let output = open_out "html/doc/doc.html" in
  output_string output (export (welcome modules));
  close_out output
