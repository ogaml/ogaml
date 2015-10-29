#import "cocoa_stubs.h"

////////////////////////////////////////////////////////////////////////////////
// IMPLEMENTING OGWindowController
// Our own version of a Window Controller (it isn't a NSWindowController)
////////////////////////////////////////////////////////////////////////////////
@implementation OGWindowController

-(id)initWithWindow:(NSWindow*)window
{
  // Inits the event queue
  m_events = [NSMutableArray new];

  m_window = [window retain];

  [m_window setDelegate:self];
  [m_window makeFirstResponder:self];

  [m_window setReleasedWhenClosed:NO]; // We can destroy it ourselves

  m_windowIsOpen = true;

  // Setting the openGL view
  m_view = [[[OGOpenGLView alloc] initWithFrame:[[m_window contentView] bounds]
                                    pixelFormat:[OGOpenGLView defaultPixelFormat]] autorelease];
  [m_window setContentView:m_view];

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
  [m_view release];
  m_window = nil;
}

-(BOOL)isWindowOpen
{
  return m_windowIsOpen;
}

-(void)pushEvent:(NSEvent *)event
{
  [m_events addObject:event];
}

-(NSEvent *)popEvent
{
  if ([m_events count] == 0) return nil;
  NSEvent* event = [m_events objectAtIndex:0];
  if (event != nil)
  {
    [[event retain] autorelease];
    [m_events removeObjectAtIndex:0];
  }
  return event;
}

-(void)keyDown:(NSEvent *)event
{
  [self pushEvent:event];
}

-(void)mouseDown:(NSEvent *)event
{
  [self pushEvent:event];
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

CAMLprim value
caml_cocoa_window_controller_pop_event(value mlcontroller)
{
  CAMLparam1(mlcontroller);

  OGWindowController* controller = (OGWindowController*) mlcontroller;

  NSEvent* event = [controller popEvent];

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
