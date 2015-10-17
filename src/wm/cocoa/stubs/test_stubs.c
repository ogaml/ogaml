#include <caml/custom.h>
#include <caml/fail.h>
#include <caml/callback.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/mlvalues.h>

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

static NSAutoreleasePool* arp = nil;

@interface MyApplication : NSApplication

@property (strong, nonatomic) NSWindow *window;

@end

@implementation MyApplication

- (void) applicationDidFinishLaunching: (NSNotification *) note
{
    NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(100, 100, 100, 100)
                        styleMask:NSTitledWindowMask backing:NSBackingStoreBuffered defer:YES];

    self.window = window;
}

@end

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

CAMLprim value
caml_open_window(value unit)
{
  CAMLparam0();

  // NSRect frame = NSMakeRect(0, 0, 200, 200);
  // NSWindow* window  = [[[NSWindow alloc] initWithContentRect:frame
  //                     styleMask:NSBorderlessWindowMask
  //                     backing:NSBackingStoreBuffered
  //                     defer:NO] autorelease];
  // [window setBackgroundColor:[NSColor blueColor]];
  // [window makeKeyAndOrderFront:NSApp];
  [MyApplication sharedApplication];
  [NSApp setDelegate: NSApp];

  [NSApp run];

  CAMLreturn(Val_unit);
}
