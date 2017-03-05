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
  CAMLlocal1(res);

  Display* dpy = Display_val(disp);
  Window p = Window_val(parent);
  XVisualInfo* xvi = XVisualInfo_val(visual);

  int depth = xvi->depth;

  Visual *vis = xvi->visual;

  unsigned int mask = CWBackPixmap | CWBorderPixel | CWColormap | CWEventMask;

  XSetWindowAttributes winAttr ;
    winAttr.event_mask = StructureNotifyMask | KeyPressMask ;
    winAttr.background_pixmap = None ;
    winAttr.background_pixel  = 0    ;
    winAttr.border_pixel      = 0    ;
    winAttr.colormap = XCreateColormap(dpy, p, vis, AllocNone);
 

  Window win = XCreateWindow(
        dpy,
        p,
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

  Window_alloc(res);
  Window_copy(res, &win),

  CAMLreturn(res);
}


// INPUT   display, screen
// OUTPUT  window (root of screen)
CAMLprim value
caml_xroot_window(value disp, value screen)
{
  CAMLparam2(disp, screen);
  CAMLlocal1(res);

  Display* dpy = Display_val(disp);
  Window win = XRootWindow(dpy, Int_val(screen));
  Window_alloc(res);
  Window_copy(res, &win),

  CAMLreturn(res);
}


// INPUT   display, window, string
// OUTPUT  nothing, sets the title of the window
CAMLprim value
caml_xwindow_set_title(value disp, value win, value str)
{
  CAMLparam3(disp, win, str);
  Display* dpy = Display_val(disp);
  Window w = Window_val(win);
  XStoreName(dpy, w, String_val(str));
  CAMLreturn(Val_unit);
}


// INPUT   display, window
// OUTPUT  the title of the window
CAMLprim value
caml_xwindow_get_title(value disp, value win)
{
  CAMLparam2(disp, win);
  CAMLlocal1(res);
  Display* dpy = Display_val(disp);
  Window w = Window_val(win);

  char* win_name;
  XFetchName(dpy, w, &win_name);
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
  Display* dpy = Display_val(disp);
  Window w = Window_val(win);

  XMapWindow(dpy, w);
  CAMLreturn(Val_unit);
}


// INPUT   display, window
// OUTPUT  nothing, unmaps the window
CAMLprim value
caml_xunmap_window(value disp, value win)
{
  CAMLparam2(disp, win);
  Display* dpy = Display_val(disp);
  Window w = Window_val(win);

  XUnmapWindow(dpy, w);
  CAMLreturn(Val_unit);
}


// INPUT   display, window
// OUTPUT  nothing, destroys the window
CAMLprim value
caml_xdestroy_window(value disp, value win)
{
  CAMLparam2(disp, win);
  Display* dpy = Display_val(disp);
  Window w = Window_val(win);

  XDestroyWindow(dpy, w);
  CAMLreturn(Val_unit);
}


// INPUT   display, window
// OUTPUT  width and height of window (in pixels)
CAMLprim value
caml_size_window(value disp, value win)
{
  CAMLparam2(disp, win);
  Display* dpy = Display_val(disp);
  Window w = Window_val(win);

  XWindowAttributes att;
  XGetWindowAttributes(dpy, w, &att);
  CAMLreturn(Int_pair(att.width, att.height));
}


// INPUT   display, window
// OUTPUT  position of the window (in pixel)
CAMLprim value
caml_xwindow_position(value disp, value win)
{
  CAMLparam2(disp, win);
  Display* dpy = Display_val(disp);
  Window w = Window_val(win);
  XWindowAttributes att;
  XGetWindowAttributes(dpy, w, &att);
  CAMLreturn(Int_pair(att.x, att.y));
}


// INPUT   display, window, x, y
// OUTPUT  resizes the window
CAMLprim value
caml_resize_window(value disp, value win, value w, value h)
{
  CAMLparam4(disp, win, w, h);
  Display* dpy = Display_val(disp);
  Window w = Window_val(win);
  XResizeWindow(dpy, w, Int_val(w), Int_val(h));
  CAMLreturn(Val_unit);
}


// INPUT   display, window, min size, max size
// OUTPUT  nothing, sets the wm size hints
CAMLprim value
caml_set_wm_size_hints(value disp, value win, value minsize, value maxsize)
{
  CAMLparam4(disp, win, minsize, maxsize);
  Display* dpy = Display_val(disp);
  Window w = Window_val(win);
  XSizeHints* hints = XAllocSizeHints();
  hints->flags      = PMinSize | PMaxSize;
  hints->min_width  = Int_val(Field(minsize,0));
  hints->min_height = Int_val(Field(minsize,1));
  hints->max_width  = Int_val(Field(maxsize,0));
  hints->max_height = Int_val(Field(maxsize,1));
  XSetWMNormalHints(dpy, w, hints);
  XFree(hints);
  CAMLreturn(Val_unit);
}


// INPUT   a display, a window
// OUTPUT  true iff the window has focus
CAMLprim value
caml_has_focus(value disp, value win)
{
  CAMLparam2(disp, win);
  Display* dpy = Display_val(disp);
  Window w = Window_val(win);

  Window result;
  int state;
  XGetInputFocus(dpy, &result, &state);

  CAMLreturn(Val_bool(w == result));
}


// INPUT   a display, a window, a boolean
// OUTPUT  nothing, changes the visibility of the cursor
CAMLprim value
caml_xshow_cursor(value disp, value win, value bl)
{
  CAMLparam3(disp, win, bl);

  Display* dpy = Display_val(disp);
  Window w = Window_val(win);

  if(!Bool_val(bl)) {
    Pixmap bm_no;
    Colormap cmap;
    Cursor no_ptr;
    XColor black, dummy;
    static char bm_no_data[] = {0, 0, 0, 0, 0, 0, 0, 0};

    cmap = DefaultColormap(dpy, DefaultScreen(dpy));
    XAllocNamedColor(dpy, cmap, "black", &black, &dummy);
    bm_no = XCreateBitmapFromData(dpy, w, bm_no_data, 8, 8);
    no_ptr = XCreatePixmapCursor(dpy, bm_no, bm_no, &black, &black, 0, 0);

    XDefineCursor(dpy, w, no_ptr);
    XFreeCursor(dpy, no_ptr);
    if (bm_no != None)
            XFreePixmap(dpy, bm_no);
    XFreeColors(dpy, cmap, &black.pixel, 1, 0);
  } else {
    XUndefineCursor(dpy, w);
  }
  CAMLreturn(Val_unit);
}
 


