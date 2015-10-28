// #define CAML_NAME_SPACE
//
// #ifndef __APPLE__
// #define strong retain
// #endif
//
// #include <caml/custom.h>
// #include <caml/fail.h>
// #include <caml/callback.h>
// #include <caml/memory.h>
// #include <caml/alloc.h>
// #include <caml/mlvalues.h>
//
// #import <Foundation/Foundation.h>
// #import <Cocoa/Cocoa.h>

#import "cocoa_stubs.h"

static NSAutoreleasePool* arp = nil;

CAMLprim value
caml_init_arp(value unit)
{
  CAMLparam0();

  if(arp == nil) {
    arp = [[NSAutoreleasePool alloc] init];
  }

  // ProcessSerialNumber psn;
  // if (!GetCurrentProcess(&psn))
  // {
  //     TransformProcessType(&psn, kProcessTransformToForegroundApplication);
  //     SetFrontProcess(&psn);
  // }

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

CAMLprim value
caml_open_window(value unit)
{
  CAMLparam0();

  // This should only be done once, but this is only for testing purposes
  [OGApplication sharedApplication];
  #ifdef __OSX__
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
  #endif
  [NSApp activateIgnoringOtherApps:YES];

  [[NSApplication sharedApplication] setDelegate:[OGApplicationDelegate new]];

  [OGApplication setUpMenuBar];

  [[OGApplication sharedApplication] finishLaunching];

  // AutoReleasePool
  [[NSAutoreleasePool alloc] init];

  // Window
  NSRect frame = NSMakeRect(0,0,500,400);
  NSWindow* window = [[NSWindow alloc] initWithContentRect:frame
                                       styleMask:NSTitledWindowMask|NSClosableWindowMask
                                       backing:NSBackingStoreBuffered
                                       defer:NO];

  // Window Delegate
  OGWindowController* wc = [[OGWindowController alloc] init];
  [wc initWithWindow:window];

  CAMLreturn(Val_unit);
}
