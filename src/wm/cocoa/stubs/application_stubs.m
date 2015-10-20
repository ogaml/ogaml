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
caml_cocoa_create_window(value frame, value styleMask, value backing, value defer)
{
  CAMLparam4(frame,styleMask,backing,defer);
  CAMLlocal2(hd, tl);

  NSRect* rect = (NSRect*) Data_custom_val(frame);

  // Getting the flags
  int mask = 0;
  tl = styleMask;
  while(tl != Val_emptylist) {
    hd = Field(tl,0);
    tl = Field(tl,1);
    // We put hd - 1 because Borderless is 0
    mask |= (1L << (Int_val(hd)-1));
  }

  // Getting the defer boolean
  BOOL deferb = Bool_val(defer);


  [OGApplication sharedApplication]; // ensure NSApp

  NSWindow* window;
  window = [[[NSWindow alloc] initWithContentRect:(*rect)
                                        styleMask:mask
                                          backing:Int_val(backing)
                                            defer:deferb] autorelease];

  CAMLreturn( (value) window );
}

CAMLprim value
caml_cocoa_window_set_bg_color(value mlwindow, value mlcolor)
{
  CAMLparam2(mlwindow, mlcolor);

  NSWindow* window = (NSWindow*) mlwindow;
  NSColor* color = (NSColor*) mlcolor;

  [window setBackgroundColor:color];

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_cocoa_window_make_key_and_order_front(value mlwindow)
{
  CAMLparam1(mlwindow);

  NSWindow* window = (NSWindow*) mlwindow;

  [OGApplication sharedApplication]; // ensure NSApp
  [window makeKeyAndOrderFront:NSApp];

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_cocoa_window_center(value mlwindow)
{
  CAMLparam1(mlwindow);

  NSWindow* window = (NSWindow*) mlwindow;

  [window center];

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_cocoa_window_make_main(value mlwindow)
{
  CAMLparam1(mlwindow);

  NSWindow* window = (NSWindow*) mlwindow;

  [window makeMainWindow];

  CAMLreturn(Val_unit);
}
