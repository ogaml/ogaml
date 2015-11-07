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

+(void)setUpMenuBar
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

-(void)bringAllToFront:(id)sender
{
    (void)sender;
    [[NSApp windows] makeObjectsPerformSelector:@selector(orderFrontRegardless)];
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
  [[NSApplication sharedApplication] setDelegate:delegate];

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

