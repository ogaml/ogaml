#include <caml/custom.h>
#include <caml/fail.h>
#include <caml/callback.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/mlvalues.h> 

#import <Foundation/Foundation.h>

static NSAutoreleasePool* arp = nil;

CAMLprim value
caml_init_arp(value unit)
{
  CAMLparam0();

  if(arp == nil) {
    arp = [[NSAutoreleasePool alloc] init];
  }

  CAMLreturn(Val_unit);
}


CAMLprim value
caml_cocoa_test(value unit)
{
  CAMLparam0();

  NSLog (@"Binding OK!");

  CAMLreturn(Val_unit);
}


CAMLprim value
caml_cocoa_gen_string(value str)
{
  CAMLparam1(str);

  //Don't know if this pointer will be collected or not...
  char* tmp = String_val(str);

  //Probably not memory-safe given that I removed the GC pool
  NSString* data = [NSString stringWithFormat:@"%s" , tmp];

  CAMLreturn((value) data);
}


CAMLprim value
caml_cocoa_print_string(value str)
{
  CAMLparam1(str);

  NSLog (@"%@", (NSString*)str);

  CAMLreturn(Val_unit);
}
