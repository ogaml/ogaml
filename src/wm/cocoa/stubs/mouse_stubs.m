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

  CGWarpMouseCursorPosition(newCursorPosition);

  CAMLreturn(Val_unit);
}
