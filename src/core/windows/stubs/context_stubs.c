#include "utils.h"
#include <windows.h>
#include <memory.h>


CAMLprim value
caml_wgl_create_context(value hwnd)
{
    CAMLparam1(hwnd);

    HDC hDC;
    HGLRC hRC;

    hDC = GetDC((HWND)hwnd);
    hRC = wglCreateContext(hDC);

    CAMLreturn((value)hRC);
}


CAMLprim value
caml_wgl_make_current(value hwnd, value hrc)
{
    CAMLparam2(hwnd,hrc);

    HDC hDC = GetDC((HWND)hwnd);
    wglMakeCurrent(hDC,(HGLRC)hrc);

    CAMLreturn(Val_unit);
}


CAMLprim value
caml_wgl_remove_current(value hwnd)
{
    CAMLparam1(hwnd);

    HDC hDC = GetDC((HWND)hwnd);
    wglMakeCurrent(hDC,NULL);

    CAMLreturn (Val_unit);
}


CAMLprim value
caml_wgl_destroy(value hrc)
{
    CAMLparam1(hrc);

    wglDeleteContext((HGLRC)hrc);

    CAMLreturn(Val_unit);
}


CAMLprim value
caml_wgl_isnull(value hrc)
{
    CAMLparam1(hrc);

    HGLRC ctx = (HGLRC) hrc;

    CAMLreturn(Val_bool(ctx == NULL));
}