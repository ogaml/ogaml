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
#include "types_stubs.h"
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
}


GLenum EBOKind_val(value kind) 
{
  switch(Int_val(kind))
  {
    case 0:
      return GL_STATIC_DRAW;

    case 1:
      return GL_DYNAMIC_DRAW;

    default:
      caml_failwith("Caml variant error in EBOKind_val(1)");
  }
}


int Val_attrib_type(GLenum type)
{
  switch(type)
  {
    case GL_INT          : return 0;
    case GL_INT_VEC2     : return 1;
    case GL_INT_VEC3     : return 2;
    case GL_INT_VEC4     : return 3;
    case GL_FLOAT        : return 4;
    case GL_FLOAT_VEC2   : return 5;
    case GL_FLOAT_VEC3   : return 6;
    case GL_FLOAT_VEC4   : return 7;
    case GL_FLOAT_MAT2   : return 8;
    case GL_FLOAT_MAT2x3 : return 9;
    case GL_FLOAT_MAT2x4 : return 10;
    case GL_FLOAT_MAT3x2 : return 11;
    case GL_FLOAT_MAT3   : return 12;
    case GL_FLOAT_MAT3x4 : return 13;
    case GL_FLOAT_MAT4x2 : return 14;
    case GL_FLOAT_MAT4x3 : return 15;
    case GL_FLOAT_MAT4   : return 16;
    case GL_SAMPLER_1D   : return 17;
    case GL_SAMPLER_2D   : return 18;
    case GL_SAMPLER_3D   : return 19;
    default: caml_failwith("Caml variant error in Val_type(1)");
  }
}


GLenum Cull_val(value mode)
{
  switch(Int_val(mode))
  {
    case 0:
      return -1;

    case 1:
      return GL_CCW;

    case 2:
      return GL_CW;

    default:
      caml_failwith("Caml variant error in Cull_val(1)");
  }
}


GLenum Polygon_val(value mode)
{
  switch(Int_val(mode))
  {
    case 0:
      return GL_POINT;

    case 1:
      return GL_LINE;

    case 2:
      return GL_FILL;

    default:
      caml_failwith("Caml variant error in Polygon_val(1)");
  }
}


GLenum Depthfun_val(value fun)
{
  switch(Int_val(fun))
  {
    case 0:
      return GL_ALWAYS;

    case 1:
      return GL_NEVER;

    case 2:
      return GL_LESS;

    case 3:
      return GL_GREATER;

    case 4:
      return GL_EQUAL;

    case 5:
      return GL_LEQUAL;

    case 6:
      return GL_GEQUAL;

    case 7:
      return GL_NOTEQUAL;

    default:
      caml_failwith("Caml variant error in Depthfun_val(1)");
  }
}


value Val_error(GLenum err)
{
  switch(err)
  {
    case GL_NO_ERROR: return Val_none;
    case GL_INVALID_ENUM      : return Val_some(Val_int(0));
    case GL_INVALID_VALUE     : return Val_some(Val_int(1));
    case GL_INVALID_OPERATION : return Val_some(Val_int(2));
    case GL_INVALID_FRAMEBUFFER_OPERATION : return Val_some(Val_int(3));
    case GL_OUT_OF_MEMORY   : return Val_some(Val_int(4));
  #ifndef __APPLE__
    case GL_STACK_UNDERFLOW : return Val_some(Val_int(5));
    case GL_STACK_OVERFLOW  : return Val_some(Val_int(6));
  #endif
    default : return Val_none;
  }
}


GLenum Shader_val(value type)
{
  switch(Int_val(type))
  {
    case 0:
      return GL_FRAGMENT_SHADER;

    case 1:
      return GL_VERTEX_SHADER;

    default:
      caml_failwith("Caml variant error in Shader_val(1)");
  }
}


GLenum Target_val(value target)
{
  switch(Int_val(target))
  {
    case 0:
      return GL_TEXTURE_1D;

    case 1:
      return GL_TEXTURE_2D;

    case 2:
      return GL_TEXTURE_3D;

    default:
      caml_failwith("Caml variant error in Target_val(1)");
  }
}


GLenum Magnify_val(value mag)
{
  switch(Int_val(mag))
  {
    case 0:
      return GL_NEAREST;

    case 1:
      return GL_LINEAR;

    default:
      caml_failwith("Caml variant error in Magnify_val(1)");
  }
}


GLenum Minify_val(value min)
{
  switch(Int_val(min))
  {
    case 0:
      return GL_NEAREST;

    case 1:
      return GL_LINEAR;

    case 2:
      return GL_NEAREST_MIPMAP_NEAREST;

    case 3:
      return GL_LINEAR_MIPMAP_NEAREST;

    case 4:
      return GL_NEAREST_MIPMAP_LINEAR;

    case 5:
      return GL_LINEAR_MIPMAP_LINEAR;

    default:
      caml_failwith("Caml variant error in Minify_val(1)");
  }
}


GLenum Wrap_val(value wrp)
{
  switch(Int_val(wrp))
  {
    case 0:
      return GL_CLAMP_TO_EDGE;

    case 1:
      return GL_CLAMP_TO_BORDER;

    case 2:
      return GL_MIRRORED_REPEAT;

    case 3:
      return GL_REPEAT;

    #ifndef GL_MIRROR_CLAMP_TO_EDGE
    case 4:
      caml_failwith("GL_MIRROR_CLAMP_TO_EDGE is not supported");
    #else
    case 4:
      return GL_MIRROR_CLAMP_TO_EDGE;
    #endif

    default:
      caml_failwith("Caml variant error in Wrap_val(1)");
  }
}


GLenum TextureFormat_val(value fmt)
{
  switch(Int_val(fmt))
  {
    case 0:
      return GL_R8;

    case 1:
      return GL_RG8;

    case 2:
      return GL_RGB8;

    case 3:
      return GL_RGBA8;

    case 4:
      return GL_DEPTH_COMPONENT24;

    case 5:
      return GL_DEPTH24_STENCIL8;

    default:
      caml_failwith("Caml variant error in TextureFormat_val(1)");
  }
}


GLenum PixelFormat_val(value fmt)
{
  switch(Int_val(fmt))
  {
    case 0:
      return GL_RED;

    case 1:
      return GL_RG;

    case 2:
      return GL_RGB;

    case 3:
      return GL_BGR;

    case 4:
      return GL_RGBA;

    case 5:
      return GL_BGRA;

    case 6:
      return GL_DEPTH_COMPONENT;

    case 7:
      return GL_DEPTH_STENCIL;

    default:
      caml_failwith("Caml variant error in TextureFormat_val(1)");
  }
}


GLenum Floattype_val(value type)
{
  switch(Int_val(type))
  {
    case 0:
      return GL_BYTE;

    case 1:
      return GL_UNSIGNED_BYTE;

    case 2:
      return GL_SHORT;

    case 3:
      return GL_UNSIGNED_SHORT;

    case 4:
      return GL_INT;

    case 5:
      return GL_UNSIGNED_INT;

    case 6:
      return GL_FLOAT;

    case 7:
      return GL_DOUBLE;

    default:
      failwith("Caml variant error in Floattype_val(1)");
  }
}


GLenum Inttype_val(value type)
{
  switch(Int_val(type))
  {
    case 0:
      return GL_BYTE;

    case 1:
      return GL_UNSIGNED_BYTE;

    case 2:
      return GL_SHORT;

    case 3:
      return GL_UNSIGNED_SHORT;

    case 4:
      return GL_INT;

    case 5:
      return GL_UNSIGNED_INT;

    default:
      failwith("Caml variant error in Inttype_val(1)");
  }
}


GLenum Drawmode_val(value mode)
{
  switch(Int_val(mode))
  {
    case 0:
      return GL_TRIANGLE_STRIP;

    case 1:
      return GL_TRIANGLE_FAN;

    case 2:
      return GL_TRIANGLES;

    case 3:
      return GL_LINES;

    default:
      failwith("Caml variant error in Drawmode_val(1)");
  }
}


GLenum VBOKind_val(value kind)
{
  switch(Int_val(kind))
  {
    case 0:
      return GL_STATIC_DRAW;

    case 1:
      return GL_DYNAMIC_DRAW;

    default:
      caml_failwith("Caml variant error in VBOKind_val(1)");
  }
}


GLenum Attachment_val(value att)
{
  if(Is_long(att)) {
    switch(Int_val(att))
    {
      case 0:
        return GL_DEPTH_ATTACHMENT;

      case 1:
        return GL_STENCIL_ATTACHMENT;
          
      default:
        caml_failwith("Caml variant error in Attachment_val (long val)");
    }
  } else {
    switch(Tag_val(att))
    {
      case 0:
        return (GL_COLOR_ATTACHMENT0 + Int_val(Field(att,0)));

      default:
        caml_failwith("Caml variant error in Attachment_val (tag val)");
    }
  }
}
