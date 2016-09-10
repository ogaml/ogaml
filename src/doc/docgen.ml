
(** Ugly doc generation code.
  * Definitely not made to be reusable or pleasant to read.
  * You have been warned :o) *)

open AST
open ASTpp
open Lexing


exception Error of string

let error fmt = Printf.ksprintf (fun s -> raise (Error s)) fmt

let rec extract_sigs hierarchy curr = function
  | Documentation s :: Signature (name, mfl) :: t -> 
    let (sigs, ast) = extract_sigs hierarchy curr t in
    ((pp (hierarchy @ [curr]) name (Documentation s :: mfl)) :: sigs, ast)
  | Signature (name, mfl) :: t ->
    let (sigs, ast) = extract_sigs hierarchy curr t in
    ((pp (hierarchy @ [curr]) name (Documentation "" :: mfl)) :: sigs, ast)
  | h::t -> 
    let (sigs, ast) = extract_sigs hierarchy curr t in
    (sigs, h::ast)
  | [] -> ([], [])

and extract_submodules hierarchy curr = function
  | Documentation s :: Module (name, mfl) :: t -> 
    let (sigs, ast) = extract_submodules hierarchy curr t in
    ((pp (hierarchy @ [curr]) name (Documentation s :: mfl)) :: sigs, ast)
  | Module (name, mfl) :: t ->
    let (sigs, ast) = extract_submodules hierarchy curr t in
    ((pp (hierarchy @ [curr]) name (Documentation "" :: mfl)) :: sigs, ast)
  | h::t -> 
    let (sigs, ast) = extract_submodules hierarchy curr t in
    (sigs, h::ast)
  | [] -> ([], [])

and get_description = function
  | Documentation s :: t -> 
    (s,t)
  | Title s :: t -> 
    let (desc,l) = get_description t in
    (desc, Title s :: l)
  | l ->
    ("", l)

and token_inline s i = 
  if i >= String.length s then 
    error "Unterminated code inline";
  match s.[i] with
  | '$' -> i
  |  _  -> token_inline s (i+1)

and token_related s i = 
  if i >= String.length s then i
  else begin
    match s.[i] with
    | 'a'..'z' 
    | 'A'..'Z' 
    | '0'..'9'
    | '.'
    | '_' -> token_related s (i+1)
    | _ -> i
  end

and token_comment s a i = 
  if i >= String.length s then begin
    if a >= String.length s then []
    else [PP_CommentString (String.sub s a (i-a))]
  end else begin
    match s.[i] with
    | '$' -> 
      let str = String.sub s a (i-a) in
      let j = token_inline s (i+1) in
      (PP_CommentString str) ::
      (PP_Inline (String.sub s (i+1) (j-i-1)))::
      (token_comment s (j+1) (j+1))
    | '@' when s.[i+1] = 's' && s.[i+2] = 'e'  && s.[i+3] = 'e' && s.[i+4] = ':' ->
      let str = String.sub s a (i-a) in
      let j = token_related s (i+5) in
      (PP_CommentString str) ::
      (PP_Related (String.sub s (i+5) (j-i-5))) ::
      (token_comment s (j+1) (j+1))
    | '\n' ->
      let str = String.sub s a (i-a) in
      (PP_CommentString str) :: PP_EOL :: (token_comment s (i+1) (i+1))
    | _ -> token_comment s a (i+1)
  end

and strip_comment_begin s i k = 
  if i >= String.length s then ""
  else begin
    match s.[i] with
    | ' ' when k=0 -> strip_comment_begin s (i+1) 0
    | '*' when k<2 -> strip_comment_begin s (i+1) 1
    | ' ' when k<3 -> strip_comment_begin s (i+1) 2
    | _ -> String.sub s i (String.length s - i)
  end

and remove_comment_end s i = 
  if i < 0 then (-1)
  else begin
    match s.[i] with
    | '*' -> remove_comment_end s (i-1)
    | _   -> i
  end

and process_comment s = 
  let j = remove_comment_end s (String.length s - 1) in
  let s = String.sub s 0 (j+1) in
  token_comment s 0 0
  |> List.map (function
               | PP_CommentString s -> PP_CommentString (" " ^ (strip_comment_begin s 0 0))
               | c -> c)
  |> List.filter (function
                  | PP_CommentString s -> not (Str.string_match (Str.regexp " *$") s 0)
                  | c -> true)
  |> List.partition (function 
                     | PP_Related _ -> false
                     | _ -> true)
  |> fun (l1,l2) -> (l1 @ l2)

and process_field field comment = 
  match field with
  | AbstractType (tp, s)      -> 
    PP_Type ({tparam = tp; 
              tname = s; 
              texpr = None; 
              tmembers = []; 
              tenum = []}, comment)
  | ConcreteType (tp, s, exp) -> 
    PP_Type ({tparam = tp; 
              tname = s; 
              texpr = Some (process_expr exp); 
              tmembers = get_members exp; 
              tenum = get_enums exp}, comment)
  | Value (s, exp) -> 
    PP_Val (s, process_expr exp, comment)
  | Exn (s, Some exp)   -> 
    PP_Exn (s, Some (process_expr exp), comment)
  | Exn (s, None) ->
    PP_Exn (s, None, comment)
  | Functor func   -> 
    PP_Functor (process_functor func, comment)
  | _ -> assert false

and process_module = function
  | Documentation s :: Title s' :: t ->
    PP_Comment (process_comment s) :: PP_Title s' :: (process_module t)
  | Documentation s :: Documentation s' :: t ->
    PP_Comment (process_comment s) :: (process_module (Documentation s' :: t))
  | [Documentation s] ->
    [PP_Comment (process_comment s)]
  | Title s :: t ->
    PP_Title s :: (process_module t)
  | Documentation s :: h :: t ->
    process_field h (process_comment s) :: process_module t
  | h :: t ->
    process_field h [] :: process_module t
  | [] -> []

and process_expr = function
  | ModuleType (s, te) -> 
    PP_ModType (s, process_expr te)
  | AtomType s -> 
    PP_AtomType s
  | Record l -> 
    PP_Record (List.map (fun (mut,_,a,b) -> (mut, a, process_expr b)) l)
  | PolyVariant (v, sl) -> 
    PP_PolyVariant (v, List.map (fun (a,b) -> 
                                 match b with
                                 | None   -> (a, None)
                                 | Some v -> (a, Some (process_expr v))) sl)
  | PolyType s -> 
    PP_PolyType s
  | Arrow (te, te') -> 
    PP_Arrow (process_expr te, process_expr te')
  | TypeTuple tl -> 
    PP_TypeTuple (List.map process_expr tl)
  | NamedParam (s,e) ->
    PP_NamedParam (s, process_expr e)
  | OptionalParam (s,e) ->
    PP_OptionalParam (s, process_expr e)
  | Variant l ->
    PP_Variant (List.map (fun (_,a,b) -> 
                          match b with
                          | None   -> (a, None)
                          | Some v -> (a, Some (process_expr v))) l)
  | ParamType (l, e) ->
    PP_ParamType (List.map process_expr l, process_expr e)
  | FCModule (t, e) ->
    PP_FCModule (process_expr t, List.map (fun (s,e) -> (s,process_expr e)) e)

and get_members = function
  | Record l ->
    List.map (fun (mut, sopt, s, e) ->
      match sopt with
      | None   -> (mut, s, process_expr e, [])
      | Some c -> (mut, s, process_expr e, process_comment c)
    ) l
  | _ -> []

and get_enums = function
  | Variant l ->
    List.map (fun (sopt, s, e) ->
      let expr = 
        match e with
        | None -> None
        | Some e -> Some (process_expr e)
      in
      match sopt with
      | None   -> (s, expr, [])
      | Some c -> (s, expr, process_comment c)
    ) l
  | _ -> []

and process_functor {name; args; sign; constr} = 
  {
    fname = name;
    fargs = args;
    fsign = sign;
    fcons = List.map (fun (s,e) -> (s,process_expr e)) constr
  }

and pp hierarchy modulename ast : ASTpp.module_data = 
  let ast = List.filter (function Comment s -> false | _ -> true) ast in
  let signatures,ast  = extract_sigs hierarchy modulename ast in
  let submodules,ast  = extract_submodules hierarchy modulename ast in
  let signatures = List.rev signatures in
  let submodules = List.rev submodules in
  let description,ast = get_description ast in
  let description = process_comment description in
  let contents = process_module ast in
  {hierarchy; modulename; description; submodules; signatures; contents}

let preprocess modulename ast = pp [] modulename ast

let print_position lexbuf =
  let pos = lexbuf.lex_curr_p in
  let str = Lexing.lexeme lexbuf in
  let begchar = pos.pos_cnum - pos.pos_bol + 1 in
  Printf.sprintf "In %s, line %d, characters %d-%d : %s"
    pos.pos_fname pos.pos_lnum begchar
    (begchar + (String.length str))
    (Lexing.lexeme lexbuf)

let parse_with_errors lexbuf =
  try
    Parser.file Lexer.token lexbuf
  with
    |Lexer.SyntaxError msg ->
        error "%s : %s" (print_position lexbuf) msg
    |Parser.Error ->
        error "%s : Syntax Error" (print_position lexbuf)

let parse_from_file f = 
  let input = open_in f in
  let lexbuf = from_channel input in
  lexbuf.lex_curr_p <- {lexbuf.lex_curr_p with pos_fname = f};
  let ast = parse_with_errors lexbuf in
  close_in input;
  ast

let preprocess_file file = 
  let modulename = 
    let dot = String.rindex file '.' in
    let sls = String.rindex file '/' in
    String.sub file (sls+1) (dot-sls-1)
    |> String.capitalize
  in
  let ast = parse_from_file file in
  preprocess modulename ast


let rec comment_to_html root ppf comment =
  match comment with
  | [] -> ()
  | (PP_CommentString s)::t -> 
    Format.fprintf ppf "%s%a" s (comment_to_html root) t
  | (PP_Inline s)::t -> 
    Format.fprintf ppf "<code class=\"OCaml\">%s</code>%a" s (comment_to_html root) t
  | PP_EOL::PP_EOL::t -> 
    Format.fprintf ppf "<br>%a" (comment_to_html root) t
  | PP_EOL::t -> 
    Format.fprintf ppf "%a" (comment_to_html root) t
  | (PP_Related s)::t -> 
    let link = 
      String.lowercase s 
      |> Str.split (Str.regexp "\\.")
      |> String.concat "/"
    in
    Format.fprintf ppf "<br><span class=\"see\">See : <a href=\"%sdoc/%s.html\">%s</a></span>%a" 
      root link s (comment_to_html root) t

and comment_to_string root comment = 
  let ppf = Format.str_formatter in
  comment_to_html root ppf comment;
  Format.flush_str_formatter ()

and mk_value root ppf (s, expr, comment) = 
  Format.fprintf ppf 
  "<td class=\"variant\">
     <figure class=\"highlight\">
        <code class=\"OCaml\">%s%s%s</code>
     </figure>
  </td>
  <td>%a</td>" s (match expr with None -> "" | Some _ -> " of ")
                 (match expr with None -> "" | Some e -> type_expr_to_string e)
                 (comment_to_html root) comment

and mk_values root ppf = function
  | [] -> ()
  | h::t -> Format.fprintf ppf "<tr>@\n%a@\n</tr>@\n%a" 
              (mk_value root) h (mk_values root) t

and mk_value_table root ppf vtable =
  if vtable <> [] then 
    Format.fprintf ppf
    "<h4>Possible values</h4>
     @\n<table class=\"values\"></tbody>@\n@[<hov2>  %a@\n@]</tbody></table>" 
     (mk_values root) vtable

and mk_member root ppf (mut, s, expr, comment) = 
  Format.fprintf ppf 
  "<td class=\"record\">
     <figure class=\"highlight\">
        <code class=\"OCaml\">%s%s : %s</code>
     </figure>
  </td>
  <td>%a</td>" (if mut then "mutable " else "") 
               s (type_expr_to_string expr) (comment_to_html root) comment

and mk_members root ppf = function
  | [] -> ()
  | h::t -> Format.fprintf ppf "<tr>@\n%a@\n</tr>@\n%a" 
              (mk_member root) h (mk_members root) t

and mk_member_table root ppf (vtable : (bool * string * type_expr * comment) list) : unit =
  if vtable <> [] then 
    Format.fprintf ppf
    "<h4>Record fields</h4>
     @\n<table class=\"fields\"></tbody>@\n@[<hov2>  %a@\n@]</tbody></table>" 
     (mk_members root) vtable


and mk_entry : 'a 'b. Format.formatter -> string -> 
                     (Format.formatter -> 'a -> unit) -> 'a -> 
                     (Format.formatter -> 'b -> unit) -> 'b -> unit =
  fun ppf s f2 a2 f3 a3 ->
  Format.fprintf ppf
  "<article>
     <span class=\"arrow-right arrow\"></span>
     <span class=\"showmore\">
        <figure class=\"highlight\">
          <pre><code class=\"OCaml\">%s</code></pre>
        </figure>
     </span>
     <div class=\"more\">@\n@[<hov4>
       %a
     @]</div>
   </article>
   %a" s f2 a2 f3 a3

and mk_type_comment root ppf (comment, typedata) : unit = 
  let (c1, c2) = 
    List.partition (function 
                    | PP_Related _ -> false
                    | _ -> true) comment
  in
  Format.fprintf ppf "%a@\n%a@\n%a@\n%a" (comment_to_html root) c1
                                         (mk_value_table root) typedata.tenum
                                         (mk_member_table root) typedata.tmembers
                                         (comment_to_html root) c2
  

and module_to_html root ppf mdl = 
  match mdl with
  | [] -> ()
  | (PP_Title s)::t ->
    Format.fprintf ppf "<br><h3>%s</h3>@\n%a" s (module_to_html root) t
  | (PP_Comment c)::t ->
    Format.fprintf ppf "<p>%a</p>@\n%a" (comment_to_html root) c (module_to_html root) t
  | (PP_Type (typedata, comment))::t -> 
    let valtext = 
      match (typedata.tparam, typedata.texpr) with
      | None, None     -> 
        Printf.sprintf "type %s" typedata.tname
      | None, Some e   -> 
        Printf.sprintf "type %s = %s" typedata.tname (type_expr_to_string e)
      | Some p, None   ->
        Printf.sprintf "type %s %s" (type_params_to_string p) typedata.tname
      | Some p, Some e ->
        Printf.sprintf "type %s %s = %s" (type_params_to_string p) 
                                         typedata.tname
                                         (type_expr_to_string e)
    in
    mk_entry ppf valtext (mk_type_comment root) (comment,typedata) (module_to_html root) t
  | (PP_Val (s, expr, comment))::t ->
    let valtext = 
      Printf.sprintf "val %s : %s" s (type_expr_to_string expr)
    in
    mk_entry ppf valtext (comment_to_html root) comment (module_to_html root) t
  | (PP_Exn (s, Some expr, comment))::t ->
    let valtext = 
      Printf.sprintf "exception %s of %s" s (type_expr_to_string expr)
    in
    mk_entry ppf valtext (comment_to_html root) comment (module_to_html root) t
  | (PP_Exn (s, None, comment))::t ->
    let valtext = 
      Printf.sprintf "exception %s" s
    in
    mk_entry ppf valtext (comment_to_html root) comment (module_to_html root) t
  | (PP_Functor (fdata, comment))::t ->
    let funargs = 
      List.map (fun (s1,s2) -> Printf.sprintf "(%s : %s)" s1 s2) 
        fdata.fargs
      |> String.concat " "
    in
    let constraints = 
      List.map (fun (s,e) -> Printf.sprintf "%s = %s" s (type_expr_to_string e)) 
        fdata.fcons
      |> String.concat " and "
    in
    let valtext = 
      Printf.sprintf "module %s : functor %s -> %s%s%s"
        fdata.fname
        funargs
        fdata.fsign
        (if List.length fdata.fcons <> 0 then " with type " else "")
        constraints
    in
    mk_entry ppf valtext (comment_to_html root) comment (module_to_html root) t

and type_params_to_string = function
  | ParamTuple []  -> 
    ""
  | ParamTuple [t] -> 
    type_params_to_string t
  | ParamTuple l   -> 
    List.map type_params_to_string l
    |> String.concat ","
    |> Printf.sprintf "(%s)" 
  | Polymorphic s -> 
    "'" ^ s

and type_expr_to_string = function
  | PP_ModType (s,e) -> 
    Printf.sprintf "%s.%s" s (type_expr_to_string e)
  | PP_AtomType s ->
    s
  | PP_Record l ->
    List.map (fun (mut,s,e) -> 
      Printf.sprintf "%s%s : %s" 
        (if mut then "mutable " else "")
        s (type_expr_to_string e)) l
    |> String.concat "; "
    |> Printf.sprintf "{%s}"
  | PP_PolyVariant (v, l) ->
    List.map (function
              | (s,Some e) -> Printf.sprintf "`%s of %s" s (type_expr_to_string e)
              | (s,None)   -> Printf.sprintf "`%s" s) l
    |> String.concat " | "
    |> Printf.sprintf "[%s %s]" (variance_to_string v)
  | PP_PolyType s -> 
    Printf.sprintf "'%s" s
  | PP_Arrow (te1, te2) ->
    Printf.sprintf "%s -> %s" (type_expr_to_string_par te1) (type_expr_to_string te2)
  | PP_TypeTuple l ->
    List.map type_expr_to_string l
    |> String.concat " * "
    |> Printf.sprintf "(%s)"
  | PP_NamedParam (s,e) ->
    Printf.sprintf "%s:%s" s (type_expr_to_string e)
  | PP_OptionalParam (s,e) ->
    Printf.sprintf "?%s:%s" s (type_expr_to_string e)
  | PP_Variant l when List.length l <= 5 ->
    List.map (function
              | (s, Some e) -> Printf.sprintf "%s of %s" s (type_expr_to_string e)
              | (s, None)   -> Printf.sprintf "%s" s) l
    |> String.concat " | "
  | PP_Variant _ -> "..."
  | PP_ParamType ([e], t) ->
    Printf.sprintf "%s %s" (type_expr_to_string e) (type_expr_to_string t)
  | PP_ParamType (l, t) ->
    List.map type_expr_to_string l
    |> String.concat ", "
    |> (fun s -> Printf.sprintf "(%s) %s" s (type_expr_to_string t))
  | PP_FCModule (t, []) ->
    Printf.sprintf "(module %s)" (type_expr_to_string t)
  | PP_FCModule (t, l) ->
    let constraints = 
      List.map (fun (s,e) -> Printf.sprintf "%s = %s" s (type_expr_to_string e)) l
      |> String.concat " and "
    in
    Printf.sprintf "(module %s with type %s)" (type_expr_to_string t) constraints
    

and type_expr_to_string_par e = 
  match e with
  | PP_Arrow _ -> Printf.sprintf "(%s)" (type_expr_to_string e)
  | _ -> type_expr_to_string e

and variance_to_string = function
  | Lower -> "<"
  | Greater -> ">"
  | Equals -> ""

let highlight_init_code = 
  "hljs.tabReplace = ''; 
   hljs.initHighlightingOnLoad(); 
   window.onload = function() { 
     var aCodes = document.getElementsByTagName('code'); 
     for (var i=0; i < aCodes.length; i++) { 
       hljs.highlightBlock(aCodes[i]); 
     }
   }"

let gen_header root modulename = 
  Format.fprintf Format.str_formatter "<head>
      @\n@[<hov2>  <title>OGaml documentation - %s</title>
      @\n<meta charset=\"utf-8\">
      @\n<link href='https://fonts.googleapis.com/css?family=Open+Sans:300,400,700' rel='stylesheet' type='text/css'>
      @\n<link rel=\"stylesheet\" href=\"%scss/monokai.css\">
      @\n<link rel=\"stylesheet\" href=\"%scss/doc.css\">
      @\n<script src=\"%sscript/highlight.pack.js\"></script>
      @\n<script src=\"https://code.jquery.com/jquery-1.10.2.js\"></script>
      @\n<script src=\"%sscript/doc.js\"></script>
      @\n<script type=\"text/javascript\">%s</script>
      @\n<link rel=\"shortcut icon\" type=\"image/x-icon\" href=\"%simg/favicon-ogaml.ico\">
      @]@\n</head>"
    modulename root root root root highlight_init_code root;
  Format.flush_str_formatter ()

let gen_main_pp ppf modl root = 
  let hierarchy = 
    if modl.hierarchy = [] then ""
    else begin
      String.concat "." modl.hierarchy
      |> Printf.sprintf "%s."
    end
  in
  let print_headmodule ppf = 
    Format.fprintf ppf "<h1>Module <span class=\"prefix\">%s</span><span class=\"modulename\">%s</span></h1>
    @\n<span class=\"abstract\">%a</span>@\n<hr>"
      hierarchy modl.modulename (comment_to_html root) modl.description
  in
  let rec print_submodules_aux ppf = function
    | []   -> ()
    | h::t -> 
      let link = h.hierarchy @ [h.modulename] |> String.concat "/" |> String.lowercase in
      Format.fprintf ppf "<tr><td><a href=\"%sdoc/%s.html\">%s</a></td><td>%a</td></tr>@\n%a"
        root link h.modulename (comment_to_html root) h.description print_submodules_aux t
  in
  let print_submodules ppf = 
    if modl.submodules <> [] then 
      Format.fprintf ppf "<h2>Submodules</h2>
      @\n<table class=\"belowh\">
      @\n@[<hov2>  <tbody>@\n@[<hov2>  %a@]
      @\n</tbody>@]@\n</table>"
      print_submodules_aux modl.submodules
    else ()
  in
  let print_signatures ppf = 
    if modl.signatures <> [] then 
      Format.fprintf ppf "<h2>Signatures</h2>
      @\n<table class=\"belowh\">
      @\n@[<hov2>  <tbody>@\n@[<hov2>  %a@]
      @\n</tbody>@]@\n</table>"
      print_submodules_aux modl.signatures
    else ()
  in
  Format.fprintf ppf "<main>@\n@[<hov2>  %t@\n%t@\n%t@\n%a@]@\n</main>"
    print_headmodule
    print_submodules
    print_signatures
    (module_to_html root) modl.contents

let gen_main root modl = 
  let ppf = Format.str_formatter in
  gen_main_pp ppf modl root;
  Format.flush_str_formatter ()

let gen_index_entry root modl = 
  let link = modl.ASTpp.modulename |> String.lowercase in
  let comm = comment_to_string root modl.ASTpp.description in
  Printf.sprintf "<li>\n\t<p>\n\t\t<a href=\"%s.html\">%s</a>\n\t%s\n\t</p>\n</li>"
    link modl.ASTpp.modulename comm

let gen_index_modules root modules =
  List.map (gen_index_entry root) modules
  |> String.concat "\n"
  |> Printf.sprintf "<ul>\n%s\n</ul>\n"

let gen_index_main root modules example =
  let expl = open_in_bin example in
  let n = in_channel_length expl in
  let s = Bytes.create n in
  really_input expl s 0 n;
  close_in expl;
  Printf.sprintf 
    "<main>
     <h1>Welcome on the documentation of OGaml !</h1>\n
     <h2>Main modules</h2>\n
     %s
     <h2>Example (triangle)</h2>\n
     <figure class=\"highlight\">
       <pre>
         <code class=\"OCaml\">%s</code>
       </pre>
     </figure>
     </main>" (gen_index_modules root modules) s

let aside_header root = 
  Printf.sprintf
  "<header>
    <a href=\"%sindex.html\">
      <img src=\"%simg/ogaml-logo.svg\" alt=\"OGAML\" width=\"100%%\">
    </a>
  </header>" root root

let rec tree_mem cur mdl = 
  cur = mdl || (List.exists (tree_mem cur) mdl.signatures)
            || (List.exists (tree_mem cur) mdl.submodules)

let rec gen_aside_module root curr mdl = 
  let link = mdl.hierarchy @ [mdl.modulename] 
             |> String.concat "/" 
             |> String.lowercase in
  Printf.sprintf 
  "<li>
    <span class=\"arrow-right arrow shownav\"></span>
    <a href=\"%sdoc/%s.html\">%s</a>
    <ul %s>
      %s
      %s
    </ul>
  </li>"
  root link mdl.modulename
  (match curr with
   | Some curr when tree_mem curr mdl ->
      "class=\"nav-open\" style=\"display: block;\""
   | _ ->
    "style=\"display: none;\"")
  (gen_aside_modules root curr mdl.signatures)
  (gen_aside_modules root curr mdl.submodules)

and gen_aside_modules root curr modules = 
  List.map (gen_aside_module root curr) modules
  |> String.concat "\n"

let gen_aside root curr modules = 
  Printf.sprintf
  "<aside>
    %s
    <h1> 
      <a href=\"%sdoc/doc.html\">Modules</a>
      <span class=\"showall\">Show all</span>
    </h1>
    <ul id=\"main-nav\" style=\"display: block;\">
      %s
    </ul>
   </aside>" 
  (aside_header root) root (gen_aside_modules root curr modules)


