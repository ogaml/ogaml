#define GL_GLEXT_PROTOTYPES
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
