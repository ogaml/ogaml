#include "utils.h"

#ifndef __APPLE__
#define strong retain
#endif

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#include <CoreFoundation/CoreFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#include <Carbon/Carbon.h>

// A function to move the cursor
void warpCursor(NSPoint loc);


// Our own event object to add windowClosed
typedef enum
{
  OGCocoaEvent,
  OGCloseWindowEvent,
  OGKeyDown,
  OGKeyUp,
  OGResizedWindowEvent,
  OGScrollWheel
} OGEventType;

typedef struct
{
  unsigned short       keyCode;
  NSString *           characters;
  NSEventModifierFlags modifierFlags;
} OGKeyInfo;

typedef union
{
  NSEvent*  nsevent;
  OGKeyInfo keyInformation;
  CGFloat   scrollingDeltaY;
} OGEventContent;

@interface OGEvent : NSObject
{
  OGEventType m_type;
  OGEventContent m_content;
}

- (instancetype)initWithNSEvent:(NSEvent*)nsevent;

- (instancetype)initWithCloseWindow;

- (instancetype)initWithResizedWindow;

- (instancetype)initWithKeyUp:(unsigned short)keyCode
                   characters:(NSString *)characters
                modifierFlags:(NSEventModifierFlags)modifierFlags;

- (instancetype)initWithKeyDown:(unsigned short)keyCode
                     characters:(NSString *)characters
                  modifierFlags:(NSEventModifierFlags)modifierFlags;

- (instancetype)initWithScrollingDeltaY:(CGFloat)deltaY;

- (OGEventType)type;

- (OGEventContent)content;

@end


// Custom OpenGLView that handles events
////////////////////////////////////////
@interface OGOpenGLView : NSOpenGLView
{
  NSMutableArray* m_events;
}

-(void)pushEvent:(OGEvent *)event;

-(OGEvent *)popEvent;

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
  OGOpenGLView* m_view;
  NSOpenGLContext* m_context;
}

-(id)initWithWindow:(NSWindow*)window;

-(void)setTitle:(NSString*)title;

-(NSRect)frame;

-(NSRect)contentFrame;

-(void)closeWindow;

-(BOOL)isWindowOpen;

-(void)releaseWindow;

-(void)openWindow;

-(OGEvent *)popEvent;

-(void)setGLContext:(NSOpenGLContext*)context;

-(void)flushGLContext;

-(NSPoint)mouseLocation;

-(NSPoint)properRelativeMouseLocation;

-(void)setProperRelativeMouseLocationTo:(NSPoint)loc;

-(BOOL)hasFocus;

// Handling resizing of a window
-(void)windowDidResize:(NSNotification *)notification;

-(void)resize:(NSRect)frame;

-(void)toggleFullScreen;

-(NSWindow*)window;

@end
