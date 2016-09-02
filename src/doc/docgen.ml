open AST
open ASTpp

exception Error of string

let error fmt = Printf.ksprintf (fun s -> raise (Error s)) fmt

let rec extract_sigs = function
  | Documentation s :: Signature (name, mfl) :: t -> 
    let (sigs, ast) = extract_sigs t in
    ((pp name (Documentation s :: mfl)) :: sigs, ast)
  | Signature (name, mfl) :: t ->
    let (sigs, ast) = extract_sigs t in
    ((pp name (Documentation "" :: mfl)) :: sigs, ast)
  | h::t -> 
    let (sigs, ast) = extract_sigs t in
    (sigs, h::ast)
  | [] -> ([], [])

and extract_submodules = function
  | Documentation s :: Module (name, mfl) :: t -> 
    let (sigs, ast) = extract_submodules t in
    ((pp name (Documentation s :: mfl)) :: sigs, ast)
  | Module (name, mfl) :: t ->
    let (sigs, ast) = extract_submodules t in
    ((pp name (Documentation "" :: mfl)) :: sigs, ast)
  | h::t -> 
    let (sigs, ast) = extract_submodules t in
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
    | '.'
    | '_' -> token_related s (i+1)
    | _ -> i
  end

and token_comment s a i = 
  if i >= String.length s then 
    [PP_CommentString (String.sub s a (i-a))]
  else begin
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
  match s.[i] with
  | '*' -> remove_comment_end s (i-1)
  | _   -> i
 
and process_comment s = 
  let s = String.sub s 1 (String.length s - 2) in
  let j = remove_comment_end s (String.length s - 1) in
  let s = String.sub s 0 (j+1) in
  token_comment s 0 0
  |> List.map (function
               | PP_CommentString s -> PP_CommentString (strip_comment_begin s 0 0)
               | c -> c)
  |> List.filter (function
                  | PP_CommentString "" -> false
                  | c -> true)

and process_field field comment = 
  match field with
  | AbstractType (tp, s)      -> PP_Type (tp, s, None, comment)
  | ConcreteType (tp, s, exp) -> PP_Type (tp, s, Some exp, comment)
  | Value (s, exp) -> PP_Val (s, exp, comment)
  | Exn (s, exp)   -> PP_Exn (s, exp, comment)
  | Functor func   -> PP_Functor (func, comment)
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

and pp modulename ast : ASTpp.module_data = 
  let ast = List.filter (function Comment s -> false | _ -> true) ast in
  let signatures,ast  = extract_sigs ast in
  let submodules,ast  = extract_submodules ast in
  let description,ast = get_description ast in
  let contents = process_module ast in
  {modulename; description; submodules; signatures; contents}

