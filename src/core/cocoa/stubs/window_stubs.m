#import "cocoa_stubs.h"

////////////////////////////////////////////////////////////////////////////////
// We directly bind NSWindow (for now at least)
////////////////////////////////////////////////////////////////////////////////

CAMLprim value
caml_cocoa_create_window(value frame, value styleMask, value backing, value defer)
{
  CAMLparam4(frame,styleMask,backing,defer);
  CAMLlocal2(hd, tl);

  NSRect* rect = (NSRect*) Data_custom_val(frame);
  CGFloat scale = [[NSScreen mainScreen] backingScaleFactor];
  // No point in scaling initial position
  // rect->origin.x = rect->origin.x / scale;
  // rect->origin.y = rect->origin.y / scale;
  rect->size.width = rect->size.width / scale;
  rect->size.height = rect->size.height / scale;

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
caml_cocoa_window_close(value mlwindow)
{
  CAMLparam1(mlwindow);

  NSWindow* window = (NSWindow*) mlwindow;

  [window close];

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

  // We need to scale the frame (from pt to pixels)
  CGFloat scale = [[NSScreen mainScreen] backingScaleFactor];
  // Note: We don't scale the origin
  rect.size.width = rect.size.width * scale;
  rect.size.height = rect.size.height * scale;

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
