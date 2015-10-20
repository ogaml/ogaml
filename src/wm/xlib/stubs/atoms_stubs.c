#include <X11/Xlib.h>
#include "../../../utils/stubs.h"


// INPUT   display, atom name, boolean
// OUTPUT  returns an atom option, 
//         creates the corresponding atom if the boolean is false 
CAMLprim value
caml_xintern_atom(value disp, value nm, value exists)
{
  CAMLparam3(disp, nm, exists);
  Atom tmp = XInternAtom((Display*) disp, String_val(nm), Bool_val(exists));
  if(tmp == None)
    CAMLreturn(Val_int(0));
  else
    CAMLreturn(Val_some((value)tmp));
}


// INPUT   display, window, atom array, length
// OUTPUT  nothing, applies the atoms to the window
CAMLprim value
caml_xset_wm_protocols(value disp, value win, value atoms, value size)
{
  CAMLparam4(disp, win, atoms, size);
  Atom tmp[Int_val(size)];
  int i = 0;
  for(i = 0; i < Int_val(size); i++) {
    tmp[i] = (Atom) Field(atoms, 0);
  }
  XSetWMProtocols((Display*) disp, (Window) win, tmp, Int_val(size));
  CAMLreturn(Val_unit);
}


