// main.m
#import <Cocoa/Cocoa.h>
#import "AppDelegate.h" // Import the delegate header

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // Create the shared application instance (the foundation of the app)
        [NSApplication sharedApplication];

        // Create an instance of our application delegate
        // The delegate handles application lifecycle events and manages our window/views
        AppDelegate *delegate = [[AppDelegate alloc] init];

        // Set our custom delegate object as the application's delegate
        [NSApp setDelegate:delegate];

        // Run the application. This starts the main event loop.
        // It doesn't return until the application terminates.
        [NSApp run];
    }
    // Although [NSApp run] typically doesn't return, include a return for completeness.
    return 0;
}

