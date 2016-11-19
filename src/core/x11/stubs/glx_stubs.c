#include <X11/Xlib.h>
#include <GL/gl.h>
#include <GL/glx.h>
#include <memory.h>
#include <stdio.h>
#include "utils.h"


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
      attrs[i+1] = True;
      switch(Int_val(hd)) {
        case 0 : attrs[i] = GLX_DOUBLEBUFFER; break;
        case 1 : attrs[i] = GLX_STEREO; break;
        case 2 : attrs[i] = GLX_X_RENDERABLE; break;
        default: caml_failwith("Variant handling bug in glx_choose_visual");
      }
      i += 2;
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
        case 13 : attrs[i] = GLX_SAMPLES; break;
        case 14 : attrs[i] = GLX_SAMPLE_BUFFERS; break;
        default: caml_failwith("Variant handling bug in glx_choose_visual");
      }
      i += 2;
    }
  }

  attrs[i] = None;
  
  int fbcount;
  GLXFBConfig* fbc = glXChooseFBConfig((Display*)disp, Int_val(scr), attrs, &fbcount);
  XVisualInfo* vis = glXGetVisualFromFBConfig((Display*)disp, fbc[0]);

  CAMLreturn((value) vis);
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


// INPUT   : a display, a context
// OUTPUT  : nothing, frees the context
CAMLprim value
caml_glx_destroy_context(value disp, value ctx)
{
  CAMLparam2(disp, ctx);
  glXDestroyContext((Display*)disp, (GLXContext)ctx);
  CAMLreturn(Val_unit);
}


CAMLprim value
caml_glcontext_debug(value unit)
{
  CAMLparam0();

  switch(glGetError())
  {
    case GL_NO_ERROR:          
      printf("No error\n"); break;
    case GL_INVALID_ENUM:      
      printf("Invalid enum\n"); break;
    case GL_INVALID_VALUE:     
      printf("Invalid value\n"); break;
    case GL_INVALID_OPERATION: 
      printf("Invalid operation\n"); break;
    case GL_INVALID_FRAMEBUFFER_OPERATION: 
      printf("Invalid FBO operation\n"); break;
    case GL_OUT_OF_MEMORY:     
      printf("Out of memory\n"); break;
  #ifdef GL_STACK_UNDERFLOW
    case GL_STACK_UNDERFLOW: 
      printf("Stack underflow\n"); break;
  #endif
  #ifdef GL_STACK_OVERFLOW
    case GL_STACK_OVERFLOW: 
      printf("Stack overflow\n"); break;
  #endif
    default:
      break;
  }

  CAMLreturn(Val_unit);
}
