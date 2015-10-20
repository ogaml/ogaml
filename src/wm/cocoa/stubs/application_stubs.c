#import "cocoa_stubs.h"


// OGApplication implementation
///////////////////////////////
@implementation OGApplication

+(void)processEvent
{
  [OGApplication sharedApplication]; // ensure NSApp
  NSEvent* event = nil;

  while ((event = [NSApp nextEventMatchingMask:NSAnyEventMask
                                     untilDate:[NSDate distantPast]
                                        inMode:NSDefaultRunLoopMode
                                       dequeue:YES]))
  {
      [NSApp sendEvent:event];
  }
}

+(void) setUpMenuBar
{
  [OGApplication sharedApplication]; // ensure NSApp

  // Main menu
  NSMenu* mainMenu = [NSApp mainMenu];
  if (mainMenu != nil) return; // We set it already
  mainMenu = [[[NSMenu alloc] initWithTitle:@""] autorelease];
  [NSApp setMainMenu:mainMenu];

  // TODO implement menu setting functions used below
  // // Application menu
  // NSMenuItem* appleItem = [mainMenu addItemWithTitle:@""
  //                                           action:nil
  //                                    keyEquivalent:@""];
  // NSMenu* appleMenu = [[OGApplication newAppleMenu] autorelease];
  // [appleItem setSubmenu:appleMenu];
  //
  // // File menu
  // NSMenuItem* fileItem = [mainMenu addItemWithTitle:@""
  //                                            action:nil
  //                                     keyEquivalent:@""];
  // NSMenu* fileMenu = [[OGApplication newFileMenu] autorelease];
  // [fileItem setSubmenu:fileMenu];
  //
  // // Window menu
  // NSMenuItem* windowItem = [mainMenu addItemWithTitle:@""
  //                                              action:nil
  //                                       keyEquivalent:@""];
  // NSMenu* windowMenu = [[OGApplication newWindowMenu] autorelease];
  // [windowItem setSubmenu:windowMenu];
  // [NSApp setWindowsMenu:windowMenu];
}

// TODO Any use for that?
// +(NSString*)applicationName

-(void)sendEvent:(NSEvent *)anEvent
{
    // id firstResponder = [[anEvent window] firstResponder];
    [super sendEvent:anEvent];
}

@end

// OGApplication binding
////////////////////////

CAMLprim value
caml_cocoa_create_app(value unit)
{
  CAMLparam0();

  OGApplication* app = [OGApplication sharedApplication];
  [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
  [NSApp activateIgnoringOtherApps:YES];
  // Temporary (TODO delegate function)
  [[NSApplication sharedApplication] setDelegate:NSApp];

  CAMLreturn( (value) app );
}

CAMLprim value
caml_cocoa_run_app(value unit)
{
  CAMLparam0();

  [OGApplication sharedApplication];
  [NSApp run];
  [NSApp activateIgnoringOtherApps:YES];

  CAMLreturn(Val_unit);
}


// OGApplicationDelegate implementation
///////////////////////////////////////
@implementation OGApplicationDelegate

-(NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication*)sender
{
  (void)sender;
  // TODO Notify closure for all windows
  // return NSTerminateCancel;
  return NSTerminateNow;
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)app
{
  (void)app;
  return YES;
}

@end

// OGApplicationDelegate binding
////////////////////////////////

CAMLprim value
caml_cocoa_create_appdgt(value unit)
{
  CAMLparam0();

  CAMLreturn( (value) [OGApplicationDelegate new] );
}


// We directly bind NSWindow (for now at least)
///////////////////////////////////////////////

CAMLprim value
caml_cocoa_create_window(value frame)
{
  CAMLparam1(frame);

  NSRect* rect = (NSRect*) Data_custom_val(frame);
  NSLog(@"x:%f, y:%f, w:%f, h:%f", rect->origin.x, rect->origin.y, rect->size.width, rect->size.height);


  [OGApplication sharedApplication]; // ensure NSApp

  NSWindow* window;
  window = [[[NSWindow alloc] initWithContentRect:(*rect)
                styleMask:NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask
                backing:NSBackingStoreBuffered
                defer:NO] autorelease];
  [window setBackgroundColor:[NSColor greenColor]];
  [window makeKeyAndOrderFront:NSApp];
  // [window center];
  [window makeMainWindow];
  CAMLreturn( (value) window );
}
