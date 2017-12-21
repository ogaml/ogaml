open OgamlUtils

let fail ?msg s = 
  Log.fatal Log.stdout "%s" s;
  begin match msg with
  | None -> ()
  | Some msg -> Log.fatal Log.stderr "%s" msg;
  end;
  exit 2

let (>>=) res f = 
  match res with
  | Ok r -> f r
  | Error e -> Error e

let assert_ok = function
  | Ok v -> v
  | Error e -> assert false

let handle_error f = function
  | Ok v -> v
  | Error e -> f e
