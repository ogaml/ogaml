#include <X11/Xlib.h>
#include <GL/gl.h>
#include <GL/glx.h>
#include "../../../utils/stubs.h"

CAMLprim value
caml_glx_choose_visual(value disp, value scr, value attributes, value len)
{
  CAMLparam4(disp, scr, attributes, len);
  CAMLlocal2(hd,tl);
  
  int attrs[Int_val(len)+1];
  int i = 0;

  tl = attributes;

  while(tl != Val_emptylist) {
    hd = Field(tl, 0);
    tl = Field(tl, 1);
    if(Is_long(hd)) {
      switch(Int_val(hd)) {
        case 0 : attrs[i] = GLX_RGBA; break;
        case 1 : attrs[i] = GLX_STEREO; break;
        default: caml_failwith("Variant handling bug in glx_choose_visual");
      }
      i++;
    } else {
      attrs[i+1] = Int_val(Field(hd,0));
      switch(Tag_val(hd)) {
        case 0  : attrs[i] = GLX_BUFFER_SIZE; break;
        case 1  : attrs[i] = GLX_LEVEL      ; break;
        case 2  : attrs[i] = GLX_AUX_BUFFERS; break;
        case 3  : attrs[i] = GLX_RED_SIZE   ; break;
        case 4  : attrs[i] = GLX_GREEN_SIZE ; break;
        case 5  : attrs[i] = GLX_BLUE_SIZE  ; break;
        case 6  : attrs[i] = GLX_ALPHA_SIZE ; break;
        case 7  : attrs[i] = GLX_DEPTH_SIZE ; break;
        case 8  : attrs[i] = GLX_STENCIL_SIZE    ; break;
        case 9  : attrs[i] = GLX_ACCUM_RED_SIZE  ; break;
        case 10 : attrs[i] = GLX_ACCUM_BLUE_SIZE ; break;
        case 11 : attrs[i] = GLX_ACCUM_ALPHA_SIZE; break;
        case 12 : attrs[i] = GLX_ACCUM_GREEN_SIZE; break;
        default: caml_failwith("Variant handling bug in glx_choose_visual");
      }
      i += 2;
    }
  }

  attrs[i] = None;

  CAMLreturn(
      (value) glXChooseVisual(
        (Display*)disp, 
        Int_val(scr),
        attrs
      )
  );
}


CAMLprim value
caml_glx_create_context()
{
  CAMLparam0();
  CAMLreturn(Val_unit);
}

CAMLprim value
caml_glx_swap_buffers()
{
  CAMLparam0();
  CAMLreturn(Val_unit);
}

CAMLprim value
caml_glx_make_current()
{
  CAMLparam0();
  CAMLreturn(Val_unit);
}
