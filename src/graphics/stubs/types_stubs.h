#ifndef TYPES_STUBS_HEADER
#define TYPES_STUBS_HEADER

#include <caml/custom.h>
#include <caml/fail.h>
#include <caml/callback.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/mlvalues.h>
#include <stdio.h>


GLenum BlendFunc_val(value func);

GLenum BlendFactor_val(value fac);

GLenum EBOKind_val(value kind);

int Val_attrib_type(GLenum type);

GLenum Cull_val(value mode);

GLenum Polygon_val(value mode);

GLenum Depthfun_val(value fun);

value Val_error(GLenum err);

GLenum Shader_val(value type);

GLenum Target_val(value target);

GLenum Magnify_val(value mag);

GLenum Minify_val(value min);

GLenum Wrap_val(value wrp);

GLenum TextureFormat_val(value fmt);

GLenum PixelFormat_val(value fmt);

GLenum Floattype_val(value type);

GLenum Inttype_val(value type);

GLenum Drawmode_val(value mode);

GLenum VBOKind_val(value kind);

GLenum Attachment_val(value att);

GLenum Parameter_val(value par);

GLenum WindowOutputBuffer_val(value par);

GLenum FBOOutputBuffer_val(value par);

GLenum Query_val(value query);

#endif
