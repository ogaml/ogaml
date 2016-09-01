#include <gl/glew.h>
#include <gl/gl.h>

#include "utils.h"

#include <windows.h>
#include <memory.h>


CAMLprim value
caml_glew_init(value unit)
{
    CAMLparam0();
    CAMLlocal1(res);

    GLenum err;

    glewExperimental = GL_TRUE;    
    err = glewInit();

    if(err != GLEW_OK)
        res = caml_copy_string(glewGetErrorString(res));
    else
        res = caml_copy_string("");
        
    CAMLreturn(res);
}
