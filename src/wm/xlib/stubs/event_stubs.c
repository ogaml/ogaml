#include <X11/Xlib.h>
#include "../../../utils/stubs.h"
#include <memory.h>


// INPUT   display, window, mask list
// OUTPUT  nothing, updates the event mask of the window
CAMLprim value
caml_xselect_input(value disp, value win, value masks)
{
  CAMLparam3(disp, win, masks);
  CAMLlocal2(hd, tl);
  int mask = 0;
  tl = masks;
  while(tl != Val_emptylist) {
    hd = Field(tl,0);
    tl = Field(tl,1);
    mask |= (1L << (Int_val(hd)));
  }
  XSelectInput((Display*) disp, (Window) win, mask);
  CAMLreturn(Val_unit);
}


// Always return true, does not filter events
// Should definitely consider the window when we
// are able to create multiple windows on one display
Bool checkEvent()
{
  return True;
}


// INPUT   display
// OUTPUT  a pointer on an event (if it exists)
CAMLprim value
caml_xnext_event(value disp)
{
  CAMLparam1(disp);
  CAMLlocal1(evt);
  XEvent event;
  if(XCheckIfEvent((Display*) disp, &event, &checkEvent, NULL) == True) {
    evt = caml_alloc_custom(&empty_custom_opts, sizeof(XEvent), 0, 1);
    memcpy(Data_custom_val(evt), &event, sizeof(XEvent));
    CAMLreturn(Val_some(evt));
  }
  else
    CAMLreturn(Val_int(0));
}


// INPUT   a pointer on an event
// OUTPUT  the type of the event
CAMLprim value
caml_event_type(value evt)
{
  CAMLparam1(evt);
  // event types begin at 2...
  CAMLreturn(Val_int(((XEvent*)Data_custom_val(evt))->type - 2));
}


