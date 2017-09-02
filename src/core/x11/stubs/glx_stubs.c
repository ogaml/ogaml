#include <X11/Xlib.h>
#include <GL/gl.h>
#include <GL/glx.h>
#include <memory.h>
#include <stdio.h>
#include "utils.h"

typedef GLXContext (*glXCreateContextAttribsARBProc)(Display*, GLXFBConfig, GLXContext, Bool, const int*);

// INPUT   : a display, a screen number, an attribute list
// OUTPUT  : a visual info satisfying the attribute list
CAMLprim value
caml_glx_choose_visual(value disp, value scr, value attributes, value len)
{
  CAMLparam4(disp, scr, attributes, len);
  CAMLlocal3(hd,tl,res);
  
  int attrs[Int_val(len)+1];
  int i = 0;
  int fbcount;
  Display* dpy = Display_val(disp);

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

  GLXFBConfig* fbc = glXChooseFBConfig(dpy, Int_val(scr), attrs, &fbcount);

  GLXFBConfig_alloc(res);
  GLXFBConfig_copy(res, &fbc[0]);

  CAMLreturn(res);
}


// INPUT   : a display, a GLXFBConfig, attributes and the total length of the 
//           resulting attrib list (w/ flags)
// OUTPUT  : creates a context satisfying the GLXFBConfig and the attributes
CAMLprim value
caml_glx_create_context(value disp, value glxfbc, value attribs, value length)
{
  CAMLparam4(disp, glxfbc, attribs, length);
  CAMLlocal2(hd,tl);

  int i = 0;
  int mask;
  int attrs_list[Int_val(length)+1];
  Display* dpy = Display_val(disp);
  GLXFBConfig config = GLXFBConfig_val(glxfbc);

  tl = attribs;

  while(tl != Val_emptylist) {
    mask = 0;
    hd = Field(tl, 0);
    tl = Field(tl, 1);
    switch(Tag_val(hd)) {
      case 0:
        attrs_list[i] = GLX_CONTEXT_MAJOR_VERSION_ARB;
        attrs_list[i+1] = Int_val(Field(hd,0));
        break;
      case 1:
        attrs_list[i] = GLX_CONTEXT_MINOR_VERSION_ARB;
        attrs_list[i+1] = Int_val(Field(hd,0));
        break;
      case 2:
        attrs_list[i] = GLX_CONTEXT_FLAGS_ARB;
        if(Bool_val(Field(Field(hd,0),0))) {
          mask |= GLX_CONTEXT_DEBUG_BIT_ARB;
        }
        if(Bool_val(Field(Field(hd,0),1))) {
          mask |= GLX_CONTEXT_FORWARD_COMPATIBLE_BIT_ARB;
        }
        attrs_list[i+1] = mask;
        break;
      case 3:
        attrs_list[i] = GLX_CONTEXT_PROFILE_MASK_ARB;
        if(Bool_val(Field(Field(hd,0),0))) {
          mask |= GLX_CONTEXT_CORE_PROFILE_BIT_ARB;
        }
        if(Bool_val(Field(Field(hd,0),1))) {
          mask |= GLX_CONTEXT_COMPATIBILITY_PROFILE_BIT_ARB;
        }
        attrs_list[i+1] = mask;
        break;
      default:
        caml_failwith("Variant error in glx_create_context");
    }
    i += 2;
  }
  attrs_list[i] = 0;

  glXCreateContextAttribsARBProc glXCreateContextAttribsARB = 0;
  glXCreateContextAttribsARB = (glXCreateContextAttribsARBProc)
    glXGetProcAddressARB((const GLubyte*) "glXCreateContextAttribsARB");

  GLXContext tmp = glXCreateContextAttribsARB(dpy, config, NULL, True, attrs_list);

  // a GLXContext is a pointer
  CAMLreturn(Val_GLXContext(tmp));
}


// INPUT   : a display, a window
// OUTPUT  : swaps the buffer of the window
CAMLprim value
caml_glx_swap_buffers(value disp, value win)
{
  CAMLparam2(disp, win);
  Display* dpy = Display_val(disp);
  Window w = Window_val(win);
  glXSwapBuffers(dpy, w);
  CAMLreturn(Val_unit);
}


// INPUT   : a display, a window and a GLcontext
// OUTPUT  : nothing, binds the context to the window
CAMLprim value
caml_glx_make_current(value disp, value win, value ctx)
{
  CAMLparam3(disp, win, ctx);
  Display* dpy = Display_val(disp);
  Window w = Window_val(win);
  GLXContext glc = GLXContext_val(ctx);
  glXMakeCurrent(dpy, w, glc);
  CAMLreturn(Val_unit);
}


// INPUT   : a display, a context
// OUTPUT  : nothing, frees the context
CAMLprim value
caml_glx_destroy_context(value disp, value ctx)
{
  CAMLparam2(disp, ctx);
  Display* dpy = Display_val(disp);
  GLXContext glc = GLXContext_val(ctx);
  glXDestroyContext(dpy, glc);
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
