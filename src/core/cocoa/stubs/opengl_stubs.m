#import "cocoa_stubs.h"

////////////////////////////////////////////////////////////////////////////////
// OGOpenGLView implementation
////////////////////////////////////////////////////////////////////////////////
@implementation OGOpenGLView

- (instancetype)initWithFrame:(NSRect)frame
                  pixelFormat:(NSOpenGLPixelFormat *)format
{
  // Inits the event queue
  m_events = [NSMutableArray new];

  return [super initWithFrame:frame pixelFormat:format];
}

-(void)keyDown:(NSEvent *)event
{
  [self pushNSEvent:event];
}

-(void)keyUp:(NSEvent *)event
{
  [self pushNSEvent:event];
}

-(void)mouseDown:(NSEvent *)event
{
  [self pushNSEvent:event];
}

-(void)mouseUp:(NSEvent *)event
{
  [self pushNSEvent:event];
}

-(void)mouseMoved:(NSEvent *)event
{
  [self pushNSEvent:event];
}

-(void)rightMouseDown:(NSEvent *)event
{
  [self pushNSEvent:event];
}

-(void)rightMouseUp:(NSEvent *)event
{
  [self pushNSEvent:event];
}

-(void)otherMouseDown:(NSEvent *)event
{
  [self pushNSEvent:event];
}

-(void)otherMouseUp:(NSEvent *)event
{
  [self pushNSEvent:event];
}

// TODO
// -(void)flagsChanged:(NSEvent*)event

-(void)pushNSEvent:(NSEvent *)event
{
  OGEvent* ogevent = [[OGEvent alloc] initWithNSEvent:event];
  [self pushEvent:ogevent];
}

-(void)pushEvent:(OGEvent *)event
{
  [m_events addObject:event];
}

-(OGEvent *)popEvent
{
  if ([m_events count] == 0) return nil;
  OGEvent* event = [m_events objectAtIndex:0];
  if (event != nil)
  {
    [[event retain] autorelease];
    [m_events removeObjectAtIndex:0];
  }
  return event;
}

@end
