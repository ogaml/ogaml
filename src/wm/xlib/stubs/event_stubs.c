#include <X11/Xlib.h>
#include <X11/Xutil.h>
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


// Tests if an event happens in the right window
Bool checkEvent(Display* disp, XEvent* evt, XPointer window)
{
  return evt->xany.window == (Window)window;
}


// INPUT   display, window
// OUTPUT  a pointer on an event (if it exists) in the current window
CAMLprim value
caml_xnext_event(value disp, value win)
{
  CAMLparam1(disp);
  CAMLlocal1(evt);
  XEvent event;
  if(XCheckIfEvent((Display*) disp, &event, &checkEvent, (XPointer)win) == True) {
    evt = caml_alloc_custom(&empty_custom_opts, sizeof(XEvent), 0, 1);
    memcpy(Data_custom_val(evt), &event, sizeof(XEvent));
    CAMLreturn(Val_some(evt));
  }
  else
    CAMLreturn(Val_int(0));
}


// Extract the keysym out of an xkey event
KeySym extract_keysym(XEvent* evt)
{
  static XComposeStatus keyboard;
  char buffer[32];
  KeySym result;
  XEvent cpy = *evt;
    cpy.xkey.state &= (~ShiftMask) & (~ControlMask) & (~LockMask) & (~AnyModifier);
  XLookupString(&cpy.xkey, buffer, sizeof(buffer), &result, &keyboard);
  return result;
}


// Extract the event out of an XEvent structure
// Warning : event types begin at 2, and one needs to 
//           be careful about the parametric variants 
//           plus there is the Unknown type (0) in Ocaml
value extract_event(XEvent* evt)
{
  CAMLparam0();
  CAMLlocal3(result, position, modifiers);
  switch(evt->type) {

    case KeyPress         :     
      result = caml_alloc(2,0);  // 1st param. variant
      modifiers = caml_alloc(4,0);
        Store_field(modifiers, 0, Val_bool((evt->xkey.state & ShiftMask) != 0));
        Store_field(modifiers, 1, Val_bool((evt->xkey.state & ControlMask) != 0));
        Store_field(modifiers, 2, Val_bool((evt->xkey.state & LockMask) != 0));
        Store_field(modifiers, 3, Val_bool((evt->xkey.state & AnyModifier) != 0));
      Store_field(result, 0, Val_int(extract_keysym(evt)));
      Store_field(result, 1, modifiers);
      break;

    case KeyRelease       :
      result = caml_alloc(2,1);  // 2nd param. variant
      modifiers = caml_alloc(4,0);
        Store_field(modifiers, 0, Val_bool((evt->xkey.state & ShiftMask) != 0));
        Store_field(modifiers, 1, Val_bool((evt->xkey.state & ControlMask) != 0));
        Store_field(modifiers, 2, Val_bool((evt->xkey.state & LockMask) != 0));
        Store_field(modifiers, 3, Val_bool((evt->xkey.state & AnyModifier) != 0));
      Store_field(result, 0, Val_int(extract_keysym(evt)));
      Store_field(result, 1, modifiers);
      break;

    case ButtonPress      :
      result = caml_alloc(3,2);  // 3rd param. variant
      position = caml_alloc(2,0);
        Store_field(position, 0, Val_int(evt->xbutton.x));
        Store_field(position, 1, Val_int(evt->xbutton.y));
      modifiers = caml_alloc(4,0);
        Store_field(modifiers, 0, Val_bool((evt->xbutton.state & ShiftMask) != 0));
        Store_field(modifiers, 1, Val_bool((evt->xbutton.state & ControlMask) != 0));
        Store_field(modifiers, 2, Val_bool((evt->xbutton.state & LockMask) != 0));
        Store_field(modifiers, 3, Val_bool((evt->xbutton.state & AnyModifier) != 0));
      Store_field(result, 0, Val_int(evt->xbutton.button));
      Store_field(result, 1, position);
      Store_field(result, 2, modifiers);
      break;

    case ButtonRelease    :
      result = caml_alloc(3,3);  // 4th param. variant
      position = caml_alloc(2,0);
        Store_field(position, 0, Val_int(evt->xbutton.x));
        Store_field(position, 1, Val_int(evt->xbutton.y));
      modifiers = caml_alloc(4,0);
        Store_field(modifiers, 0, Val_bool((evt->xbutton.state & ShiftMask) != 0));
        Store_field(modifiers, 1, Val_bool((evt->xbutton.state & ControlMask) != 0));
        Store_field(modifiers, 2, Val_bool((evt->xbutton.state & LockMask) != 0));
        Store_field(modifiers, 3, Val_bool((evt->xbutton.state & AnyModifier) != 0));
      Store_field(result, 0, Val_int(evt->xbutton.button));
      Store_field(result, 1, position);
      Store_field(result, 2, modifiers);
      break;

    case MotionNotify     :
      result = caml_alloc(1,4); // 5th param. variant
      position = caml_alloc(2,0);
        Store_field(position, 0, Val_int(evt->xmotion.x));
        Store_field(position, 1, Val_int(evt->xmotion.y));
      Store_field(result, 0, position);
      break;

    case EnterNotify      :
    case LeaveNotify      :
    case FocusIn          :
    case FocusOut         :
    case KeymapNotify     :
    case Expose           :
    case GraphicsExpose   :
    case NoExpose         :
    case VisibilityNotify :
    case CreateNotify     :
    case DestroyNotify    :
    case UnmapNotify      :
    case MapNotify        :
    case MapRequest       :
    case ReparentNotify   :
    case ConfigureNotify  :
    case ConfigureRequest :
    case GravityNotify    :
    case ResizeRequest    :
    case CirculateNotify  :
    case CirculateRequest :
    case PropertyNotify   :
    case SelectionClear   :
    case SelectionRequest :
    case SelectionNotify  :
    case ColormapNotify   :
      result = Val_int(evt->type - 6);
      break;

    // ClientMessage : get the Atom (message_type)
    case ClientMessage: // 33, 6th parametric variant 
      result = caml_alloc(1,5);
      Store_field(result, 0, (value)evt->xclient.data.l[0]);
      break;

    case MappingNotify    :
    case GenericEvent     :
    case LASTEvent        :
      result = Val_int(evt->type - 7);
      break;
    
    default: 
      result = Val_int(0);
      break;
  }
  CAMLreturn(result);
}


// INPUT   a pointer on an event
// OUTPUT  the type of the event
CAMLprim value
caml_event_type(value evt)
{
  CAMLparam1(evt);
  CAMLlocal1(result);
  result = extract_event((XEvent*)Data_custom_val(evt));
  CAMLreturn(result);
}


