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
