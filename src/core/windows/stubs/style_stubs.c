#include "utils.h"
#include <windows.h>
#include <memory.h>

DWORD Style_val(value style)
{
  switch(Int_val(style))
  {
    case 0:
      return WS_BORDER;

    case 1:
      return WS_CAPTION;

    case 2:
      return WS_MAXIMIZE;

    case 3:
      return WS_MAXIMIZEBOX;

    case 4:
      return WS_MINIMIZE;

    case 5:
      return WS_MINIMIZEBOX;

    case 6:
      return WS_POPUP;

    case 7:
      return WS_SYSMENU;

    case 8:
      return WS_THICKFRAME;

    case 9:
      return WS_VISIBLE;

    case 10:
      return WS_CLIPCHILDREN;

    case 11:
      return WS_CLIPSIBLINGS;

    default:
      caml_failwith("Caml variant error in Style_val(1)");
  }

  return 0;
}

CAMLprim value
caml_mkstyle_W(value styles)
{
  CAMLparam1(styles);
  CAMLlocal2(hd, tl);
  DWORD flags = 0;
  tl = styles;
  while(tl != Val_emptylist) {
    hd = Field(tl,0);
    tl = Field(tl,1);
    flags |= Style_val(hd);
  }
  CAMLreturn((value)flags);
}