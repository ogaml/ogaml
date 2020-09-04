open Docgen

let copy src dest = 
  let command = Printf.sprintf "cp %s %s" src dest in
  if not (Sys.file_exists dest) then
    Unix.system command |> ignore

let rec relative_root = function
  | 0 -> ""
  | n -> "../" ^ (relative_root (n-1))

let gen_relative directory modules =
  let open ASTpp in
  let rec gen_aux directory modl =
    let dir = Unix.getcwd () in
    if not (Sys.file_exists directory) then 
      Unix.mkdir directory 0o777;
    Unix.chdir directory;
    let output = open_out (String.lowercase_ascii modl.modulename ^ ".html") in
    Printf.fprintf output "<!DOCTYPE html>\n<html>\n%s\n<body>%s\n%s</body>\n</html>"
      (Docgen.gen_header (relative_root (List.length modl.hierarchy + 1)) modl.modulename)
      (Docgen.gen_aside (relative_root (List.length modl.hierarchy + 1)) (Some modl) modules)
      (Docgen.gen_main (relative_root (List.length modl.hierarchy + 1)) modl);
    close_out output;
    List.iter (fun modl' -> gen_aux (String.lowercase_ascii modl.modulename) modl')
      modl.submodules;
    List.iter (fun modl' -> gen_aux (String.lowercase_ascii modl.modulename) modl')
      modl.signatures;
    Unix.chdir dir
  in
  List.iter (gen_aux directory) modules

let () = 
  if Array.length Sys.argv < 1 then begin
    print_endline "Usage : ./mkdoc <file1.mli> ... <fileN.mli>";
    exit 2
  end;
  if not (Sys.file_exists "html") then 
    Unix.mkdir "html" 0o777;
  if not (Sys.file_exists "html/css") then 
    Unix.mkdir "html/css" 0o777;
  if not (Sys.file_exists "html/script") then 
    Unix.mkdir "html/script" 0o777;
  if not (Sys.file_exists "html/img") then 
    Unix.mkdir "html/img" 0o777;
  let modules = 
    Array.to_list Sys.argv
    |> List.tl
    |> List.map (Docgen.preprocess_file)
  in
  gen_relative "html/doc" modules;
  let output = open_out "html/doc/doc.html" in
  Printf.fprintf output "<!DOCTYPE html>\n<html>\n%s\n<body>%s\n%s</body>\n</html>"
    (Docgen.gen_header "../" "Index")
    (Docgen.gen_aside "../" None modules)
    (Docgen.gen_index_main "../" modules "examples/tut02.ml");
  close_out output;
  copy "src/doc/index.html" "html/index.html";
  copy "src/doc/doc.css" "html/css/doc.css";
  copy "src/doc/highlight.pack.js" "html/script/highlight.pack.js";
  copy "src/doc/doc.js" "html/script/doc.js";
  copy "src/doc/monokai.css" "html/css/monokai.css";
  copy "src/doc/home.css" "html/css/home.css";
  copy "src/doc/favicon-ogaml.ico" "html/img/favicon-ogaml.ico";
  copy "src/doc/ogaml-logo.svg" "html/img/ogaml-logo.svg";
