#include <stdio.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/mlvalues.h> 
#include <Foundation/NSObjcRuntime.h>

CAMLprim value
caml_cocoa_test(value unit)
{
  void* cls = objc_getClass("NSString");
  void* obj = objc_msgSend(cls, NSSelectorFromString(CFSTR("alloc")));
  obj = objc_msgSend(obj, NSSelectorFromString(CFSTR("init")));
  printf("OK");
  return Val_unit;
}
