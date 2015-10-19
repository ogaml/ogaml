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
