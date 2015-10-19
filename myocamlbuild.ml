open Ocamlbuild_plugin
open Command

(* OS *)
type sys_type = OSX | Linux

let sys =
  let ic = Unix.open_process_in "uname" in
  let uname = input_line ic in
  let () = close_in ic in
  if uname = "Linux" then Linux
  else if uname = "Darwin" then OSX
  else failwith "Unknown exploitation system"


(* Directories *)
let root_dir   = ".."

let utils_dir  = root_dir ^ "/src/utils"

let window_dir = root_dir ^ "/src/wm"

let xlib_dir   = window_dir ^ "/xlib"

let cocoa_dir  = window_dir ^ "/cocoa"

let stub_dir s = s ^ "/stubs"

let x11_dir = "/usr/include/X11"


(* Constants *)
let gnustep_flags = "-MMD -MP -DGNUSTEP -DGNUSTEP_BASE_LIBRARY=1 -DGNU_GUI_LIBRARY=1 -DGNU_RUNTIME=1 -DGNUSTEP_BASE_LIBRARY=1 -fno-strict-aliasing -fexceptions -fobjc-exceptions -D_NATIVE_OBJC_EXCEPTIONS -pthread -fPIC -Wall -DGSWARN -DGSDIAGNOSE -Wno-import -g -O2 -fgnu-runtime -fconstant-string-class=NSConstantString -I. -I/home/victor/GNUstep/Library/Headers -I/usr/local/include/GNUstep -I/usr/include/GNUstep"

let gnustep_libs = "-rdynamic -shared-libgcc -pthread -fexceptions -fgnu-runtime -L/home/victor/GNUstep/Library/Libraries -L/usr/local/lib -L/usr/lib -lgnustep-gui -lgnustep-base -lobjc -lm"

let lib_flags = "-framework Foundation -framework Cocoa -lobjc"


(* Utils *)
type options = 
  | Compiler of string
  | Include of string
  | Clib of string
  | Dlib of string
  | Other of string
  | ObjC
  | OtherOpt of string
  | OtherLib of string

let add_flags l opt = 
  flag l (S (List.flatten (List.map 
    (function
      |Compiler s-> [A "-cc"   ; A s]
      |Include s -> [A "-ccopt"; A ("-I"^s)]
      |Clib s    -> [A "-cclib"; A ("-l"^s )]
      |Dlib s    -> [A "-dllib"; A ("-l"^s )]
      |Other s   -> [A s]
      |ObjC      -> [A "-ccopt"; A "-x objective-c"]
      |OtherOpt s-> [A "-ccopt"; A s]
      |OtherLib s-> [A "-cclib"; A s]
    )
    opt
  )))


(* Default flags *)
let add_default_flags () = 
  add_flags 
    ["c"; "compile"; "utils"]
    [Include utils_dir]


(* Xlib flags (linux only) *)
let add_xlib_flags () =
  add_flags
    ["c"; "use_x11"; "compile"]
    [Include x11_dir;
     Include (stub_dir xlib_dir)];

  add_flags 
    ["c"; "use_x11"; "ocamlmklib"]
    [Other "-lX11"];

  add_flags 
    ["ocaml"; "use_x11"; "link"; "library"]
    [Clib "X11"];

  ocaml_lib ~extern:true ~dir:"src/wm/xlib" "xlib";

  add_flags
    ["link"; "library"; "ocaml"; "byte"; "use_libxlib"]
    [Dlib "xlib"; Clib "xlib"];

  add_flags
    ["link"; "library"; "ocaml"; "native"; "use_libxlib"]
    [Clib "xlib"];

  dep ["link"; "ocaml"; "use_libxlib"] ["src/wm/xlib/libxlib.a"]


(* Cocoa flags (linux part) *)
let add_gnu_cocoa_flags () =
  add_flags 
    ["c"; "use_lcocoa"; "compile"]
    [Compiler "clang";
     ObjC;
     OtherOpt gnustep_flags];

  add_flags 
    ["c"; "use_lcocoa"; "ocamlmklib"]
    [OtherOpt lib_flags];

  add_flags
    ["ocaml"; "use_lcocoa"; "link"; "library"]
    [OtherLib gnustep_libs]


(* Cocoa flags (osx part) *)
let add_osx_cocoa_flags () =
  add_flags 
    ["c"; "use_lcocoa"; "compile"]
    [ObjC;
     OtherOpt "-fconstant-string-class=NSConstantString";
     Include (stub_dir cocoa_dir)];

  add_flags 
    ["c"; "use_lcocoa"; "ocamlmklib"]
    [OtherOpt lib_flags];

  add_flags
    ["ocaml"; "use_lcocoa"; "link"; "library"]
    [OtherLib lib_flags]


(* Cocoa flags (common part) *)
let add_default_cocoa_flags () =
  ocaml_lib ~extern:true ~dir:"src/wm/cocoa" "cocoa";

  add_flags
    ["link"; "library"; "ocaml"; "byte"; "use_libcocoa"]
    [Dlib "cocoa";
     Clib "cocoa"];

  add_flags
    ["link"; "library"; "ocaml"; "native"; "use_libcocoa"]
    [Clib "cocoa"];

  dep ["link"; "ocaml"; "use_libcocoa"] ["src/wm/cocoa/libcocoa.a"]


(* Main *)
let _ = dispatch (function
  | After_rules when sys = Linux ->
    add_default_flags ();
    add_xlib_flags ();
    add_gnu_cocoa_flags ();
    add_default_cocoa_flags ()
  | After_rules when sys = OSX ->
    add_default_flags ();
    add_xlib_flags ();
    add_osx_cocoa_flags ();
    add_default_cocoa_flags ()
  | _ -> ()
  )
