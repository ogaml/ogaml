#import "cocoa_stubs.h"

// NSRect binding
/////////////////

CAMLprim value
caml_cocoa_create_nsrect(value x, value y, value w, value h)
{
  CAMLparam4(x,y,w,h);

  CAMLlocal1(mlrect);
  mlrect = caml_alloc_custom(&empty_custom_opts, sizeof(NSRect), 0, 1);

  NSRect rect = NSMakeRect(Double_val(x), Double_val(y), Double_val(w), Double_val(h));
  NSLog(@"made rect x:%f, y:%f, w:%f, h:%f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);

  memcpy(Data_custom_val(mlrect), &rect, sizeof(NSRect));

  CAMLreturn(mlrect);
}
