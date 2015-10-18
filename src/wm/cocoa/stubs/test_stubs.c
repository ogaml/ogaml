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
  // Since alloc isn't recognized, allocWithZone:nil would do the trick
  // Indeed we are lucky and allocWithZone ignores its argument, behaving as
  // alloc (wow, much hack)
  // Still no window though
  NSWindow *window = [[NSWindow allocWithZone:nil] initWithContentRect:NSMakeRect(100, 100, 100, 100)
                      styleMask:NSTitledWindowMask backing:NSBackingStoreBuffered defer:YES];

  // The previous lines use caml_alloc for alloc, hence are not working at
  // runtime. Since [NSWindow new] is short for [[NSWindow alloc] init],
  // the following line works, no runtime error, no window shows, but no error
  // and the program expects a CTRL+C.
  // NSWindow *window = [NSWindow new];

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
