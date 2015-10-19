#import "cocoa_stubs.h"

// NSRect binding
/////////////////

CAMLprim value
caml_cocoa_create_nsrect(value x, value y, value w, value h)
{
  CAMLparam4(x,y,w,h);

  CAMLlocal1(mlrect);
  mlrect = caml_alloc_custom(&empty_custom_opts, sizeof(NSRect), 0, 1);

  NSRect rect = NSMakeRect(Int_val(x), Int_val(y), Int_val(w), Int_val(h));

  memcpy(Data_custom_val(mlrect), &rect, sizeof(NSRect));

  CAMLreturn(mlrect);
}
