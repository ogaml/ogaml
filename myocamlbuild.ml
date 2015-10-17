open Ocamlbuild_plugin
open Command

type sys_type = OSX | Linux

let sys = 
  let ic = Unix.open_process_in "uname" in
  let uname = input_line ic in
  let () = close_in ic in
  if uname = "Linux" then Linux
  else if uname = "Darwin" then OSX
  else failwith "Unknown exploitation system"


let add_xlib_flags () =
  flag ["c"; "use_x11"; "compile"]
    (S [A"-ccopt"; A"-I/usr/include/X11";]);

  flag ["c"; "use_x11"; "ocamlmklib"] 
    (S [A"-lX11";]);

  flag ["ocaml"; "use_x11"; "link"; "library"] 
    (S [A"-cclib"; A"-lX11";]);

  ocaml_lib ~extern:true ~dir:"src/wm/xlib" "xlib";

  flag["link"; "library"; "ocaml"; "byte"; "use_libxlib"]
    (S [A"-dllib"; A"-lxlib"; A"-cclib"; A"-lxlib"]);

  flag["link"; "library"; "ocaml"; "native"; "use_libxlib"]
    (S [A"-cclib"; A"-lxlib"]);

  dep ["link"; "ocaml"; "use_libxlib"] ["src/wm/xlib/libxlib.a"]


let add_gnu_cocoa_flags () =
  flag ["c"; "use_lcocoa"; "compile"] 
    (S [A"-ccopt"; A"-x objective-c -lobjc";
        A"-ccopt"; A"-I /usr/include/GNUstep/";
        A"-ccopt"; A"-fconstant-string-class=NSConstantString"]);

  flag ["c"; "use_lcocoa"; "ocamlmklib"] 
    (S [A"-ccopt"; A"-framework Foundation -lobjc";]);

  flag ["ocaml"; "use_lcocoa"; "link"; "library"] 
    (S [A"-cclib"; A"-lobjc -lgnustep-base";])


let add_osx_cocoa_flags () =
  flag ["c"; "use_lcocoa"; "compile"] 
    (S [A"-ccopt"; A"-x objective-c -lobjc";
        A"-ccopt"; A"-fconstant-string-class=NSConstantString"]);

  flag ["c"; "use_lcocoa"; "ocamlmklib"] 
    (S [A"-ccopt"; A"-framework Foundation -lobjc";]);

  flag ["ocaml"; "use_lcocoa"; "link"; "library"] 
    (S [A"-cclib"; A"-framework Foundation -lobjc";])


let add_default_cocoa_flags () =
  ocaml_lib ~extern:true ~dir:"src/wm/cocoa" "cocoa";

  flag["link"; "library"; "ocaml"; "byte"; "use_libcocoa"]
    (S [A"-dllib"; A"-lcocoa"; A"-cclib"; A"-lcocoa"]);

  flag["link"; "library"; "ocaml"; "native"; "use_libcocoa"]
    (S [A"-cclib"; A"-lcocoa"]);

  dep ["link"; "ocaml"; "use_libcocoa"] ["src/wm/cocoa/libcocoa.a"]


let _ = dispatch (function
  | After_rules when sys = Linux ->
    add_xlib_flags ();
    add_gnu_cocoa_flags ();
    add_default_cocoa_flags ()
  | After_rules when sys = OSX ->
    add_xlib_flags ();
    add_osx_cocoa_flags ();
    add_default_cocoa_flags ()
  | _ -> ()
  )
