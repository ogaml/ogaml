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
  NSRect frame = NSMakeRect(100, 100, 500, 200);
  self.window = [[[NSWindow alloc] initWithContentRect:frame
                styleMask:NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask
                backing:NSBackingStoreBuffered
                defer:NO] autorelease];
  [self.window setBackgroundColor:[NSColor redColor]];
  [self.window makeKeyAndOrderFront:NSApp];
  [self.window center];
  [self.window makeMainWindow];
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

// This doesn't appear to change the name
// +(NSString*)applicationName
// {
//     // // First, try localized name
//     // NSString* appName = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
//     //
//     // // Then, try non-localized name
//     // if ((appName == nil) || ([appName length] == 0))
//     //     appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
//     //
//     // // Finally, fallback to the process info
//     // if ((appName == nil) || ([appName length] == 0))
//     //     appName = [[NSProcessInfo processInfo] processName];
//     //
//     // return appName;
//
//     return @"Test";
// }

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

  [MyApplication sharedApplication];
  [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
  [NSApp activateIgnoringOtherApps:YES];
  [[NSApplication sharedApplication] setDelegate:NSApp];

  [NSApp run];
  [NSApp activateIgnoringOtherApps:YES];

  CAMLreturn(Val_unit);
}
