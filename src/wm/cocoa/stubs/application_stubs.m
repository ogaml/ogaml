#import "cocoa_stubs.h"


////////////////////////////////////////////////////////////////////////////////
// OGApplication implementation (strongly inspired from SFML for now)
////////////////////////////////////////////////////////////////////////////////
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

  // Application menu
  NSMenuItem* appleItem = [mainMenu addItemWithTitle:@""
                                              action:nil
                                       keyEquivalent:@""];
  NSMenu* appleMenu = [[OGApplication newAppleMenu] autorelease];
  [appleItem setSubmenu:appleMenu];

  // File menu
  NSMenuItem* fileItem = [mainMenu addItemWithTitle:@""
                                             action:nil
                                      keyEquivalent:@""];
  NSMenu* fileMenu = [[OGApplication newFileMenu] autorelease];
  [fileItem setSubmenu:fileMenu];

  // Window menu
  NSMenuItem* windowItem = [mainMenu addItemWithTitle:@""
                                               action:nil
                                        keyEquivalent:@""];
  NSMenu* windowMenu = [[OGApplication newWindowMenu] autorelease];
  [windowItem setSubmenu:windowMenu];
  [NSApp setWindowsMenu:windowMenu];
}

+(NSMenu*)newAppleMenu
{
  NSString* appName = [OGApplication applicationName];

  NSMenu* appleMenu = [[NSMenu alloc] initWithTitle:@""];

  // Apple menu
  [appleMenu addItemWithTitle:[@"About " stringByAppendingString:appName]
                       action:@selector(orderFrontStandardAboutPanel:)
                keyEquivalent:@""];

  // Separator
  [appleMenu addItem:[NSMenuItem separatorItem]];

  // Preferences
  [appleMenu addItemWithTitle:@"Preferences..."
                       action:nil
                keyEquivalent:@""];

  // Separator
  [appleMenu addItem:[NSMenuItem separatorItem]];

  // Services
  NSMenu* serviceMenu = [[[NSMenu alloc] initWithTitle:@""] autorelease];
  NSMenuItem* serviceItem = [appleMenu addItemWithTitle:@"Services"
                                       action:nil
                                       keyEquivalent:@""] ;
  [serviceItem setSubmenu:serviceMenu];
  [NSApp setServicesMenu:serviceMenu];

  // Separator
  [appleMenu addItem:[NSMenuItem separatorItem]];

  // Hide
  [appleMenu addItemWithTitle:[@"Hide " stringByAppendingString:appName]
                                        action:@selector(hide:)
                                        keyEquivalent:@"h"];

  // Hide other
  NSMenuItem* hideOtherItem = [appleMenu addItemWithTitle:@"Hide Others"
                                        action:@selector(hideOtherApplications:)
                                        keyEquivalent:@"h"];
  [hideOtherItem setKeyEquivalentModifierMask:(NSAlternateKeyMask | NSCommandKeyMask)];

  // Show all
  [appleMenu addItemWithTitle:@"Show All"
             action:@selector(unhideAllApplications:)
             keyEquivalent:@""];

  // Separator
  [appleMenu addItem:[NSMenuItem separatorItem]];

  // Quit
  [appleMenu addItemWithTitle:[@"Quit " stringByAppendingString:appName]
                                        action:@selector(terminate:)
                                        keyEquivalent:@"q"];

  return appleMenu;
}

+(NSMenu*)newFileMenu
{
  // File menu
  NSMenu* fileMenu = [[NSMenu alloc] initWithTitle:@"File"];

  // Close window
  NSMenuItem* closeItem = [[NSMenuItem alloc] initWithTitle:@"Close Window"
                                              action:@selector(performClose:)
                                              keyEquivalent:@"w"];
  [fileMenu addItem:closeItem];
  [closeItem release];

  return fileMenu;
}

+(NSMenu*)newWindowMenu
{
    // Window menu
    NSMenu* windowMenu = [[NSMenu alloc] initWithTitle:@"Window"];

    // Minimize
    NSMenuItem* minimizeItem = [[NSMenuItem alloc] initWithTitle:@"Minimize"
                                        action:@selector(performMiniaturize:)
                                        keyEquivalent:@"m"];
    [windowMenu addItem:minimizeItem];
    [minimizeItem release];

    // Zoom
    [windowMenu addItemWithTitle:@"Zoom"
                          action:@selector(performZoom:)
                   keyEquivalent:@""];

    // Separator
    [windowMenu addItem:[NSMenuItem separatorItem]];

    // Bring all to front
    [windowMenu addItemWithTitle:@"Bring All to Front"
                          action:@selector(bringAllToFront:)
                   keyEquivalent:@""];

    return windowMenu;
}

+(NSString*)applicationName
{
  // First, try localized name
  NSString* appName = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];

  // Then, try non-localized name
  if ((appName == nil) || ([appName length] == 0))
      appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];

  // Finally, fallback to the process info
  if ((appName == nil) || ([appName length] == 0))
      appName = [[NSProcessInfo processInfo] processName];

  return appName;
}

-(void)sendEvent:(NSEvent *)anEvent
{
    // id firstResponder = [[anEvent window] firstResponder];
    [super sendEvent:anEvent];
}

@end

////////////////////////////////////////////////////////////////////////////////
// OGApplication binding
////////////////////////////////////////////////////////////////////////////////

CAMLprim value
caml_cocoa_init_app(value mldelegate)
{
  CAMLparam1(mldelegate);

  OGApplicationDelegate* delegate = (OGApplicationDelegate*) mldelegate;

  [OGApplication sharedApplication];
  [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
  [NSApp activateIgnoringOtherApps:YES];

  // [[NSApplication sharedApplication] setDelegate:NSApp];
  [[NSApplication sharedApplication] setDelegate:delegate];

  [OGApplication setUpMenuBar];

  [[OGApplication sharedApplication] finishLaunching];

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_cocoa_run_app(value unit)
{
  CAMLparam0();

  [OGApplication sharedApplication];
  [OGApplication setUpMenuBar];
  [NSApp run];
  [NSApp activateIgnoringOtherApps:YES];

  CAMLreturn(Val_unit);
}


////////////////////////////////////////////////////////////////////////////////
// OGApplicationDelegate implementation
////////////////////////////////////////////////////////////////////////////////
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
  return NO;
}

@end

////////////////////////////////////////////////////////////////////////////////
// OGApplicationDelegate binding
////////////////////////////////////////////////////////////////////////////////

CAMLprim value
caml_cocoa_create_appdgt(value unit)
{
  CAMLparam0();

  CAMLreturn( (value) [OGApplicationDelegate new] );
}


////////////////////////////////////////////////////////////////////////////////
// We directly bind NSWindow (for now at least)
////////////////////////////////////////////////////////////////////////////////

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

  // [window retain];

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

CAMLprim value
caml_cocoa_window_perform_close(value mlwindow)
{
  CAMLparam1(mlwindow);

  NSWindow* window = (NSWindow*) mlwindow;

  [window performClose:nil];

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_cocoa_window_frame(value mlwindow)
{
  CAMLparam1(mlwindow);
  CAMLlocal1(mlrect);
  mlrect = caml_alloc_custom(&empty_custom_opts, sizeof(NSRect), 0, 1);

  NSWindow* window = (NSWindow*) mlwindow;
  NSRect rect = [window frame];

  memcpy(Data_custom_val(mlrect), &rect, sizeof(NSRect));

  CAMLreturn(mlrect);
}

// INPUT  A window to poll (no EventMask for now)
// OUTPUT An event taken out of the queue
CAMLprim value
caml_cocoa_window_next_event(value mlwindow)
{
  CAMLparam1(mlwindow);

  NSWindow* window = (NSWindow*) mlwindow;
  NSEvent* event = [window nextEventMatchingMask:NSAnyEventMask];

  if(event == nil) CAMLreturn(Val_none);
  else CAMLreturn( Val_some((value)event) );
}

CAMLprim value
caml_cocoa_window_set_for_events(value mlwindow)
{
  CAMLparam1(mlwindow);

  NSWindow* window = (NSWindow*) mlwindow;

  // Should we set a delegate?
  // [OGApplication sharedApplication]; // ensure NSApp
  // [window setDelegate:NSApp];
  [window setAcceptsMouseMovedEvents:YES];
  [window setIgnoresMouseEvents:NO];

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_cocoa_window_set_autodisplay(value mlwindow, value mlbool)
{
  CAMLparam2(mlwindow,mlbool);

  NSWindow* window = (NSWindow*) mlwindow;
  BOOL autodisplay = Bool_val(mlbool);

  [window setAutodisplay:autodisplay];

  CAMLreturn(Val_unit);
}

////////////////////////////////////////////////////////////////////////////////
// IMPLEMENTING OGWindowController
// Our own version of a Window Controller (it isn't a NSWindowController)
////////////////////////////////////////////////////////////////////////////////
@implementation OGWindowController

-(id)initWithWindow:(NSWindow*)window
{
  m_window = [window retain];

  [m_window setDelegate:self];

  [m_window setReleasedWhenClosed:NO]; // We can destroy it ourselves

  m_windowIsOpen = true;

  return self;
}

-(void)windowWillClose:(NSNotification *)notification
{
  m_windowIsOpen = false;
}

-(void)processEvent
{
  [OGApplication processEvent];
}

-(NSRect)frame
{
  return [m_window frame];
}

-(void)closeWindow
{
  [m_window close];
  [m_window setDelegate:nil];
}

-(void)releaseWindow
{
  if([self isWindowOpen]) [self closeWindow];
  if(m_window == nil) return;
  [m_window release];
  m_window = nil;
}

-(BOOL)isWindowOpen
{
  return m_windowIsOpen;
}

@end

////////////////////////////////////////////////////////////////////////////////
// BINDING OGWindowController
////////////////////////////////////////////////////////////////////////////////
CAMLprim value
caml_cocoa_window_controller_init_with_window(value mlwindow)
{
  CAMLparam1(mlwindow);

  NSWindow* window = (NSWindow*) mlwindow;

  OGWindowController* wc = [[OGWindowController alloc] init];
  [wc initWithWindow:window];

  CAMLreturn( (value) wc );
}

CAMLprim value
caml_cocoa_window_controller_process_event(value mlcontroller)
{
  CAMLparam1(mlcontroller);

  OGWindowController* controller = (OGWindowController*) mlcontroller;

  [controller processEvent];

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_cocoa_controller_frame(value mlcontroller)
{
  CAMLparam1(mlcontroller);
  CAMLlocal1(mlrect);
  mlrect = caml_alloc_custom(&empty_custom_opts, sizeof(NSRect), 0, 1);

  OGWindowController* controller = (OGWindowController*) mlcontroller;
  NSRect rect = [controller frame];

  memcpy(Data_custom_val(mlrect), &rect, sizeof(NSRect));

  CAMLreturn(mlrect);
}

CAMLprim value
caml_cocoa_window_controller_close(value mlcontroller)
{
  CAMLparam1(mlcontroller);

  OGWindowController* controller = (OGWindowController*) mlcontroller;

  [controller closeWindow];

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_cocoa_controller_is_window_open(value mlcontroller)
{
  CAMLparam1(mlcontroller);

  OGWindowController* controller = (OGWindowController*) mlcontroller;

  BOOL b = [controller isWindowOpen];

  CAMLreturn(Val_bool(b));
}

CAMLprim value
caml_cocoa_window_controller_release_window(value mlcontroller)
{
  CAMLparam1(mlcontroller);

  OGWindowController* controller = (OGWindowController*) mlcontroller;

  [controller releaseWindow];

  CAMLreturn(Val_unit);
}

////////////////////////////////////////////////////////////////////////////////
// BINDING NSEvent
//////////////////
// NSEventType is an enum so binding for it is direct

// INPUT  a NSEvent
// OUTPUT the type of the event
CAMLprim value
caml_cocoa_event_type(value mlevent)
{
  CAMLparam1(mlevent);

  NSEvent* event = (NSEvent*) Data_custom_val(mlevent);

  NSEventType type = [event type];

  // It's an enum so an int
  CAMLreturn(Val_int(type));
}
