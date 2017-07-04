#include "utils.h"
#include <windows.h>
#include <memory.h>


CAMLprim value
caml_get_full_path(value path)
{
    CAMLparam1(path);

    char* c_path = String_val(path);
    TCHAR  full_path[32767];

    GetFullPathName(c_path, 32767, full_path, NULL);

    CAMLreturn((value)caml_copy_string((char*)full_path));
}