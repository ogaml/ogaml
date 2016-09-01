#include "utils.h"
#include <windows.h>
#include <memory.h>


LRESULT CALLBACK onEvent(HWND handle, UINT message, WPARAM wParam, LPARAM lParam)
{

    if (message == WM_CLOSE) {
        printf("Received close message!");
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

    window = CreateWindow(String_val(cname), 
                          String_val(title),
                          winstyle,
                          Int_val(Field(origin,0)),
                          Int_val(Field(origin,1)),
                          Int_val(Field(size,0)),
                          Int_val(Field(size,1)),
                          NULL,
                          NULL,
                          GetModuleHandle(NULL),
                          NULL);

    CAMLreturn((value)window);
}