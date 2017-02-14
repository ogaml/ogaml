#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include "utils.h"
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


// Extract the key out of an xkey event
value extract_keysym(XEvent* evt)
{
  CAMLparam0();
  CAMLlocal1(key);
  
  static XComposeStatus keyboard;
  char buffer[32];
  KeySym result;
  XEvent cpy = *evt;
    cpy.xkey.state &= (~ShiftMask) & (~ControlMask) & (~LockMask) & (~AnyModifier);
  
  if(XLookupString(&cpy.xkey, buffer, sizeof(buffer), &result, &keyboard)) {
    if(buffer[0] >= 97 && buffer[0] <= 122) {
      key = caml_alloc(1,1);
      Store_field(key, 0, Val_int(buffer[0]));
    }
    else {
      key = caml_alloc(1,0);
      Store_field(key, 0, Val_int(evt->xkey.keycode));
    }
  }
  else {
    key = caml_alloc(1,0);
    Store_field(key, 0, Val_int(evt->xkey.keycode));
  }
  CAMLreturn(key);
}


// Extract the character code out of an xkey event
int extract_char(XEvent* evt)
{
  static XComposeStatus keyboard;
  char buffer[32];
  KeySym result;

  if(XLookupString(&evt->xkey, buffer, sizeof(buffer), &result, &keyboard)) {
    return buffer[0];
  }
  
  return -1;
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
      result = caml_alloc(3,0);  // 1st param. variant
      modifiers = caml_alloc(4,0);
        Store_field(modifiers, 0, Val_bool((evt->xkey.state & ShiftMask) != 0));
        Store_field(modifiers, 1, Val_bool((evt->xkey.state & ControlMask) != 0));
        Store_field(modifiers, 2, Val_bool((evt->xkey.state & LockMask) != 0));
        Store_field(modifiers, 3, Val_bool((evt->xkey.state & Mod1Mask) != 0));
      Store_field(result, 0, extract_keysym(evt));
      Store_field(result, 1, Val_int(extract_char(evt)));
      Store_field(result, 2, modifiers);
      break;

    case KeyRelease       :
      result = caml_alloc(2,1);  // 2nd param. variant
      modifiers = caml_alloc(4,0);
        Store_field(modifiers, 0, Val_bool((evt->xkey.state & ShiftMask) != 0));
        Store_field(modifiers, 1, Val_bool((evt->xkey.state & ControlMask) != 0));
        Store_field(modifiers, 2, Val_bool((evt->xkey.state & LockMask) != 0));
        Store_field(modifiers, 3, Val_bool((evt->xkey.state & Mod1Mask) != 0));
      Store_field(result, 0, extract_keysym(evt));
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

    case EnterNotify      : result = Val_int(1); break;
    case LeaveNotify      : result = Val_int(2); break;
    case FocusIn          : result = Val_int(3); break;
    case FocusOut         : result = Val_int(4); break;
    case KeymapNotify     : result = Val_int(5); break;
    case Expose           : result = Val_int(6); break;
    case GraphicsExpose   : result = Val_int(7); break;
    case NoExpose         : result = Val_int(8); break;
    case VisibilityNotify : result = Val_int(9); break;
    case CreateNotify     : result = Val_int(10); break;
    case DestroyNotify    : result = Val_int(11); break;
    case UnmapNotify      : result = Val_int(12); break;
    case MapNotify        : result = Val_int(13); break;
    case MapRequest       : result = Val_int(14); break;
    case ReparentNotify   : result = Val_int(15); break;
    case ConfigureNotify  : result = Val_int(16); break;
    case ConfigureRequest : result = Val_int(17); break;
    case GravityNotify    : result = Val_int(18); break;
    case ResizeRequest    : result = Val_int(19); break;
    case CirculateNotify  : result = Val_int(20); break;
    case CirculateRequest : result = Val_int(21); break;
    case PropertyNotify   : result = Val_int(22); break;
    case SelectionClear   : result = Val_int(23); break;
    case SelectionRequest : result = Val_int(24); break;
    case SelectionNotify  : result = Val_int(25); break;
    case ColormapNotify   : result = Val_int(26); break;

    // ClientMessage : get the Atom (message_type)
    case ClientMessage: // 33, 6th parametric variant 
      result = caml_alloc(1,5);
      Store_field(result, 0, (value)evt->xclient.data.l[0]);
      break;

    case MappingNotify    : result = Val_int(27); break;
    case GenericEvent     : result = Val_int(28); break;
    case LASTEvent        :
      result = Val_int(0);
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


