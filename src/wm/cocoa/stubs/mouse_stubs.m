#import "cocoa_stubs.h"

#import <CoreGraphics/CoreGraphics.h>

////////////////////////////////////////////////////////////////////////////////
// Binding some CoreGraphics for mouse/cursor handling
////////////////////////////////////////////////////////////////////////////////

CAMLprim value
caml_cg_warp_mouse_cursor_position(value mlx, value mly)
{
  CAMLparam2(mlx,mly);

  int scale = [[NSScreen mainScreen] backingScaleFactor];
  CGPoint newCursorPosition = CGPointMake(Double_val(mlx) / scale,
                                          Double_val(mly) / scale);

  // First solution
  // CGEventSourceRef evsrc =
  //   CGEventSourceCreate(kCGEventSourceStateCombinedSessionState);
  // CGEventSourceSetLocalEventsSuppressionInterval(evsrc, 0.0);
  // CGAssociateMouseAndMouseCursorPosition(0);
  // CGWarpMouseCursorPosition(newCursorPosition);
  // CGAssociateMouseAndMouseCursorPosition(1);

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
