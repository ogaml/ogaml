#define CAML_NAME_SPACE

#ifndef __APPLE__
#define strong retain
#endif

#include <caml/custom.h>
#include <caml/fail.h>
#include <caml/callback.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/mlvalues.h>
#include <caml/custom.h>

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

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
