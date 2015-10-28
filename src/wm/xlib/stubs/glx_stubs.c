#include <X11/Xlib.h>
#include <GL/gl.h>
#include <GL/glx.h>
#include <memory.h>
#include "../../../utils/stubs.h"


// INPUT   : a display, a screen number, an attribute list
// OUTPUT  : a visual info satisfying the attribute list
CAMLprim value
caml_glx_choose_visual(value disp, value scr, value attributes, value len)
{
  CAMLparam4(disp, scr, attributes, len);
  CAMLlocal2(hd,tl);
  
  int attrs[Int_val(len)+1];
  int i = 0;

  tl = attributes;

  while(tl != Val_emptylist) {
    hd = Field(tl, 0);
    tl = Field(tl, 1);
    if(Is_long(hd)) {
      switch(Int_val(hd)) {
        case 0 : attrs[i] = GLX_RGBA; break;
        case 1 : attrs[i] = GLX_DOUBLEBUFFER; break;
        case 2 : attrs[i] = GLX_STEREO; break;
        default: caml_failwith("Variant handling bug in glx_choose_visual");
      }
      i++;
    } else {
      attrs[i+1] = Int_val(Field(hd,0));
      switch(Tag_val(hd)) {
        case 0  : attrs[i] = GLX_BUFFER_SIZE; break;
        case 1  : attrs[i] = GLX_LEVEL      ; break;
        case 2  : attrs[i] = GLX_AUX_BUFFERS; break;
        case 3  : attrs[i] = GLX_RED_SIZE   ; break;
        case 4  : attrs[i] = GLX_GREEN_SIZE ; break;
        case 5  : attrs[i] = GLX_BLUE_SIZE  ; break;
        case 6  : attrs[i] = GLX_ALPHA_SIZE ; break;
        case 7  : attrs[i] = GLX_DEPTH_SIZE ; break;
        case 8  : attrs[i] = GLX_STENCIL_SIZE    ; break;
        case 9  : attrs[i] = GLX_ACCUM_RED_SIZE  ; break;
        case 10 : attrs[i] = GLX_ACCUM_BLUE_SIZE ; break;
        case 11 : attrs[i] = GLX_ACCUM_ALPHA_SIZE; break;
        case 12 : attrs[i] = GLX_ACCUM_GREEN_SIZE; break;
        default: caml_failwith("Variant handling bug in glx_choose_visual");
      }
      i += 2;
    }
  }

  attrs[i] = None;

  CAMLreturn(
      (value) glXChooseVisual(
        (Display*)disp, 
        Int_val(scr),
        attrs
      )
  );
}


// INPUT   : a display, a visualinfo struct
// OUTPUT  : creates a context satisfying the visualinfo
CAMLprim value
caml_glx_create_context(value disp, value vi)
{
  CAMLparam2(disp, vi);

  // a GLXContext is already a pointer
  GLXContext tmp = glXCreateContext(
      (Display*) disp,
      (XVisualInfo*) vi,
      NULL, True);

  CAMLreturn((value)tmp);
}


// INPUT   : a display, a window
// OUTPUT  : swaps the buffer of the window
CAMLprim value
caml_glx_swap_buffers(value disp, value win)
{
  CAMLparam2(disp, win);
  glXSwapBuffers((Display*)disp, (Window)win);
  CAMLreturn(Val_unit);
}


// INPUT   : a display, a window and a GLcontext
// OUTPUT  : nothing, binds the context to the window
CAMLprim value
caml_glx_make_current(value disp, value win, value ctx)
{
  CAMLparam3(disp, win, ctx);
  glXMakeCurrent((Display*)disp, (Window)win, (GLXContext)ctx);
  CAMLreturn(Val_unit);
}


// INPUT   : a display, a window 
// OUTPUT  : nothing, removes the current context of the window
CAMLprim value
caml_glx_remove_current(value disp, value win)
{
  CAMLparam2(disp, win);
  glXMakeCurrent((Display*)disp, (Window)win, NULL);
  CAMLreturn(Val_unit);
}


// INPUT   : a display, a context
// OUTPUT  : nothing, frees the context
CAMLprim value
caml_glx_destroy_context(value disp, value ctx)
{
  CAMLparam2(disp, ctx);
  glXDestroyContext((Display*)disp, (GLXContext)ctx);
  CAMLreturn(Val_unit);
}



