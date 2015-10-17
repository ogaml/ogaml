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
