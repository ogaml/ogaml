#import "cocoa_stubs.h"

// AutoReleasePool binding
//////////////////////////
static NSAutoreleasePool* arp = nil;

CAMLprim value
caml_init_arp(value unit)
{
  CAMLparam0();

  if(arp == nil) {
    arp = [[NSAutoreleasePool alloc] init];
  }

  CAMLreturn(Val_unit);
}

// Display information
//////////////////////
CAMLprim value
caml_cocoa_display_size(value unit)
{
  CAMLparam0();
  CAMLlocal1(tuple);

  CGDirectDisplayID displayID = CGMainDisplayID();
  size_t screenWidth = CGDisplayPixelsWide(displayID);
  size_t screenHeight = CGDisplayPixelsHigh(displayID);

  tuple = caml_alloc(2,0);
  Store_field(tuple,0,caml_copy_double(screenWidth));
  Store_field(tuple,1,caml_copy_double(screenHeight));

  CAMLreturn(tuple);
}

// Resource Path
////////////////
CAMLprim value
caml_cocoa_resource_path(value unit)
{
  CAMLparam0();
  CAMLlocal1(mlc);

  // Get the app's main bundle
  NSBundle* main = [NSBundle mainBundle];
  // Then the path of the resource directory
  NSString* path = [main resourcePath];

  char* c = (char*)[path UTF8String];
  mlc = caml_copy_string(c);

  CAMLreturn(mlc);
}

// Real path
////////////
CAMLprim value
caml_realpath(value path)
{
  CAMLparam1(path);
  CAMLlocal1(res);

  char* res_ptr = realpath(String_val(path), NULL);

  res = caml_copy_string(res_ptr);

  free(res_ptr);

  CAMLreturn(res);
}

// Moving the cursor to a NSPoint
/////////////////////////////////
void warpCursor(NSPoint loc)
{
  // int scale = [[NSScreen mainScreen] backingScaleFactor];
  // CGPoint newCursorPosition = CGPointMake(loc.x / scale,
  //                                         loc.y / scale);
  CGPoint newCursorPosition = CGPointMake(loc.x, loc.y);

  // First solution
  // CGEventSourceRef evsrc =
  //   CGEventSourceCreate(kCGEventSourceStateCombinedSessionState);
  // CGEventSourceSetLocalEventsSuppressionInterval(evsrc, 0.0);
  // CGAssociateMouseAndMouseCursorPosition(0);
  // CGWarpMouseCursorPosition(newCursorPosition);
  // CGAssociateMouseAndMouseCursorPosition(1);

  // Second solution from StackOverflow
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
  // CGEventRef event = CGEventCreateMouseEvent(NULL,
  //                                            kCGEventMouseMoved,
  //                                            newCursorPosition,
  //                                            0);
  // CGEventPost(kCGHIDEventTap, event);
  // CFRelease(event);

  // Other solution
  CGWarpMouseCursorPosition(newCursorPosition);
}

CAMLprim value
caml_cg_warp_mouse_cursor_position(value mlx, value mly)
{
  CAMLparam2(mlx,mly);

  NSPoint loc = NSMakePoint(Double_val(mlx),Double_val(mly));
  CGFloat scale = [[NSScreen mainScreen] backingScaleFactor];
  loc.x = loc.x / scale;
  loc.y = loc.y / scale;

  warpCursor(loc);

  CAMLreturn(Val_unit);
}

// Keyboard information
///////////////////////

// This function is strongly inspired from StackOverflow
// http://stackoverflow.com/questions/8263618/convert-virtual-key-code-to-unicode-string
NSString* keyCodeToString(CGKeyCode keyCode)
{
  TISInputSourceRef currentKeyboard = TISCopyCurrentKeyboardInputSource();
  CFDataRef uchr =
    (CFDataRef)TISGetInputSourceProperty(currentKeyboard,
                                         kTISPropertyUnicodeKeyLayoutData);
  const UCKeyboardLayout *keyboardLayout =
    (const UCKeyboardLayout*)CFDataGetBytePtr(uchr);

  if(keyboardLayout)
  {
    UInt32 deadKeyState = 0;
    UniCharCount maxStringLength = 255;
    UniCharCount actualStringLength = 0;
    UniChar unicodeString[maxStringLength];

    OSStatus status = UCKeyTranslate(keyboardLayout,
                                     keyCode, kUCKeyActionDown, 0,
                                     LMGetKbdType(), 0,
                                     &deadKeyState,
                                     maxStringLength,
                                     &actualStringLength, unicodeString);

    if (actualStringLength == 0 && deadKeyState)
    {
      status = UCKeyTranslate(keyboardLayout,
                                       kVK_Space, kUCKeyActionDown, 0,
                                       LMGetKbdType(), 0,
                                       &deadKeyState,
                                       maxStringLength,
                                       &actualStringLength, unicodeString);
    }
    if(actualStringLength > 0 && status == noErr)
      return [[NSString stringWithCharacters:unicodeString
                        length:(NSUInteger)actualStringLength] lowercaseString];
  }

  return nil;
}

NSNumber* charToKeyCode(const char c)
{
  static NSMutableDictionary* dict = nil;

  if (dict == nil)
  {
    dict = [NSMutableDictionary dictionary];

    // For every keyCode
    size_t i;
    for (i = 0; i < 128; ++i)
    {
      NSString* str = keyCodeToString((CGKeyCode)i);
      if(str != nil && ![str isEqualToString:@""])
      {
        [dict setObject:[NSNumber numberWithInt:i] forKey:str];
      }
    }
  }

  NSString * keyChar = [NSString stringWithFormat:@"%c" , c];

  return [dict objectForKey:keyChar];
}

// Check if a keycode is pressed
BOOL isKeyPressed(CGKeyCode key)
{
  return CGEventSourceKeyState(kCGEventSourceStateHIDSystemState,key);
}

CAMLprim value
caml_cg_is_key_pressed(value mlkeycode)
{
  CAMLparam1(mlkeycode);

  BOOL res = isKeyPressed(Int_val(mlkeycode));

  CAMLreturn(Val_bool(res));
}

CAMLprim value
caml_cg_is_char_pressed(value mlchar)
{
  CAMLparam1(mlchar);

  char c = Int_val(mlchar);

  NSNumber* keycode = charToKeyCode(c);

  BOOL res =
    (keycode == nil) ? false : isKeyPressed((CGKeyCode)[keycode intValue]);

  CAMLreturn(Val_bool(res));
}

// NSString binding
///////////////////

CAMLprim value
caml_cocoa_gen_string(value str)
{
  CAMLparam1(str);

  const char* tmp = String_val(str);

  NSString* data = [NSString stringWithUTF8String:tmp];

  CAMLreturn((value) data);
}


CAMLprim value
caml_cocoa_get_string(value mlstr)
{
  CAMLparam1(mlstr);
  CAMLlocal1(mlc);

  NSString* str = (NSString*) mlstr;
  char* c = (char*)[str UTF8String];

  mlc = caml_copy_string(c);

  CAMLreturn(mlc);
}

// NSRect binding
/////////////////

CAMLprim value
caml_cocoa_create_nsrect(value x, value y, value w, value h)
{
  CAMLparam4(x,y,w,h);

  CAMLlocal1(mlrect);
  mlrect = caml_alloc_custom(&empty_custom_opts, sizeof(NSRect), 0, 1);

  NSRect rect = NSMakeRect(Double_val(x), Double_val(y), Double_val(w), Double_val(h));

  memcpy(Data_custom_val(mlrect), &rect, sizeof(NSRect));

  CAMLreturn(mlrect);
}

CAMLprim value
caml_cocoa_get_nsrect(value mlrect)
{
  CAMLparam1(mlrect);
  CAMLlocal1(tuple);

  NSRect* rect = (NSRect*) Data_custom_val(mlrect);

  tuple = caml_alloc(4,0);
  Store_field(tuple,0,caml_copy_double(rect->origin.x));
  Store_field(tuple,1,caml_copy_double(rect->origin.y));
  Store_field(tuple,2,caml_copy_double(rect->size.width));
  Store_field(tuple,3,caml_copy_double(rect->size.height));

  CAMLreturn(tuple);
}

// NSColor binding
//////////////////

CAMLprim value
caml_cocoa_color_rgba(value r, value g, value b, value a)
{
  CAMLparam4(r,g,b,a);

  float fr = Double_val(r);
  float fg = Double_val(g);
  float fb = Double_val(b);
  float fa = Double_val(a);

  NSColor* color = [NSColor colorWithRed:fr green:fg blue:fb alpha:fa];

  CAMLreturn( (value) color );
}

#define def_caml_cocoa_color(c,nsc) CAMLprim value \
                            caml_cocoa_color_ ## c (value unit) \
                            { \
                              CAMLparam0(); \
                              NSColor* color = [NSColor nsc ## Color]; \
                              CAMLreturn( (value) color ); \
                            }

def_caml_cocoa_color(black,black)
def_caml_cocoa_color(blue,blue)
def_caml_cocoa_color(brown,brown)
def_caml_cocoa_color(clear,clear)
def_caml_cocoa_color(cyan,cyan)
def_caml_cocoa_color(dark_gray,darkGray)
def_caml_cocoa_color(gray,gray)
def_caml_cocoa_color(green,green)
def_caml_cocoa_color(light_gray,lightGray)
def_caml_cocoa_color(magenta,magenta)
def_caml_cocoa_color(orange,orange)
def_caml_cocoa_color(purple,purple)
def_caml_cocoa_color(red,red)
def_caml_cocoa_color(white,white)
def_caml_cocoa_color(yellow,yellow)
