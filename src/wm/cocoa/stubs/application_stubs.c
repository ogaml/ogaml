#import "stubs.h"


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

  CAMLreturn( (value) [OGApplication new] );
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
  // This is an option so we check whether it is None of Some
  if(frame == Val_int(0))
    CAMLreturn( (value) [NSWindow new] );
  else
  {
    NSRect* rect = (NSRect*) Data_custom_val(frame);
    NSWindow* window;
    window = [[[NSWindow alloc] initWithContentRect:(*rect)
                  styleMask:NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask
                  backing:NSBackingStoreBuffered
                  defer:NO] autorelease];
    CAMLreturn( (value) window );
  }
}
