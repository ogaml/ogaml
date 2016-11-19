#define GL_GLEXT_PROTOTYPES
#if defined(_WIN32)
  #include <windows.h>
  #include <gl/glew.h>
#endif
#if defined(__APPLE__)
  #include <OpenGL/gl3.h>
  #ifndef GL_TESS_CONTROL_SHADER
      #define GL_TESS_CONTROL_SHADER 0x00008e88
  #endif
  #ifndef GL_TESS_EVALUATION_SHADER
      #define GL_TESS_EVALUATION_SHADER 0x00008e87
  #endif
  #ifndef GL_PATCHES
      #define GL_PATCHES 0x0000000e
  #endif
#else
  #include <GL/gl.h>
#endif
#include <caml/bigarray.h>
#include "utils.h"
#include "types_stubs.h"


// INPUT   three booleans (color, depth, stencil)
// OUTPUT  nothing, clears the corresponding buffers
CAMLprim value
caml_gl_clear(value c, value d, value s)
{
  CAMLparam3(c,d,s);

  GLbitfield mask = 0;
  if (c == Val_true) mask |= GL_COLOR_BUFFER_BIT ;
  if (d == Val_true) mask |= GL_DEPTH_BUFFER_BIT ;
  if (s == Val_true) mask |= GL_STENCIL_BUFFER_BIT ;

  glClear(mask);

  CAMLreturn(Val_unit);
}


// INPUT   nothing
// OUTPUT  returns a GL error (option)
CAMLprim value
caml_gl_error(value unit)
{
  CAMLparam0();

  CAMLreturn(Val_error(glGetError()));
}


// INPUT   a parameter
// OUTPUT  returns the integer value of the parameter
CAMLprim value
caml_gl_get_integerv(value par)
{
  CAMLparam1(par);

  int data;
  int param = Parameter_val(par);

  if(param == -1) 
    data = -1;
  else
    glGetIntegerv(param,&data);

  CAMLreturn(Val_int(data));
}


// INPUT   four values r g b a
// OUTPUT  nothing, sets the clear color
CAMLprim value
caml_clear_color(value r, value g, value b, value a)
{
  CAMLparam4(r,g,b,a);

  glClearColor(
    Double_val(r),
    Double_val(g),
    Double_val(b),
    Double_val(a)
  );

  CAMLreturn(Val_unit);
}


// INPUT   a culling mode
// OUTPUT  nothing, sets the culling mode
CAMLprim value
caml_culling_mode(value mode)
{
  CAMLparam1(mode);

  GLenum val = Cull_val(mode);
  if(val != -1)
  {
    glEnable(GL_CULL_FACE);
    glFrontFace(val);
  }
  else
    glDisable(GL_CULL_FACE);

  CAMLreturn(Val_unit);
}


// INPUT   a boolean
// OUTPUT  nothing, (des)activates MSAA
CAMLprim value
caml_enable_msaa(value active)
{
  CAMLparam0();
  if(Bool_val(active))
    glEnable(GL_MULTISAMPLE);
  else
    glDisable(GL_MULTISAMPLE);
  CAMLreturn(Val_unit);
}


// INPUT   a polygon mode
// OUTPUT  nothing, sets the polygon mode
CAMLprim value
caml_polygon_mode(value mode)
{
  CAMLparam1(mode);

  glPolygonMode(GL_FRONT_AND_BACK, Polygon_val(mode));

  CAMLreturn(Val_unit);
}


// INPUT   a boolean
// OUTPUT  nothing, sets the current value of depth testing
CAMLprim value
caml_depth_test(value b)
{
  CAMLparam1(b);

  if(Bool_val(b))
    glEnable(GL_DEPTH_TEST);
  else
    glDisable(GL_DEPTH_TEST);

  CAMLreturn(Val_unit);
}


// INPUT   a boolean
// OUTPUT  nothing, sets the current value of depth writing
CAMLprim value
caml_depth_mask(value b)
{
  CAMLparam1(b);

  if(Bool_val(b))
    glDepthMask(GL_TRUE);
  else
    glDepthMask(GL_FALSE);

  CAMLreturn(Val_unit);
}


// INPUT   a depth function
// OUTPUT  nothing, sets the current value of the depth function
CAMLprim value
caml_depth_fun(value f)
{
  CAMLparam1(f);

  glDepthFunc(Depthfun_val(f));

  CAMLreturn(Val_unit);
}


// INPUT   x, y, width, height
// OUTPUT  nothing, sets the glViewport
CAMLprim value
caml_viewport(value x, value y, value w, value h)
{
  CAMLparam4(x,y,w,h);

  glViewport(Int_val(x), Int_val(y), Int_val(w), Int_val(h));

  CAMLreturn(Val_unit);
}


// INPUT   nothing
// OUTPUT  the current GL version
CAMLprim value
caml_gl_version(value unit)
{
  CAMLparam0();
  CAMLreturn(caml_copy_string(glGetString(GL_VERSION)));
}


// INPUT   nothing
// OUTPUT  the current GLSL version
CAMLprim value
caml_glsl_version(value unit)
{
  CAMLparam0();
  CAMLreturn(caml_copy_string(glGetString(GL_SHADING_LANGUAGE_VERSION)));
}


// INPUT   nothing
// OUTPUT  nothing, flushes the current buffer
CAMLprim value
caml_glflush(value unit)
{
  CAMLparam0();
  glFlush();
  CAMLreturn(Val_unit);
}


// INPUT   nothing
// OUTPUT  nothing, finishes the pending actions
CAMLprim value
caml_glfinish(value unit)
{
  CAMLparam0();
  glFinish();
  CAMLreturn(Val_unit);
}
