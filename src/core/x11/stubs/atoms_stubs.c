#include <X11/Xlib.h>
#include <X11/Xatom.h>
#include "utils.h"

// Global atoms
CAMLprim value
caml_wm_add(value unit)
{
  CAMLparam0();
  CAMLreturn((Atom) 1);
}

CAMLprim value
caml_wm_remove(value unit)
{
  CAMLparam0();
  CAMLreturn((Atom) 0);
}

CAMLprim value
caml_wm_toggle(value unit)
{
  CAMLparam0();
  CAMLreturn((Atom) 2);
}


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
    tmp[i] = (Atom) Field(atoms, i);
  }
  XSetWMProtocols((Display*) disp, (Window) win, tmp, Int_val(size));
  CAMLreturn(Val_unit);
}


// INPUT   display, window, atom property, atom array, length
// OUTPUT  nothing applies the properties
CAMLprim value
caml_xchange_property(value disp, value win, value prop, value atoms, value length)
{
  CAMLparam5(disp, win, prop, atoms, length);
  Atom tmp[Int_val(length)+1];
  int i = 0;
  for(i = 0; i < Int_val(length); i++) {
    tmp[i] = (Atom) Field(atoms, i);
  }
  tmp[Int_val(length)] = None;
  XChangeProperty((Display*) disp, (Window) win, (Atom) prop, XA_ATOM, 32, PropModeReplace, (unsigned char*) tmp, Int_val(length));
  CAMLreturn(Val_unit);
}


// INPUT   display, window, property, data, length
// OUTPUT  nothing, sends an event
CAMLprim value
caml_xsend_event(value disp, value win, value prop, value atoms, value length)
{
  CAMLparam5(disp, win, prop, atoms, length);
  XEvent xev;
  int i = 0;
  for(i = 0; i < Int_val(length); i++) {
    xev.xclient.data.l[i] = (Atom) Field(atoms, i);
  }
    xev.xclient.data.l[Int_val(length)] = None;
    xev.xclient.type = ClientMessage;
    xev.xclient.serial = 0;
    xev.xclient.send_event = True;
    xev.xclient.window = (Window) win;
    xev.xclient.message_type = (Atom) prop;
    xev.xclient.format = 32;
  XSendEvent((Display*) disp, DefaultRootWindow((Display*) disp), False, SubstructureRedirectMask | SubstructureNotifyMask, &xev);
  CAMLreturn(Val_unit);
}
