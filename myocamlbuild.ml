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




let _ = dispatch (function
  | After_rules ->
    add_xlib_flags ()
  | _ -> ()
  )
