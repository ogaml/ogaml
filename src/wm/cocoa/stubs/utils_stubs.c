#import "stubs.h"

// NSRect binding
/////////////////

static struct custom_operations objst_custom_ops = {
  .identifier  = "obj_st handling",
  .finalize    = custom_finalize_default,
  .compare     = custom_compare_default,
  .hash        = custom_hash_default,
  .serialize   = custom_serialize_default,
  .deserialize = custom_deserialize_default
};

CAMLprim value
caml_cocoa_create_nsrect(value x, value y, value w, value h)
{
  CAMLparam4(x,y,w,h);

  CAMLlocal1(mlrect);
  mlrect = caml_alloc_custom(&objst_custom_ops, sizeof(NSRect), 0, 1);

  NSRect rect = NSMakeRect(Int_val(x), Int_val(y), Int_val(w), Int_val(h));

  memcpy(Data_custom_val(mlrect), &rect, sizeof(NSRect));

  CAMLreturn(mlrect);
}
