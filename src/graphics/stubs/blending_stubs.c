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

GLenum BlendFunc_val(value func) 
{
  switch(Tag_val(func))
  {
    case 0:
      return GL_FUNC_ADD;

    case 1:
      return GL_FUNC_SUBTRACT;

    default:
      caml_failwith("Caml variant error in BlendFunc_val(1)");
  }

  return 0;
}


GLenum BlendFactor_val(value fac) 
{
  switch(Int_val(fac))
  {
    case 0 : 
      return GL_ZERO;

    case 1 : 
      return GL_ONE;

    case 2 : 
      return GL_SRC_COLOR;

    case 3 : 
      return GL_ONE_MINUS_SRC_COLOR;

    case 4 : 
      return GL_DST_COLOR;

    case 5 : 
      return GL_ONE_MINUS_DST_COLOR;

    case 6 : 
      return GL_SRC_ALPHA;

    case 7 : 
      return GL_SRC_ALPHA_SATURATE;

    case 8 : 
      return GL_ONE_MINUS_SRC_ALPHA;

    case 9 : 
      return GL_DST_ALPHA;

    case 10: 
      return GL_ONE_MINUS_DST_ALPHA;

    case 11: 
      return GL_CONSTANT_COLOR;

    case 12: 
      return GL_ONE_MINUS_CONSTANT_COLOR;

    case 13: 
      return GL_CONSTANT_ALPHA;

    case 14: 
      return GL_ONE_MINUS_CONSTANT_ALPHA;

    default:
      caml_failwith("Caml variant error in BlendFactor_val(1)");
  }

  return 0;
}


CAMLprim value
caml_blend_enable(value b)
{
  CAMLparam1(b);
  
  if(Bool_val(b)) glEnable(GL_BLEND);
  else glDisable(GL_BLEND);

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_blend_func_separate(value srcRGB, value dstRGB, value srcA, value dstA)
{
  CAMLparam4(srcRGB, dstRGB, srcA, dstA);

  glBlendFuncSeparate(
      BlendFactor_val(srcRGB), 
      BlendFactor_val(dstRGB), 
      BlendFactor_val(srcA), 
      BlendFactor_val(dstA));

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_blend_equation_separate(value eqRGB, value eqA)
{
  CAMLparam2(eqRGB, eqA);

  GLenum rgb_eq = (Is_long(eqRGB))? GL_FUNC_ADD : BlendFunc_val(eqRGB);
  GLenum alp_eq = (Is_long(eqA))?   GL_FUNC_ADD : BlendFunc_val(eqA  );

  glBlendEquationSeparate(rgb_eq, alp_eq);

  CAMLreturn(Val_unit);
}
