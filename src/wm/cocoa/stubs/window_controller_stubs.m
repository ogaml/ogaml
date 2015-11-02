#import "cocoa_stubs.h"

////////////////////////////////////////////////////////////////////////////////
// IMPLEMENTING OGWindowController
// Our own version of a Window Controller (it isn't a NSWindowController)
////////////////////////////////////////////////////////////////////////////////
@implementation OGWindowController

-(id)initWithWindow:(NSWindow*)window
{
  m_window = [window retain];

  [m_window setDelegate:self];
  // [m_window makeFirstResponder:self];

  [m_window setReleasedWhenClosed:NO]; // We can destroy it ourselves

  m_windowIsOpen = true;

  // Setting the openGL view
  m_view = [[[OGOpenGLView alloc] initWithFrame:[[m_window contentView] bounds]
                                    pixelFormat:[OGOpenGLView defaultPixelFormat]] autorelease];
  [m_window setContentView:m_view];
  [m_window makeFirstResponder:m_view];

  return self;
}

-(BOOL)windowShouldClose:(id)sender
{
  (void)sender;

  // We cancel close and treat it as an event instead
  OGEvent* ogevent = [[OGEvent alloc] initWithCloseWindow];
  [m_view pushEvent:ogevent];
  return NO;
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

-(NSRect)contentFrame
{
  return [[m_window contentView] frame];
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
  [m_view release];
  m_window = nil;
}

-(BOOL)isWindowOpen
{
  return m_windowIsOpen;
}

-(OGEvent *)popEvent
{
  return [m_view popEvent];
}

-(void)setGLContext:(NSOpenGLContext*)context
{
  [m_view setOpenGLContext:context];
  [context setView:m_view];
  // We test it down here
  [context makeCurrentContext];
}

-(void)flushGLContext
{
  [[m_view openGLContext] flushBuffer];
}

-(NSPoint)mouseLocation
{
  return [m_window mouseLocationOutsideOfEventStream];
}

-(NSPoint)properRelativeMouseLocation
{
  NSPoint rawloc = [m_window mouseLocationOutsideOfEventStream];
  NSPoint loc = [m_view convertPoint:rawloc fromView:nil];
  int scale = [[m_window screen] backingScaleFactor];

  return NSMakePoint(loc.x * scale, loc.y * scale);
}

-(void)setProperRelativeMouseLocationTo:(NSPoint)loc
{
  int scale = [[m_window screen] backingScaleFactor];
  NSPoint p = NSMakePoint(loc.x / scale, loc.y / scale);

  // Now we get global coordinates (Thanks SFML)
  p.y = [m_view frame].size.height - p.y;

  p = [m_view convertPoint:p toView:m_view];
  p = [m_view convertPoint:p toView:nil];

  NSRect rect = NSZeroRect;
  rect.origin = p;
  rect = [m_window convertRectToScreen:rect];
  p = rect.origin;

  const float screenHeight = [[[m_view window] screen] frame].size.height;
  p.y = screenHeight - p.y;

  // No we set the cursor to p
  warpCursor(p);
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
caml_cocoa_controller_content_frame(value mlcontroller)
{
  CAMLparam1(mlcontroller);
  CAMLlocal1(mlrect);
  mlrect = caml_alloc_custom(&empty_custom_opts, sizeof(NSRect), 0, 1);

  OGWindowController* controller = (OGWindowController*) mlcontroller;
  NSRect rect = [controller contentFrame];

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

CAMLprim value
caml_cocoa_window_controller_pop_event(value mlcontroller)
{
  CAMLparam1(mlcontroller);

  OGWindowController* controller = (OGWindowController*) mlcontroller;

  OGEvent* event = [controller popEvent];

  if(event == nil) CAMLreturn(Val_none);
  else CAMLreturn(Val_some((value)event));
}

CAMLprim value
caml_cocoa_controller_set_glctx(value mlcontroller, value mlctx)
{
  CAMLparam2(mlcontroller,mlctx);

  OGWindowController* controller = (OGWindowController*) mlcontroller;
  NSOpenGLContext* context = (NSOpenGLContext*) mlctx;

  [controller setGLContext:context];

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_cocoa_controller_flush_glctx(value mlcontroller)
{
  CAMLparam1(mlcontroller);

  OGWindowController* controller = (OGWindowController*) mlcontroller;

  [controller flushGLContext];

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_cocoa_controller_mouse_location(value mlcontroller)
{
  CAMLparam1(mlcontroller);
  CAMLlocal1(pair);

  OGWindowController* controller = (OGWindowController*) mlcontroller;

  NSPoint loc = [controller mouseLocation];

  pair = caml_alloc(2,0);
  Store_field(pair,0,caml_copy_double(loc.x));
  Store_field(pair,1,caml_copy_double(loc.y));

  CAMLreturn(pair);
}

CAMLprim value
caml_cocoa_proper_relative_mouse_location(value mlcontroller)
{
  CAMLparam1(mlcontroller);
  CAMLlocal1(pair);

  OGWindowController* controller = (OGWindowController*) mlcontroller;

  NSPoint loc = [controller properRelativeMouseLocation];

  pair = caml_alloc(2,0);
  Store_field(pair,0,caml_copy_double(loc.x));
  Store_field(pair,1,caml_copy_double(loc.y));

  CAMLreturn(pair);
}

CAMLprim value
caml_cocoa_set_proper_relative_mouse_location(value mlcontroller, value mlx, value mly)
{
  CAMLparam3(mlcontroller,mlx,mly);

  OGWindowController* controller = (OGWindowController*) mlcontroller;
  NSPoint loc = NSMakePoint(Double_val(mlx),Double_val(mly));

  [controller setProperRelativeMouseLocationTo:loc];

  CAMLreturn(Val_unit);
}
