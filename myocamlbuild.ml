open Ocamlbuild_plugin
open Command

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


let add_cocoa_flags () =
  flag ["c"; "use_lcocoa"; "compile"]
    (S [A"-ccopt"; A"-framework Foundation -lobjc";]);

  flag ["c"; "use_lcocoa"; "ocamlmklib"] 
    (S [A"-ccopt"; A"-framework Foundation -lobjc";]);

  flag ["ocaml"; "use_lcocoa"; "link"; "library"] 
    (S [A"-cclib"; A"-framework Foundation -lobjc";]);

  ocaml_lib ~extern:true ~dir:"src/wm/cocoa" "cocoa";

  flag["link"; "library"; "ocaml"; "byte"; "use_libcocoa"]
    (S [A"-dllib"; A"-lcocoa"; A"-cclib"; A"-lcocoa"]);

  flag["link"; "library"; "ocaml"; "native"; "use_libcocoa"]
    (S [A"-cclib"; A"-lcocoa"]);

  dep ["link"; "ocaml"; "use_libcocoa"] ["src/wm/cocoa/cocoa.a"]


let _ = dispatch (function
  | After_rules ->
    add_xlib_flags ();
    add_cocoa_flags ()
  | _ -> ()
  )
