#define CAML_NAME_SPACE

#ifndef __APPLE__
#define strong retain
#endif

#include <caml/custom.h>
#include <caml/fail.h>
#include <caml/callback.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/mlvalues.h>

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

static NSAutoreleasePool* arp = nil;

@interface MyApplication : NSApplication {
  NSWindow* _window;
}

@property (strong, nonatomic) NSWindow *window;

@end


@implementation MyApplication

@synthesize window = _window;

- (void) applicationDidFinishLaunching: (NSNotification *) note
{
  // self.window = [[NSWindow alloc] initWithContentRect:NSMakeRect(100, 100, 100, 100)
                      // styleMask:NSTitledWindowMask backing:NSBackingStoreBuffered defer:YES];
  NSRect frame = NSMakeRect(100, 100, 200, 200);
  self.window = [[[NSWindow alloc] initWithContentRect:frame
                // styleMask:NSBorderlessWindowMask
                styleMask:NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask
                backing:NSBackingStoreBuffered
                defer:NO] autorelease];
  [self.window setBackgroundColor:[NSColor blueColor]];
  [self.window makeKeyAndOrderFront:NSApp];
  [self.window center];

  // Apparently I don't have the right to do that...
  // [self.window makeMainWindow];

  // [self.window display];

  // [self.window close];
  //
  // [super stop: self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    NSLog (@"Leaving the application");

    // I don't know how bad it is not to close the window when quiting but
    // if you close it before quiting, you get a segfault
    // if ([self.window screen] != nil) {
    //   [self.window close];
    // }

    [super stop: self];
}

@end

// My AppDelegate
@interface AppDelegate : NSObject <NSApplicationDelegate> {
  NSWindow *_window;
}

@property (assign) IBOutlet NSWindow *window;

@end


@implementation AppDelegate

@synthesize window = _window;

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

//    Commented out, deprecated w/ Cocoa, doesn't work with GNUStep
//    const ProcessSerialNumber psn = { 0, kCurrentProcess };
//    TransformProcessType(&psn, kProcessTransformToForegroundApplication);

    // SetFrontProcess(&psn); // This is deperecated
    // Removing it means the window doesn't get the focus right away

    [MyApplication sharedApplication];
    [NSApp setDelegate: NSApp];

    [NSApp run];

  CAMLreturn(Val_unit);
}
