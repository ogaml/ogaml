#include "../../../utils/stubs.h"

#ifndef __APPLE__
#define strong retain
#endif

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

// Custom OpenGLView that handles events
////////////////////////////////////////
@interface OGOpenGLView : NSOpenGLView

@end

// Event processing and menu bar (strongly inspired from SFML)
//////////////////////////////////////////////////////////////
@interface OGApplication : NSApplication

// Event processing
+(void) processEvent;

// Setting the menu bar
+(void) setUpMenuBar;

// Displatchs events
-(void)sendEvent:(NSEvent*)anEvent;

@end


// Application specific events processing
/////////////////////////////////////////
@interface OGApplicationDelegate : NSObject <NSApplicationDelegate>

// Handling of termination notification
-(NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication*)sender;

// Once all windows are closed
-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)app;

@end


// Handler of a window
//////////////////////
@interface OGWindowController : NSResponder <NSWindowDelegate>
{
  NSWindow* m_window;
  BOOL m_windowIsOpen; // Luckily it is NO by default
  NSMutableArray* m_events;
  OGOpenGLView* m_view;
}

-(id)initWithWindow:(NSWindow*)window;

-(NSRect)frame;

-(void)closeWindow;

-(BOOL)isWindowOpen;

-(void)releaseWindow;

-(NSEvent *)popEvent;

@end
