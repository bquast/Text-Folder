// AppDelegate.h
#import <Cocoa/Cocoa.h>
#import "FileSystemItem.h" // <-- Import the new header

// Forward declaration
@class FileSystemItem; // We might need a helper class later, declare it here

// Declare that this class conforms to several protocols needed to manage the app,
// handle UI events (outline view, split view), and respond to lifecycle events.
@interface AppDelegate : NSObject <NSApplicationDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate, NSSplitViewDelegate>

// Keep track of the main window
@property (strong) NSWindow *mainWindow;

// UI Elements
@property (strong) NSSplitView *splitView;
@property (strong) NSScrollView *sidebarScrollView;
@property (strong) NSOutlineView *outlineView;
@property (strong) NSScrollView *editorScrollView;
@property (strong) NSTextView *textView;

// File System Data
@property (strong) NSString *rootPath;
@property (strong) NSString *currentlyOpenFile;
@property (strong) NSArray<FileSystemItem *> *rootItems; // Top-level items for the outline view

// Method to open a folder
- (void)openFolder:(id)sender;

// Method to save the current file
- (void)saveFile:(id)sender;

@end

