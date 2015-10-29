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
  [self pushEvent:event];
}

-(void)mouseDown:(NSEvent *)event
{
  [self pushEvent:event];
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

@end
