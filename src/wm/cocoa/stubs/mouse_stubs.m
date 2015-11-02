#import "cocoa_stubs.h"

#import <CoreGraphics/CoreGraphics.h>

////////////////////////////////////////////////////////////////////////////////
// Binding some CoreGraphics for mouse/cursor handling
////////////////////////////////////////////////////////////////////////////////

CAMLprim value
caml_cg_warp_mouse_cursor_position(value mlx, value mly)
{
  CAMLparam2(mlx,mly);

  CGPoint newCursorPosition = {
    .x = Double_val(mlx),
    .y = Double_val(mly)
  };

  // First solution
  // CGWarpMouseCursorPosition(newCursorPosition);

  // Second solution fro StackOverflow
  // CGEventSourceRef source =
  //   CGEventSourceCreate(kCGEventSourceStateCombinedSessionState);
  // CGEventRef mouse = CGEventCreateMouseEvent(NULL,
  //                                            kCGEventMouseMoved,
  //                                            newCursorPosition,
  //                                            0);
  // CGEventPost(kCGHIDEventTap, mouse);
  // CFRelease(mouse);
  // CFRelease(source);

  // SFML solution
  CGEventRef event = CGEventCreateMouseEvent(NULL,
                                             kCGEventMouseMoved,
                                             newCursorPosition,
                                             0);
  CGEventPost(kCGHIDEventTap, event);
  CFRelease(event);

  CAMLreturn(Val_unit);
}
