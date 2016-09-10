#include <X11/Xlib.h>
#include <GL/gl.h>
#include <GL/glx.h>
#include "utils.h"


// INPUT   display, parent window, origin, size, border width, 
//         border value, bg value
// OUTPUT  new window 
CAMLprim value
caml_xcreate_simple_window(
    value disp, value parent, value origin, value size, value visual
  )
{
  CAMLparam5(disp, parent, origin, size, visual);

  int depth = ((XVisualInfo*)visual)->depth;

  Visual *vis = ((XVisualInfo*)visual)->visual;

  unsigned int mask = CWBackPixmap | CWBorderPixel | CWColormap | CWEventMask;

  XSetWindowAttributes winAttr ;
    winAttr.event_mask = StructureNotifyMask | KeyPressMask ;
    winAttr.background_pixmap = None ;
    winAttr.background_pixel  = 0    ;
    winAttr.border_pixel      = 0    ;
    winAttr.colormap = XCreateColormap((Display*)disp, (Window)parent, vis, AllocNone );
 

  Window win = XCreateWindow(
        (Display*) disp, 
        (Window) parent,
        Int_val(Field(origin,0)),
        Int_val(Field(origin,1)),
        Int_val(Field(size,0)),
        Int_val(Field(size,1)),
        0,
        depth,
        InputOutput,
        vis,
        mask,
        &winAttr
    );

  CAMLreturn((value)win);
}


// INPUT   display, screen
// OUTPUT  window (root of screen)
CAMLprim value
caml_xroot_window(value disp, value screen)
{
  CAMLparam2(disp, screen);
  CAMLreturn((value) XRootWindow((Display*) disp, Int_val(screen)));
}


// INPUT   display, window, string
// OUTPUT  nothing, sets the title of the window
CAMLprim value
caml_xwindow_set_title(value disp, value win, value str)
{
  CAMLparam3(disp, win, str);
  XStoreName((Display*)disp, (Window)win, String_val(str));
  CAMLreturn(Val_unit);
}


// INPUT   display, window
// OUTPUT  the title of the window
CAMLprim value
caml_xwindow_get_title(value disp, value win)
{
  CAMLparam2(disp, win);
  CAMLlocal1(res);
  char* win_name;
  XFetchName((Display*)disp, (Window)win, &win_name);
  res = caml_copy_string(win_name);
  XFree(win_name);
  CAMLreturn(res);
}


// INPUT   display, window
// OUTPUT  nothing, maps the window
CAMLprim value
caml_xmap_window(value disp, value win)
{
  CAMLparam2(disp, win);
  XMapWindow((Display*) disp, (Window) win);
  CAMLreturn(Val_unit);
}


// INPUT   display, window
// OUTPUT  nothing, unmaps the window
CAMLprim value
caml_xunmap_window(value disp, value win)
{
  CAMLparam2(disp, win);
  XUnmapWindow((Display*) disp, (Window) win);
  CAMLreturn(Val_unit);
}


// INPUT   display, window
// OUTPUT  nothing, destroys the window
CAMLprim value
caml_xdestroy_window(value disp, value win)
{
  CAMLparam2(disp, win);
  XDestroyWindow((Display*) disp, (Window) win);
  CAMLreturn(Val_unit);
}


// INPUT   display, window
// OUTPUT  width and height of window (in pixels)
CAMLprim value
caml_size_window(value disp, value win)
{
  CAMLparam2(disp, win);
  XWindowAttributes att;
  XGetWindowAttributes((Display*) disp, (Window) win, &att);
  CAMLreturn(Int_pair(att.width, att.height));
}


// INPUT   display, window
// OUTPUT  position of the window (in pixel)
CAMLprim value
caml_xwindow_position(value disp, value win)
{
  CAMLparam2(disp, win);
  XWindowAttributes att;
  XGetWindowAttributes((Display*) disp, (Window) win, &att);
  CAMLreturn(Int_pair(att.x, att.y));
}


// INPUT   display, window, x, y
// OUTPUT  resizes the window
CAMLprim value
caml_resize_window(value disp, value win, value w, value h)
{
  CAMLparam4(disp, win, w, h);
  XResizeWindow((Display*) disp, (Window) win, Int_val(w), Int_val(h));
  CAMLreturn(Val_unit);
}


// INPUT   display, window, min size, max size
// OUTPUT  nothing, sets the wm size hints
CAMLprim value
caml_set_wm_size_hints(value disp, value win, value minsize, value maxsize)
{
  CAMLparam4(disp, win, minsize, maxsize);
  XSizeHints* hints = XAllocSizeHints();
  hints->flags      = PMinSize | PMaxSize;
  hints->min_width  = Int_val(Field(minsize,0));
  hints->min_height = Int_val(Field(minsize,1));
  hints->max_width  = Int_val(Field(maxsize,0));
  hints->max_height = Int_val(Field(maxsize,1));
  XSetWMNormalHints((Display*) disp, (Window) win, hints);
  XFree(hints);
  CAMLreturn(Val_unit);
}


// INPUT   a display, a window
// OUTPUT  true iff the window has focus
CAMLprim value
caml_has_focus(value disp, value win)
{
  CAMLparam2(disp, win);
  Window result;
  int state;
  XGetInputFocus((Display*) disp, &result, &state);
  CAMLreturn(Val_bool(((Window)win) == result));
}


// INPUT   a display, a window, a boolean
// OUTPUT  nothing, changes the visibility of the cursor
CAMLprim value
caml_xshow_cursor(value disp, value win, value bl)
{
  CAMLparam3(disp, win, bl);
  if(!Bool_val(bl)) {
    Pixmap bm_no;
    Colormap cmap;
    Cursor no_ptr;
    XColor black, dummy;
    static char bm_no_data[] = {0, 0, 0, 0, 0, 0, 0, 0};

    cmap = DefaultColormap((Display*) disp, DefaultScreen((Display*) disp));
    XAllocNamedColor((Display*) disp, cmap, "black", &black, &dummy);
    bm_no = XCreateBitmapFromData((Display*) disp, (Window) win, bm_no_data, 8, 8);
    no_ptr = XCreatePixmapCursor((Display*) disp, bm_no, bm_no, &black, &black, 0, 0);

    XDefineCursor((Display*) disp, (Window) win, no_ptr);
    XFreeCursor((Display*) disp, no_ptr);
    if (bm_no != None)
            XFreePixmap((Display*) disp, bm_no);
    XFreeColors((Display*) disp, cmap, &black.pixel, 1, 0);
  } else {
    XUndefineCursor((Display*) disp, (Window) win);
  }
  CAMLreturn(Val_unit);
}
 


