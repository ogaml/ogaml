#import "stubs.h"

// NSRect binding
/////////////////

CAMLprim value
caml_cocoa_create_nsrect(value x, value y, value w, value h)
{
  CAMLparam4(x,y,w,h);

  NSRect rect = NSMakeRect(Int_val(x), Int_val(y), Int_val(w), Int_val(h));

  CAMLreturn( (value) &rect );
}
