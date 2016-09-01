#include "utils.h"
#include <windows.h>
#include <memory.h>


LRESULT CALLBACK onEvent(HWND handle, UINT message, WPARAM wParam, LPARAM lParam)
{

    if (message == WM_CLOSE) {
        return 0;
    }

    if ((message == WM_SYSCOMMAND) && (wParam == SC_KEYMENU))
        return 0;

    return DefWindowProc(handle, message, wParam, lParam);
}


CAMLprim value
caml_register_class_W (value name)
{
    CAMLparam1(name);

    const wchar_t* classname = (wchar_t*)String_val(name);

    WNDCLASSW windowClass;
    windowClass.style         = 0;
    windowClass.lpfnWndProc   = &onEvent;
    windowClass.cbClsExtra    = 0;
    windowClass.cbWndExtra    = 0;
    windowClass.hInstance     = GetModuleHandleW(NULL);
    windowClass.hIcon         = NULL;
    windowClass.hCursor       = 0;
    windowClass.hbrBackground = 0;
    windowClass.lpszMenuName  = NULL;
    windowClass.lpszClassName = classname;
    RegisterClassW(&windowClass);

    CAMLreturn(Val_unit);
}

CAMLprim value
caml_create_window_W(value cname, value title, value origin, value size, value style)
{
    CAMLparam5(cname, title, origin, size, style);

    DWORD winstyle = (DWORD)style;
    HWND window;
    int width, height, posx, posy;
    RECT rectangle;

    posx = Field(origin,0);
    posy = Field(origin,1);
    width = Field(size,0);
    height = Field(size,1);

    rectangle.left = posx;
    rectangle.top  = posy;
    rectangle.right = posx+width;
    rectangle.bottom = posy+height;

    AdjustWindowRect(&rectangle, winstyle, 0);

    posx = rectangle.left;
    posy = rectangle.top;
    width  = rectangle.right - rectangle.left;
    height = rectangle.bottom - rectangle.top;

    window = CreateWindowW(String_val(cname), 
                           String_val(title),
                           winstyle,
                           posx,
                           posy,
                           width,
                           height,
                           NULL,
                           NULL,
                           GetModuleHandle(NULL),
                           (LPCWSTR)NULL);


    CAMLreturn((value)window);
}


CAMLprim value
caml_get_window_rect(value handle)
{
    CAMLparam1(handle);
    CAMLlocal1(res);

    HWND wnd = (HWND)handle;
    RECT rect;

    GetWindowRect(wnd, &rect);

    res = caml_alloc(4,0);
    Store_field(res, 0, Val_int(rect.left));
    Store_field(res, 1, Val_int(rect.top));
    Store_field(res, 2, Val_int(rect.right - rect.left));
    Store_field(res, 3, Val_int(rect.bottom - rect.top));

    CAMLreturn(res);
}