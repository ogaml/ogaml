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


////////////////////////////////////////////////////////////////////////////////
// OGEvent implementation
////////////////////////////////////////////////////////////////////////////////
@implementation OGEvent

- (instancetype)initWithNSEvent:(NSEvent*)nsevent
{
  m_type = OGCocoaEvent;
  // m_content = {'$'};
  // m_content = {.nsevent = nsevent};
  m_content.nsevent = nsevent;

  return self;
}

- (instancetype)initWithCloseWindow
{
  m_type = OGCloseWindowEvent;

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
  CAMLlocal1(result);

  OGEvent* ogevent = (OGEvent*) mlogevent;

  OGEventType type = [ogevent type];

  switch(type)
  {
    case OGCocoaEvent:
      result = caml_alloc(1,0);
      Store_field(result, 0, (value) [ogevent content].nsevent);
      break;

    case OGCloseWindowEvent:
      result = Val_int(0);
      break;
  };

  CAMLreturn(result);
}
