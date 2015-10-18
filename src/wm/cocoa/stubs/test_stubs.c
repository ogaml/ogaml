#define CAML_NAME_SPACE

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
@property (strong,retain) NSWindow *window;

@end

@implementation MyApplication

- (void) applicationDidFinishLaunching: (NSNotification *) note
{
  self.window = [[NSWindow alloc] initWithContentRect:NSMakeRect(100, 100, 100, 100)
                      styleMask:NSTitledWindowMask backing:NSBackingStoreBuffered defer:YES];

  // [self.window close];
  //
  // [super stop: self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    NSLog (@"Leaving the application");

    [self.window close];

    [super stop: self];
}

@end

// My AppDelegate
@interface AppDelegate : NSObject <NSApplicationDelegate>


@end

@interface AppDelegate ()

@property () IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    self.window = [[NSWindow alloc] initWithContentRect: NSMakeRect(100, 100, 100, 100)
                  styleMask: NSTitledWindowMask backing: NSBackingStoreBuffered defer: YES];

    [self.window close];

    // [super stop: self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    NSLog (@"Leaving the application");
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

  // [MyApplication sharedApplication];
  // [NSApp setDelegate: NSApp];
  //
  // [NSApp run];

  // Third way (w/ AppDelegate)
  // NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  // [NSApplication sharedApplication];
  //
  // AppDelegate *appDelegate = [[AppDelegate alloc] init];
  // [NSApp setDelegate:appDelegate];
  // [NSApp run];
  // [pool release];

  // Fourth way (w/ NSApplication)
  @autoreleasepool
  {
    const ProcessSerialNumber psn = { 0, kCurrentProcess };
    TransformProcessType(&psn, kProcessTransformToForegroundApplication);
    SetFrontProcess(&psn);

    [MyApplication sharedApplication];
    [NSApp setDelegate: NSApp];

    [NSApp run];
  }

  CAMLreturn(Val_unit);
}
