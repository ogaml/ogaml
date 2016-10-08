#include "utils.h"
#include <windows.h>
#include <memory.h>

value* callback_get_window_from_id;
value* callback_push_event_to_window;

value processEvent(UINT message, WPARAM wParam, LPARAM lParam)
{
    CAMLparam0();
    CAMLlocal3(res,res_field_1,res_field_2);

    switch(message)
    {
        case WM_CLOSE:
        {
            res = Val_int(1);
            break;
        }

        case WM_SIZE:
        {
            res = caml_alloc(1,0);
            Store_field(res, 0, Val_bool(wParam != SIZE_MINIMIZED));
            break;
        }

        case WM_ENTERSIZEMOVE:
        {
            res = Val_int(2);
            break;
        }

        case WM_EXITSIZEMOVE:
        {
            res = Val_int(3);
            break;
        }

        case WM_KEYDOWN:
        case WM_SYSKEYDOWN:
        {
            res = caml_alloc(2,1);
            if(wParam >=65 && wParam <= 90) {
                res_field_1 = caml_alloc(1,1);
                Store_field(res_field_1,0,Val_int(wParam));
            } else {
                res_field_1 = caml_alloc(1,0);
                Store_field(res_field_1,0,Val_int(wParam));
            }
            res_field_2 = caml_alloc(4,0);
            Store_field(res_field_2,0,Val_bool(HIWORD(GetAsyncKeyState(VK_SHIFT)) != 0));
            Store_field(res_field_2,1,Val_bool(HIWORD(GetAsyncKeyState(VK_CONTROL)) != 0));
            Store_field(res_field_2,2,Val_bool(HIWORD(GetAsyncKeyState(VK_CAPITAL)) != 0));
            Store_field(res_field_2,3,Val_bool(HIWORD(GetAsyncKeyState(VK_MENU)) != 0));

            Store_field(res, 0, res_field_1);
            Store_field(res, 1, res_field_2);
            break;
        }

        case WM_KEYUP:
        case WM_SYSKEYUP:
        {
            res = caml_alloc(2,2);
            if(wParam >=65 && wParam <= 90) {
                res_field_1 = caml_alloc(1,1);
                Store_field(res_field_1,0,Val_int(wParam));
            } else {
                res_field_1 = caml_alloc(1,0);
                Store_field(res_field_1,0,Val_int(wParam));
            }
            res_field_2 = caml_alloc(4,0);
            Store_field(res_field_2,0,Val_bool(HIWORD(GetAsyncKeyState(VK_SHIFT)) != 0));
            Store_field(res_field_2,1,Val_bool(HIWORD(GetAsyncKeyState(VK_CONTROL)) != 0));
            Store_field(res_field_2,2,Val_bool(HIWORD(GetAsyncKeyState(VK_CAPITAL)) != 0));
            Store_field(res_field_2,3,Val_bool(HIWORD(GetAsyncKeyState(VK_MENU)) != 0));

            Store_field(res, 0, res_field_1);
            Store_field(res, 1, res_field_2);
            break;
        }

        default:
        {
            res = Val_int(0);
            break;
        }
    }

    CAMLreturn(res);
}

CAMLprim value
caml_get_async_key_state(value key)
{
    CAMLparam1(key);
    
    int code = Int_val(Field(key,0));

    CAMLreturn(Val_bool(HIWORD(GetAsyncKeyState(code)) != 0));
}

LRESULT CALLBACK onEvent(HWND handle, UINT message, WPARAM wParam, LPARAM lParam)
{

    LONG_PTR data;
    value uid;
    value win;

    if(message == WM_CREATE)
    {
        uid = (int)((CREATESTRUCT*)lParam)->lpCreateParams;
        SetWindowLongPtrA(handle, GWLP_USERDATA, (LONG_PTR)uid);

    }

    if(handle) {

        data = GetWindowLongPtrA(handle, GWLP_USERDATA);

        if(data) {

            uid = (int)data;

            if(!callback_get_window_from_id) {
                callback_get_window_from_id = caml_named_value("OGAMLCallbackGetWindow");
            }

            if(!callback_push_event_to_window) {
                callback_push_event_to_window = caml_named_value("OGAMLCallbackPushEvent");
            }

            if(callback_get_window_from_id && callback_push_event_to_window) {

                win = caml_callback(*callback_get_window_from_id, Val_int(uid));

                if(Is_block(win)) {

                    caml_callback2(*callback_push_event_to_window, Field(win,0),
                                   processEvent(message,wParam,lParam));
                }

            }

        }

    }

    if (message == WM_CLOSE) {
        return 0;
    }

    if ((message == WM_SYSCOMMAND) && (wParam == SC_KEYMENU))
        return 0;

    return DefWindowProcA(handle, message, wParam, lParam);
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
    windowClass.hInstance     = GetModuleHandleA(NULL);
    windowClass.hIcon         = NULL;
    windowClass.hCursor       = LoadCursor( NULL, IDC_ARROW );
    windowClass.hbrBackground = 0;
    windowClass.lpszMenuName  = NULL;
    windowClass.lpszClassName = classname;
    RegisterClassA(&windowClass);

    CAMLreturn(Val_unit);
}

CAMLprim value
caml_create_window_W(value cname, value title, value rect, value style, value uid)
{
    CAMLparam5(cname, title, rect, style, uid);

    DWORD winstyle = (DWORD)style;
    HWND window;
    int width, height, posx, posy;
    RECT rectangle;

    posx = Int_val(Field(rect,0));
    posy = Int_val(Field(rect,1));
    width = Int_val(Field(rect,2));
    height = Int_val(Field(rect,3));

    rectangle.left = posx;
    rectangle.top  = posy;
    rectangle.right = posx+width;
    rectangle.bottom = posy+height;

    AdjustWindowRect(&rectangle, winstyle, 0);

    posx = rectangle.left;
    posy = rectangle.top;
    width  = rectangle.right - rectangle.left;
    height = rectangle.bottom - rectangle.top;

    window = CreateWindowA(String_val(cname), 
                           String_val(title),
                           winstyle,
                           posx,
                           posy,
                           width,
                           height,
                           NULL,
                           NULL,
                           GetModuleHandle(NULL),
                           (LPCWSTR)Int_val(uid));


    CAMLreturn((value)window);
}


CAMLprim value
caml_set_window_text(value handle, value txt)
{
    CAMLparam2(handle, txt);

    HWND wnd = (HWND)handle;

    SetWindowTextA(wnd, (LPCTSTR)String_val(txt));

    CAMLreturn(Val_unit);
}


CAMLprim value
caml_close_window(value handle)
{
    CAMLparam1(handle);

    HWND wnd = (HWND)handle;

    CloseWindow(wnd);

    CAMLreturn(Val_unit);
}


CAMLprim value
caml_destroy_window(value handle)
{
    CAMLparam1(handle);

    HWND wnd = (HWND)handle;

    DestroyWindow(wnd);

    CAMLreturn(Val_unit);
}


CAMLprim value
caml_window_has_focus(value handle)
{
    CAMLparam1(handle);

    HWND wnd = (HWND)handle;

    CAMLreturn(Val_bool(wnd == GetForegroundWindow()));
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


CAMLprim value
caml_move_window(value handle, value rect)
{
    CAMLparam2(handle, rect);
    
    HWND wnd = (HWND)handle;
    int x, y, w, h;

    x = Int_val(Field(rect,0));
    y = Int_val(Field(rect,1));
    w = Int_val(Field(rect,2));
    h = Int_val(Field(rect,3));

    MoveWindow(wnd,x,y,w,h,TRUE);

    CAMLreturn(Val_unit);
}


CAMLprim value
caml_attach_userdata(value handle, value udata)
{
    CAMLparam2(handle, udata);
    
    HWND wnd;
    LONG_PTR userdata;

    wnd = (HWND)handle;
    userdata = (LONG_PTR)(udata);

    SetWindowLongPtrA(wnd,GWLP_USERDATA,userdata);

    CAMLreturn(Val_unit);
}


CAMLprim value
caml_swap_buffers(value handle)
{
    CAMLparam1(handle);

    HDC hDC = GetDC((HWND)handle);
    SwapBuffers(hDC);

    CAMLreturn(Val_unit);
}


CAMLprim value
caml_process_events(value handle)
{
    CAMLparam1(handle);

    MSG message;

    while (PeekMessageA(&message, NULL, 0, 0, PM_REMOVE))
    {
        TranslateMessage(&message);
        DispatchMessageA(&message);
    }

    CAMLreturn(Val_unit);
}


CAMLprim value
caml_cursor_position(value unit)
{
    CAMLparam1(unit);
    CAMLlocal1(res);

    POINT point;

    GetCursorPos(&point);

    res = caml_alloc(2,0);
    Store_field(res, 0, Val_int(point.x));
    Store_field(res, 1, Val_int(point.y));

    CAMLreturn(res);
}


CAMLprim value
caml_set_cursor_position(value pos)
{
    CAMLparam1(pos);

    SetCursorPos(Int_val(Field(pos,0)),Int_val(Field(pos,1)));

    CAMLreturn(Val_unit);
}