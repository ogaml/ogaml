open OgamlUtils

let fail ?err s = 
  Log.fatal Log.stdout "%s" s;
  begin match err with
  | None -> ()
  | Some err -> Log.fatal Log.stderr "%s" err;
  end;
  exit 2

let handle_window_creation = function
  | Ok win -> win
  | Error (`Context_initialization_error err) -> 
    fail ~err "Failed to create context" 
  | Error (`Window_creation_error err) -> 
    fail ~err "Failed to create window" 

let handle_program_creation = function
  | Ok prog -> prog
  | Error `Fragment_compilation_error err -> fail ~err "Failed to compile fragment shader"
  | Error `Vertex_compilation_error err -> fail ~err "Failed to compile vertex shader"
  | Error `Context_failure -> fail "GL context failure"
  | Error `Unsupported_GLSL_version -> fail "Unsupported GLSL version"
  | Error `Unsupported_GLSL_type -> fail "Unsupported GLSL type"
  | Error `Linking_failure -> fail "GLSL linking failure"

let assert_ok = function
  | Ok v -> v
  | Error _ -> assert false
