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


let gnustep_flags = "-MMD -MP -DGNUSTEP -DGNUSTEP_BASE_LIBRARY=1 -DGNU_GUI_LIBRARY=1 -DGNU_RUNTIME=1 -DGNUSTEP_BASE_LIBRARY=1 -fno-strict-aliasing -fexceptions -fobjc-exceptions -D_NATIVE_OBJC_EXCEPTIONS -pthread -fPIC -Wall -DGSWARN -DGSDIAGNOSE -Wno-import -g -O2 -fgnu-runtime -fconstant-string-class=NSConstantString -I. -I/home/victor/GNUstep/Library/Headers -I/usr/local/include/GNUstep -I/usr/include/GNUstep"

let gnustep_libs = "-rdynamic -shared-libgcc -pthread -fexceptions -fgnu-runtime -L/home/victor/GNUstep/Library/Libraries -L/usr/local/lib -L/usr/lib -lgnustep-gui -lgnustep-base -lobjc -lm"

let lib_flags = "-framework Foundation -framework Cocoa -lobjc"


let add_gnu_cocoa_flags () =
  flag ["c"; "use_lcocoa"; "compile"] 
    (S [A"-ccopt"; A"-x objective-c";
        A"-ccopt"; A gnustep_flags]);

  flag ["c"; "use_lcocoa"; "ocamlmklib"] 
    (S [A"-ccopt"; A lib_flags;]);

  flag ["ocaml"; "use_lcocoa"; "link"; "library"] 
    (S [A"-cclib"; A gnustep_libs])


let add_osx_cocoa_flags () =
  flag ["c"; "use_lcocoa"; "compile"] 
    (S [A"-ccopt"; A"-x objective-c";
        A"-ccopt"; A"-fconstant-string-class=NSConstantString"]);

  flag ["c"; "use_lcocoa"; "ocamlmklib"] 
    (S [A"-ccopt"; A lib_flags;]);

  flag ["ocaml"; "use_lcocoa"; "link"; "library"] 
    (S [A"-cclib"; A lib_flags;])


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


