#include "../../../utils/stubs.h"

#ifndef __APPLE__
#define strong retain
#endif

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
