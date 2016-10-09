#include "utils.h"
#include <windows.h>
#include <wingdi.h>
#include <memory.h>


CAMLprim value
caml_simple_pfmt_descriptor(value hwnd, value depth, value stencil)
{
    CAMLparam3(hwnd, depth, stencil);

    PIXELFORMATDESCRIPTOR pfd =
	{
		sizeof(PIXELFORMATDESCRIPTOR),
		1,
		PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER,
		PFD_TYPE_RGBA,
		32, 
		0, 0, 0, 0, 0, 0,
		0,
		0,
		0,
		0, 0, 0, 0,
		Int_val(depth),
		Int_val(stencil),
		0,
		PFD_MAIN_PLANE,
		0,
		0, 0, 0
	};

    PIXELFORMATDESCRIPTOR* result = malloc(sizeof(PIXELFORMATDESCRIPTOR));
                           *result = pfd;

    CAMLreturn((value)result);
}

CAMLprim value
caml_choose_pixelformat(value hwnd, value descriptor)
{
    CAMLparam2(hwnd,descriptor);

    HDC handle = GetDC((HWND)hwnd);
    PIXELFORMATDESCRIPTOR* pfd = (PIXELFORMATDESCRIPTOR*)descriptor;
    int pfmt = ChoosePixelFormat(handle,pfd);
    CAMLreturn((value)pfmt);
}

CAMLprim value
caml_set_pixelformat(value hwnd, value descriptor, value format)
{
    CAMLparam3(hwnd, descriptor, format);

    HDC handle = GetDC((HWND)hwnd);
    PIXELFORMATDESCRIPTOR* pfd = (PIXELFORMATDESCRIPTOR*)descriptor;
    SetPixelFormat(handle,(int)format,pfd);

    CAMLreturn(Val_unit);
}

CAMLprim value
caml_destroy_pfmt_descriptor(value descriptor)
{
    CAMLparam1(descriptor);

    PIXELFORMATDESCRIPTOR* pfd = (PIXELFORMATDESCRIPTOR*)descriptor;
    free(pfd);

    CAMLreturn(Val_unit);
}