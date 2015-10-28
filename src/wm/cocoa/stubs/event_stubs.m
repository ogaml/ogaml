#import "cocoa_stubs.h"

////////////////////////////////////////////////////////////////////////////////
// BINDING NSEvent
//////////////////
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
