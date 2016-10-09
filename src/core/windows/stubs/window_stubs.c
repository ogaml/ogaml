#include "utils.h"
#include <windows.h>
#include <Windowsx.h>
#include <memory.h>

value* callback_get_window_from_id;
value* callback_push_event_to_window;

value getModifiers()
{
    CAMLparam0();
    CAMLlocal1(res);

    res = caml_alloc(4,0);
    Store_field(res,0,Val_bool(HIWORD(GetAsyncKeyState(VK_SHIFT)) != 0));
    Store_field(res,1,Val_bool(HIWORD(GetAsyncKeyState(VK_CONTROL)) != 0));
    Store_field(res,2,Val_bool(HIWORD(GetAsyncKeyState(VK_CAPITAL)) != 0));
    Store_field(res,3,Val_bool(HIWORD(GetAsyncKeyState(VK_MENU)) != 0));

    CAMLreturn(res);
}

value processEvent(UINT message, WPARAM wParam, LPARAM lParam)
{
    CAMLparam0();
    CAMLlocal3(res,res_field,modifiers);
    int x,y,dt,button;

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
                res_field = caml_alloc(1,1);
                Store_field(res_field,0,Val_int(wParam));
            } else {
                res_field = caml_alloc(1,0);
                Store_field(res_field,0,Val_int(wParam));
            }
            modifiers = getModifiers();

            Store_field(res, 0, res_field);
            Store_field(res, 1, modifiers);
            break;
        }

        case WM_KEYUP:
        case WM_SYSKEYUP:
        {
            res = caml_alloc(2,2);
            if(wParam >=65 && wParam <= 90) {
                res_field = caml_alloc(1,1);
                Store_field(res_field,0,Val_int(wParam));
            } else {
                res_field = caml_alloc(1,0);
                Store_field(res_field,0,Val_int(wParam));
            }
            modifiers = getModifiers();

            Store_field(res, 0, res_field);
            Store_field(res, 1, modifiers);
            break;
        }

        case WM_MOUSEWHEEL:
        {
            res = caml_alloc(4,3);

            x = GET_X_LPARAM(lParam);
            y = GET_Y_LPARAM(lParam);
            dt = GET_WHEEL_DELTA_WPARAM(wParam);
            modifiers = getModifiers();

            Store_field(res, 0, Val_int(x));
            Store_field(res, 1, Val_int(y));
            Store_field(res, 2, Val_int(dt));
            Store_field(res, 3, modifiers);
            break;
        }

        case WM_MOUSEHWHEEL:
        {
            res = caml_alloc(4,4);

            x = GET_X_LPARAM(lParam);
            y = GET_Y_LPARAM(lParam);
            dt = GET_WHEEL_DELTA_WPARAM(wParam);
            modifiers = getModifiers();

            Store_field(res, 0, Val_int(x));
            Store_field(res, 1, Val_int(y));
            Store_field(res, 2, Val_int(dt));
            Store_field(res, 3, modifiers);
            break;
        }

        case WM_LBUTTONUP:
        {
            res = caml_alloc(4,5);

            x = GET_X_LPARAM(lParam);
            y = GET_Y_LPARAM(lParam);
            modifiers = getModifiers();

            Store_field(res, 0, Val_int(0));
            Store_field(res, 1, Val_int(x));
            Store_field(res, 2, Val_int(y));
            Store_field(res, 3, modifiers);
            break;
        }

        case WM_LBUTTONDOWN:
        {
            res = caml_alloc(4,6);

            x = GET_X_LPARAM(lParam);
            y = GET_Y_LPARAM(lParam);
            modifiers = getModifiers();

            Store_field(res, 0, Val_int(0));
            Store_field(res, 1, Val_int(x));
            Store_field(res, 2, Val_int(y));
            Store_field(res, 3, modifiers);
            break;
        }

        case WM_RBUTTONUP:
        {
            res = caml_alloc(4,5);

            x = GET_X_LPARAM(lParam);
            y = GET_Y_LPARAM(lParam);
            modifiers = getModifiers();

            Store_field(res, 0, Val_int(1));
            Store_field(res, 1, Val_int(x));
            Store_field(res, 2, Val_int(y));
            Store_field(res, 3, modifiers);
            break;
        }

        case WM_RBUTTONDOWN:
        {
            res = caml_alloc(4,6);

            x = GET_X_LPARAM(lParam);
            y = GET_Y_LPARAM(lParam);
            modifiers = getModifiers();

            Store_field(res, 0, Val_int(1));
            Store_field(res, 1, Val_int(x));
            Store_field(res, 2, Val_int(y));
            Store_field(res, 3, modifiers);
            break;
        }

        case WM_MBUTTONUP:
        {
            res = caml_alloc(4,5);

            x = GET_X_LPARAM(lParam);
            y = GET_Y_LPARAM(lParam);
            modifiers = getModifiers();

            Store_field(res, 0, Val_int(2));
            Store_field(res, 1, Val_int(x));
            Store_field(res, 2, Val_int(y));
            Store_field(res, 3, modifiers);
            break;
        }

        case WM_MBUTTONDOWN:
        {
            res = caml_alloc(4,6);

            x = GET_X_LPARAM(lParam);
            y = GET_Y_LPARAM(lParam);
            modifiers = getModifiers();

            Store_field(res, 0, Val_int(2));
            Store_field(res, 1, Val_int(x));
            Store_field(res, 2, Val_int(y));
            Store_field(res, 3, modifiers);
            break;
        }

        case WM_XBUTTONUP:
        {
            res = caml_alloc(4,5);

            x = GET_X_LPARAM(lParam);
            y = GET_Y_LPARAM(lParam);
            modifiers = getModifiers();

            button = HIWORD(wParam) == XBUTTON1 ? 3 : 4;

            Store_field(res, 0, Val_int(button));
            Store_field(res, 1, Val_int(x));
            Store_field(res, 2, Val_int(y));
            Store_field(res, 3, modifiers);
            break;
        }

        case WM_XBUTTONDOWN:
        {
            res = caml_alloc(4,6);

            x = GET_X_LPARAM(lParam);
            y = GET_Y_LPARAM(lParam);
            modifiers = getModifiers();

            button = HIWORD(wParam) == XBUTTON1 ? 3 : 4;

            Store_field(res, 0, Val_int(button));
            Store_field(res, 1, Val_int(x));
            Store_field(res, 2, Val_int(y));
            Store_field(res, 3, modifiers);
            break;
        }

        case WM_MOUSEMOVE:
        {
            res = caml_alloc(2,7);

            x = GET_X_LPARAM(lParam);
            y = GET_Y_LPARAM(lParam);

            Store_field(res, 0, Val_int(x));
            Store_field(res, 1, Val_int(y));
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

CAMLprim value
caml_get_async_mouse_state(value but)
{
    CAMLparam1(but);
    
    int code = 0;

    switch (Int_val(but))
    {
        case 0:
            code = VK_LBUTTON;
            break;
        
        case 1:
            code = VK_RBUTTON;
            break;

        case 2:
            code = VK_MBUTTON;
            break;

        case 3:
            code = VK_XBUTTON1;
            break;

        case 4:
            code = VK_XBUTTON2;
            break;

        default:
            caml_failwith("Variant error in get_async_mouse_state");
            break;
    }

    CAMLreturn(Val_bool(HIWORD(GetAsyncKeyState(code)) != 0));
}

CAMLprim value
caml_button_swap(value unit)
{
    CAMLparam1(unit);

    CAMLreturn(Val_bool(GetSystemMetrics(SM_SWAPBUTTON)));
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
caml_get_window_style(value handle)
{
    CAMLparam1(handle);

    HWND wnd = (HWND)handle;
    DWORD winstyle = (DWORD)GetWindowLongPtr(wnd, GWL_STYLE);

    CAMLreturn((value)winstyle);
}


CAMLprim value
caml_set_window_style(value handle, value style)
{
    CAMLparam2(handle, style);

    HWND wnd = (HWND)handle;
    DWORD winstyle = (DWORD)style;

    SetWindowLongPtr(wnd, GWL_STYLE, winstyle);

    CAMLreturn(Val_unit);
}


CAMLprim value
caml_screen_to_client(value handle, value pos)
{
    CAMLparam2(handle, pos);
    CAMLlocal1(res);

    HWND wnd = (HWND)handle;
    POINT pt;
        pt.x = Int_val(Field(pos,0));
        pt.y = Int_val(Field(pos,1));

    ScreenToClient(wnd, &pt);

    res = caml_alloc(2,0);
        Store_field(res, 0, Val_int(pt.x));
        Store_field(res, 1, Val_int(pt.y));

    CAMLreturn(res);
}


CAMLprim value
caml_client_to_screen(value handle, value pos)
{
    CAMLparam2(handle, pos);
    CAMLlocal1(res);

    HWND wnd = (HWND)handle;
    POINT pt;
        pt.x = Int_val(Field(pos,0));
        pt.y = Int_val(Field(pos,1));

    ClientToScreen(wnd, &pt);

    res = caml_alloc(2,0);
        Store_field(res, 0, Val_int(pt.x));
        Store_field(res, 1, Val_int(pt.y));

    CAMLreturn(res);
}


CAMLprim value
caml_adjust_window_rect(value handle, value rect, value style)
{
    CAMLparam3(handle, rect, style);
    CAMLlocal1(res);

    HWND wnd = (HWND)handle;
    DWORD winstyle = (DWORD)style;
    RECT rectangle;
        rectangle.left = Int_val(Field(rect,0));
        rectangle.top = Int_val(Field(rect,1));
        rectangle.right = Int_val(Field(rect,2)) + rectangle.left;
        rectangle.bottom = Int_val(Field(rect,3)) + rectangle.top;

    AdjustWindowRect(&rectangle, winstyle, FALSE);

    res = caml_alloc(4, 0);
        Store_field(res, 0, Val_int(rectangle.left));
        Store_field(res, 1, Val_int(rectangle.top));
        Store_field(res, 2, Val_int(rectangle.right - rectangle.left));
        Store_field(res, 3, Val_int(rectangle.bottom - rectangle.top));

    CAMLreturn(res);
}


CAMLprim value
caml_fullscreen_size(value unit)
{
    CAMLparam1(unit);
    CAMLlocal1(res);

    res = caml_alloc(2,0);

    Store_field(res, 0, Val_int(GetSystemMetrics(SM_CXSCREEN)));
    Store_field(res, 1, Val_int(GetSystemMetrics(SM_CYSCREEN)));

    CAMLreturn(res);
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
    RECT rectwin, rectclt;

    GetWindowRect(wnd, &rectwin);
    GetClientRect(wnd, &rectclt);

    res = caml_alloc(4,0);
    Store_field(res, 0, Val_int(rectwin.left));
    Store_field(res, 1, Val_int(rectwin.top));
    Store_field(res, 2, Val_int(rectclt.right - rectclt.left));
    Store_field(res, 3, Val_int(rectclt.bottom - rectclt.top));

    CAMLreturn(res);
}


CAMLprim value
caml_move_window(value handle, value rect, value nomove, value nosize)
{
    CAMLparam4(handle, rect, nomove, nosize);
    
    HWND wnd = (HWND)handle;
    int x, y, w, h;
    UINT flags = 0;

    if(Bool_val(nomove)) {
        flags |= SWP_NOMOVE;
    }
    if(Bool_val(nosize)) {
        flags |= SWP_NOSIZE;
    }

    x = Int_val(Field(rect,0));
    y = Int_val(Field(rect,1));
    w = Int_val(Field(rect,2));
    h = Int_val(Field(rect,3));

    SetWindowPos(wnd,NULL,x,y,w,h,flags);

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

CAMLprim value
caml_show_cursor(value handle, value show)
{
    CAMLparam2(handle, show);

    ShowCursor(Bool_val(show));

    CAMLreturn(Val_unit);
}

CAMLprim value
caml_set_fullscreen_devmode(value handle, value width, value height)
{
    CAMLparam1(handle);

    LONG result;

    DEVMODE dm;
    dm.dmSize = sizeof(DEVMODE);
    dm.dmPelsWidth = Int_val(width);
    dm.dmPelsHeight = Int_val(height);
    dm.dmFields = DM_PELSWIDTH | DM_PELSHEIGHT;

    result = ChangeDisplaySettingsA(&dm, CDS_FULLSCREEN);

    CAMLreturn(Val_bool(result == DISP_CHANGE_SUCCESSFUL));
}

CAMLprim value
caml_unset_fullscreen_devmode(value handle)
{
    CAMLparam1(handle);

    CAMLreturn(Val_bool(ChangeDisplaySettingsA(0, 0) == DISP_CHANGE_SUCCESSFUL));
}