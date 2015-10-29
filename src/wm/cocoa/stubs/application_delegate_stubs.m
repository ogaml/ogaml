#import "cocoa_stubs.h"

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

-(void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
  [OGApplication sharedApplication];
  [OGApplication setUpMenuBar];
  #ifdef __OSX__
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
  #endif
}

-(void)applicationDidFinishLaunching:(NSNotification *)notification
{
  [OGApplication sharedApplication];

  #ifdef __OSX__
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
  #endif

  [NSApp activateIgnoringOtherApps:YES];
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
