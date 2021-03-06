#import "cocoa_stubs.h"

////////////////////////////////////////////////////////////////////////////////
// BINDING NSEvent
////////////////////////////////////////////////////////////////////////////////
// NSEventType is an enum so binding for it is direct

// INPUT  a NSEvent
// OUTPUT the type of the event
CAMLprim value
caml_cocoa_event_type(value mlevent)
{
  CAMLparam1(mlevent);

  NSEvent* event = (NSEvent*) mlevent;

  NSEventType type = [event type];

  // It's an enum so an int
  CAMLreturn(Val_int(type-1));
}

value extract_modifier_flags(NSEventModifierFlags mask)
{
  CAMLparam0();
  CAMLlocal2(li, cons);
  li = Val_emptylist;

  if(mask & NSAlphaShiftKeyMask)
  {
    cons = caml_alloc(2, 0);
    Store_field(cons, 0, 0); // 0 for NSAlphaShiftKeyMask is the first
    Store_field(cons, 1, li);
    li = cons;
  }
  if(mask & NSShiftKeyMask)
  {
    cons = caml_alloc(2, 0);
    Store_field(cons, 0, 1);
    Store_field(cons, 1, li);
    li = cons;
  }
  if(mask & NSControlKeyMask)
  {
    cons = caml_alloc(2, 0);
    Store_field(cons, 0, 2);
    Store_field(cons, 1, li);
    li = cons;
  }
  if(mask & NSAlternateKeyMask)
  {
    cons = caml_alloc(2, 0);
    Store_field(cons, 0, 2);
    Store_field(cons, 1, li);
    li = cons;
  }
  if(mask & NSCommandKeyMask)
  {
    cons = caml_alloc(2, 0);
    Store_field(cons, 0, 2);
    Store_field(cons, 1, li);
    li = cons;
  }
  if(mask & NSNumericPadKeyMask)
  {
    cons = caml_alloc(2, 0);
    Store_field(cons, 0, 2);
    Store_field(cons, 1, li);
    li = cons;
  }
  if(mask & NSHelpKeyMask)
  {
    cons = caml_alloc(2, 0);
    Store_field(cons, 0, 2);
    Store_field(cons, 1, li);
    li = cons;
  }
  if(mask & NSFunctionKeyMask)
  {
    cons = caml_alloc(2, 0);
    Store_field(cons, 0, 2);
    Store_field(cons, 1, li);
    li = cons;
  }
  if(mask & NSDeviceIndependentModifierFlagsMask)
  {
    cons = caml_alloc(2, 0);
    Store_field(cons, 0, 2);
    Store_field(cons, 1, li);
    li = cons;
  }

  CAMLreturn(li);
}


CAMLprim value
caml_cocoa_event_modifier_flags(value unit)
{
  CAMLparam0();
  CAMLlocal1(li);

  NSEventModifierFlags mask = [NSEvent modifierFlags];

  li = extract_modifier_flags(mask);

  CAMLreturn(li);
}

CAMLprim value
caml_cocoa_event_characters(value mlevent)
{
  CAMLparam1(mlevent);

  NSEvent* event = (NSEvent*) mlevent;

  CAMLreturn((value)[event characters]);
}

CAMLprim value
caml_cocoa_event_key_code(value mlevent)
{
  CAMLparam1(mlevent);

  NSEvent* event = (NSEvent*) mlevent;

  CAMLreturn(Int_val([event keyCode]));
}

CAMLprim value
caml_cocoa_mouse_location(value unit)
{
  CAMLparam0();
  CAMLlocal1(pair);

  NSPoint loc = [NSEvent mouseLocation];

  pair = caml_alloc(2,0);
  Store_field(pair,0,caml_copy_double(loc.x));
  Store_field(pair,1,caml_copy_double(loc.y));

  CAMLreturn(pair);
}

CAMLprim value
caml_cocoa_proper_mouse_location(value unit)
{
  CAMLparam0();
  CAMLlocal1(pair);

  NSPoint loc = [NSEvent mouseLocation];

  // Reversing y
  CGDirectDisplayID displayID = CGMainDisplayID();
  size_t screenHeight = CGDisplayPixelsHigh(displayID);
  loc.y = screenHeight - loc.y;

  int scale = [[NSScreen mainScreen] backingScaleFactor];

  pair = caml_alloc(2,0);
  Store_field(pair,0,caml_copy_double(loc.x * scale));
  Store_field(pair,1,caml_copy_double(loc.y * scale));

  CAMLreturn(pair);
}

CAMLprim value
caml_cocoa_event_pressed_mouse_buttons(value unit)
{
  CAMLparam0();
  CAMLlocal2(li,cons);
  li = Val_emptylist;

  NSUInteger mask = [NSEvent pressedMouseButtons];

  if(mask & (1 << 0)) // Left Button is pressed
  {
    cons = caml_alloc(2, 0);
    Store_field(cons, 0, 0); // Left Button
    Store_field(cons, 1, li);
    li = cons;

    mask -= (1 << 0);
  }

  if(mask & (1 << 1)) // Right Button is pressed
  {
    cons = caml_alloc(2, 0);
    Store_field(cons, 0, 1); // Right Button
    Store_field(cons, 1, li);
    li = cons;

    mask -= (1 << 1);
  }

  if(mask != 0) // Some other bit is on
  {
    cons = caml_alloc(2, 0);
    Store_field(cons, 0, 2); // Other Button
    Store_field(cons, 1, li);
    li = cons;
  }

  CAMLreturn(li);
}


////////////////////////////////////////////////////////////////////////////////
// OGEvent implementation
////////////////////////////////////////////////////////////////////////////////
@implementation OGEvent

- (instancetype)initWithNSEvent:(NSEvent*)nsevent
{
  m_type = OGCocoaEvent;
  m_content.nsevent = nsevent;

  return self;
}

- (instancetype)initWithCloseWindow
{
  m_type = OGCloseWindowEvent;

  return self;
}

- (instancetype)initWithResizedWindow
{
  m_type = OGResizedWindowEvent;

  return self;
}

- (instancetype)initWithKeyUp:(unsigned short)keyCode
                   characters:(NSString *)characters
                modifierFlags:(NSEventModifierFlags)modifierFlags
{
  m_type = OGKeyUp;
  OGKeyInfo info = {
    .keyCode       = keyCode,
    .characters    = characters,
    .modifierFlags = modifierFlags
  };
 m_content.keyInformation = info;

  return self;
}

- (instancetype)initWithKeyDown:(unsigned short)keyCode
                     characters:(NSString *)characters
                  modifierFlags:(NSEventModifierFlags)modifierFlags
{
  m_type = OGKeyDown;
  OGKeyInfo info = {
    .keyCode       = keyCode,
    .characters    = characters,
    .modifierFlags = modifierFlags
  };
  m_content.keyInformation = info;

  return self;
}

- (instancetype)initWithScrollingDeltaY:(CGFloat)deltaY
{
  m_type = OGScrollWheel;
  m_content.scrollingDeltaY = deltaY;

  return self;
}

- (OGEventType)type
{
  return m_type;
}

- (OGEventContent)content
{
  return m_content;
}

@end

////////////////////////////////////////////////////////////////////////////////
// BINDING OGEvent
////////////////////////////////////////////////////////////////////////////////

CAMLprim value
caml_ogevent_get_content(value mlogevent)
{
  CAMLparam1(mlogevent);
  CAMLlocal3(result,key_info,li);

  OGEvent* ogevent = (OGEvent*) mlogevent;

  OGEventType type = [ogevent type];

  OGKeyInfo info;

  switch(type)
  {
    case OGCocoaEvent:
      result = caml_alloc(1,0); // 1st variant
      Store_field(result, 0, (value) [ogevent content].nsevent);
      break;

    case OGCloseWindowEvent:
      result = Val_int(0);
      break;

    case OGKeyUp:
      info = [ogevent content].keyInformation;
      result = caml_alloc(1,1); // 2nd variant
      key_info = caml_alloc(3,0); // 3 values, 0 for tuple (no tag)
        Store_field(key_info, 0, Val_int(info.keyCode));
        Store_field(key_info, 1, (value) info.characters);
        li = extract_modifier_flags(info.modifierFlags);
        Store_field(key_info, 2, li);
      Store_field(result, 0, key_info);
      break;

    case OGKeyDown:
      info = [ogevent content].keyInformation;
      result = caml_alloc(1,2); // 3rd variant
      key_info = caml_alloc(3,0); // 3 values, 0 for tuple (no tag)
        Store_field(key_info, 0, Val_int(info.keyCode));
        Store_field(key_info, 1, (value) info.characters);
        li = extract_modifier_flags(info.modifierFlags);
        Store_field(key_info, 2, li);
      Store_field(result, 0, key_info);
      break;

    case OGResizedWindowEvent:
      result = Val_int(1);
      break;

    case OGScrollWheel:
      result = caml_alloc(1,3); // 4th variant
      Store_field(result, 0, caml_copy_double([ogevent content].scrollingDeltaY));
      break;
  };

  CAMLreturn(result);
}
