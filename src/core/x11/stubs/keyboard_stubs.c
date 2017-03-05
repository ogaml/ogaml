#include <X11/Xlib.h>
#include <xcb/xcb.h>
#include <X11/Xlib-xcb.h>
#include <X11/keysym.h>
#include "utils.h"

CAMLprim value
caml_is_key_down(value disp, value code)
{
  CAMLparam2(disp, code);

  Display* dpy = Display_val(disp);

  xcb_generic_error_t* error = NULL;

  xcb_connection_t* conn = XGetXCBConnection(dpy);

  xcb_query_keymap_reply_t* keymap = 
    xcb_query_keymap_reply(conn,
                           xcb_query_keymap(conn),
                           &error);

  xcb_keycode_t sym;


  if(Tag_val(code) == 0) {
    sym = Int_val(Field(code,0));
  } else {
    int val = Int_val(Field(code,0));
    char str[2] = {val, '\0'};
    int ks = XStringToKeysym(str);
    sym = XKeysymToKeycode(dpy, ks);
  }

  CAMLreturn(Val_bool((keymap->keys[sym / 8] & (1 << (sym % 8))) != 0));
}

