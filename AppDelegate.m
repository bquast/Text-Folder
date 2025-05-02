// AppDelegate.m
#import "AppDelegate.h"

// --- Helper C Function for Creating Menu Items ---
// Creates a menu item and adds it to a menu.
NSMenuItem* createMenuItem(NSMenu *menu, NSString *title, NSString *keyEquivalent, SEL action) {
    NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:title
                                                      action:action
                                               keyEquivalent:keyEquivalent];
    [menu addItem:menuItem];
    return menuItem; // Return the created item
}

// --- AppDelegate Implementation ---
@implementation AppDelegate

// Called when the application has finished launching.
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSLog(@"Application did finish launching."); // <-- Log start

    // --- 1. Create the Main Window ---
    NSRect contentRect = NSMakeRect(100, 100, 800, 600);
    NSWindowStyleMask styleMask = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable;
    self.mainWindow = [[NSWindow alloc] initWithContentRect:contentRect
                                                 styleMask:styleMask
                                                   backing:NSBackingStoreBuffered
                                                     defer:NO];
    [self.mainWindow setTitle:@"Text Folder"];
    [self.mainWindow center];
    NSLog(@"Main window created."); // <-- Log window

    // --- 2. Create the Split View ---
    self.splitView = [[NSSplitView alloc] initWithFrame:self.mainWindow.contentView.bounds]; // Use content view bounds
    [self.splitView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable]; // Ensure it resizes with window
    [self.splitView setVertical:YES];
    [self.splitView setDividerStyle:NSSplitViewDividerStyleThin];
    [self.splitView setDelegate:self];
    NSLog(@"Split view created."); // <-- Log split view

    // --- 3. Create the Sidebar (Outline View) ---
    self.sidebarScrollView = [[NSScrollView alloc] initWithFrame:NSZeroRect];
    [self.sidebarScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable]; // <-- Ensure scroll view resizes
    [self.sidebarScrollView setHasVerticalScroller:YES];
    [self.sidebarScrollView setAutohidesScrollers:YES];
    [self.sidebarScrollView setBorderType:NSBezelBorder];

    self.outlineView = [[NSOutlineView alloc] initWithFrame:NSZeroRect];
    NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"NameColumn"];
    [column setTitle:@"Name"];
    [column setMinWidth:100];
    [column setWidth:200];
    [column setResizingMask:NSTableColumnAutoresizingMask];
    [self.outlineView addTableColumn:column];
    [self.outlineView setOutlineTableColumn:column];
    [self.outlineView setAutoresizesOutlineColumn:YES];
    [self.outlineView setHeaderView:nil];
    [self.outlineView setDataSource:self];
    NSLog(@"OutlineView dataSource set to: %@", self.outlineView.dataSource);
    [self.outlineView setDelegate:self];
    [self.outlineView setIndentationPerLevel:16.0];
    [self.outlineView setUsesAlternatingRowBackgroundColors:YES];
    [self.sidebarScrollView setDocumentView:self.outlineView];
    NSLog(@"Sidebar and outline view created."); // <-- Log sidebar

    // --- 4. Create the Text Editor ---
    self.editorScrollView = [[NSScrollView alloc] initWithFrame:NSZeroRect];
    [self.editorScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable]; // <-- Ensure scroll view resizes
    [self.editorScrollView setHasVerticalScroller:YES];
    [self.editorScrollView setHasHorizontalScroller:YES];
    [self.editorScrollView setAutohidesScrollers:YES];
    [self.editorScrollView setBorderType:NSNoBorder];

    self.textView = [[NSTextView alloc] initWithFrame:self.editorScrollView.bounds];
    [self.textView setMinSize:NSMakeSize(0.0, 0.0)]; // Adjust min size
    [self.textView setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    [self.textView setVerticallyResizable:YES];
    [self.textView setHorizontallyResizable:YES];
    [self.textView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [[self.textView textContainer] setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)]; // Use FLT_MAX for horizontal
    [[self.textView textContainer] setWidthTracksTextView:YES]; // Text view controls width
    [self.textView setFont:[NSFont userFixedPitchFontOfSize:12.0]];
    [self.textView setAllowsUndo:YES];
    [self.textView setRichText:NO];

    [self.editorScrollView setDocumentView:self.textView];
     NSLog(@"Editor and text view created."); // <-- Log editor

    // --- 5. Add Views to Split View and Window ---
    [self.splitView addArrangedSubview:self.sidebarScrollView];
    [self.splitView addArrangedSubview:self.editorScrollView];
    [self.splitView adjustSubviews];
    [self.splitView setPosition:250 ofDividerAtIndex:0]; // Set initial position *after* adding subviews and initial adjust
    [self.mainWindow setContentView:self.splitView]; // Set content view *after* configuring split view
     NSLog(@"Views added to split view and window."); // <-- Log view hierarchy

    // --- 6. Create Application Menu ---
    // (Menu creation code remains the same)
    NSMenu *mainMenu = [[NSMenu alloc] initWithTitle:@"MainMenu"];
    NSMenuItem *appMenuItem = [[NSMenuItem alloc] init];
    NSMenu *appMenu = [[NSMenu alloc] initWithTitle:@"Application"];
    NSString *appName = [[NSProcessInfo processInfo] processName];
    createMenuItem(appMenu, [NSString stringWithFormat:@"About %@", appName], @"", @selector(orderFrontStandardAboutPanel:));
    [appMenu addItem:[NSMenuItem separatorItem]];
    createMenuItem(appMenu, @"Preferences...", @",", nil);
    [appMenu addItem:[NSMenuItem separatorItem]];
    createMenuItem(appMenu, [NSString stringWithFormat:@"Hide %@", appName], @"h", @selector(hide:));
    NSMenuItem *hideOthers = createMenuItem(appMenu, @"Hide Others", @"h", @selector(hideOtherApplications:));
    [hideOthers setKeyEquivalentModifierMask:NSEventModifierFlagOption | NSEventModifierFlagCommand];
    createMenuItem(appMenu, @"Show All", @"", @selector(unhideAllApplications:));
    [appMenu addItem:[NSMenuItem separatorItem]];
    createMenuItem(appMenu, [NSString stringWithFormat:@"Quit %@", appName], @"q", @selector(terminate:));
    [appMenuItem setSubmenu:appMenu];
    [mainMenu addItem:appMenuItem];

    NSMenuItem *fileMenuItem = [[NSMenuItem alloc] init];
    NSMenu *fileMenu = [[NSMenu alloc] initWithTitle:@"File"];
    createMenuItem(fileMenu, @"Open Folder...", @"o", @selector(openFolder:));
    [fileMenu addItem:[NSMenuItem separatorItem]];
    createMenuItem(fileMenu, @"Save", @"s", @selector(saveFile:));
    [fileMenuItem setSubmenu:fileMenu];
    [mainMenu addItem:fileMenuItem];
    [NSApp setMainMenu:mainMenu];
    NSLog(@"Menu created."); // <-- Log menu

    // *** Add Frame Logging Here (Ensure this is present!) ***
    NSLog(@"--- Frame Info Before Show ---");
    NSLog(@"SplitView Frame: %@", NSStringFromRect(self.splitView.frame));
    NSLog(@"Sidebar ScrollView Frame: %@", NSStringFromRect(self.sidebarScrollView.frame));
    NSLog(@"OutlineView Frame (within scroll): %@", NSStringFromRect(self.outlineView.frame));
    NSLog(@"Editor ScrollView Frame: %@", NSStringFromRect(self.editorScrollView.frame));
    NSLog(@"-----------------------------");

    // --- 7. Make Window Visible ---
    [self.mainWindow makeKeyAndOrderFront:nil];
    NSLog(@"Window made key and ordered front."); // <-- Log visibility

    // --- 8. Initial State ---
    // Prompt user to open a folder at launch
    // Use performSelector to ensure the event loop is running before showing the panel
    [self performSelector:@selector(openFolder:) withObject:nil afterDelay:0.0];
    NSLog(@"Scheduled openFolder call."); // <-- Log scheduling

    // *** Add Delegate Check at End ***
    NSLog(@"--- Final Delegate Check ---");
    NSLog(@"OutlineView dataSource is: %@", self.outlineView.dataSource);
    NSLog(@"OutlineView delegate is: %@", self.outlineView.delegate);
    NSLog(@"AppDelegate instance (self) is: %@", self);
    NSLog(@"--------------------------");
     NSLog(@"applicationDidFinishLaunching finished."); // Mark end of method
}

// Called when the application is about to terminate.
- (void)applicationWillTerminate:(NSNotification *)aNotification {
     NSLog(@"Application will terminate."); // <-- Log termination
    // Insert code here to tear down your application
}

// Indicates whether the app supports secure state restoration.
- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

// Prevent the app from terminating if the last window is closed,
// unless explicitly quitting (e.g., Cmd+Q or Quit menu).
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return NO;
}

// --- Action Methods ---

// Action method for the "Open Folder..." menu item.
- (void)openFolder:(id)sender {
    NSLog(@"openFolder: called."); // <-- Log method entry
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setAllowsMultipleSelection:NO];

    if ([panel runModal] == NSModalResponseOK) {
        NSURL *selectedURL = [[panel URLs] firstObject];
        NSLog(@"Folder selected: %@", selectedURL); // <-- Log selected URL
        if (selectedURL && [selectedURL isFileURL]) {
            self.rootPath = [selectedURL path];
             NSLog(@"Root path set to: %@", self.rootPath); // <-- Log root path
            [self.mainWindow setTitle:[NSString stringWithFormat:@"Text Folder - %@", [self.rootPath lastPathComponent]]];
            self.currentlyOpenFile = nil;
            [self.textView setString:@""];
            [self loadFileSystemItems]; // Load data
            NSLog(@"Dispatching reloadData to main queue.");
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Executing reloadData on main queue.");
                [self.outlineView reloadData];
                NSLog(@"OutlineView reloadData finished on main queue.");

                // *** Explicitly trigger layout updates AFTER reloadData ***
                NSLog(@"Adjusting splitView subviews.");
                [self.splitView adjustSubviews]; // Force split view to recalculate layout
                NSLog(@"LayoutIfNeeded on sidebarScrollView.");
                [self.sidebarScrollView layoutSubtreeIfNeeded]; // Force scroll view layout

                NSLog(@"OutlineView reloaded and layout triggered.");
            });
        } else {
             NSLog(@"Selected item is not a valid file URL."); // <-- Log invalid selection
        }
    } else {
         NSLog(@"Open panel was cancelled."); // <-- Log cancellation
    }
}

// Action method for the "Save" menu item.
- (void)saveFile:(id)sender {
     NSLog(@"saveFile: called for file: %@", self.currentlyOpenFile); // <-- Log save attempt
    if (!self.currentlyOpenFile || [self.currentlyOpenFile length] == 0) {
        NSLog(@"No file selected to save.");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Nothing to Save"];
        [alert setInformativeText:@"No file is currently open in the editor."];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
        return;
    }

    NSString *content = [self.textView string];
    NSError *error = nil;
    BOOL success = [content writeToFile:self.currentlyOpenFile
                             atomically:YES
                               encoding:NSUTF8StringEncoding
                                  error:&error];

    if (success) {
        NSLog(@"File saved successfully: %@", self.currentlyOpenFile);
    } else {
        NSLog(@"Error saving file: %@", error);
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert runModal];
    }
}

// --- Helper Method to Load Root Items ---

- (void)loadFileSystemItems {
    NSLog(@"loadFileSystemItems called for path: %@", self.rootPath); // <-- Log entry
    if (!self.rootPath) {
         NSLog(@"No root path set, clearing items."); // <-- Log no path
        self.rootItems = @[];
        return;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:self.rootPath error:&error];

    if (error) {
        NSLog(@"Error reading directory %@: %@", self.rootPath, error);
        self.rootItems = @[];
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert runModal];
        return;
    }

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT self BEGINSWITH '.'"];
    NSArray *visibleItems = [contents filteredArrayUsingPredicate:predicate];
    self.rootItems = [visibleItems sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    NSLog(@"Loaded %lu items: %@", (unsigned long)self.rootItems.count, self.rootItems);

    // IMPORTANT: Reload the outline view data on the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Executing reloadData on main queue.");
        [self.outlineView reloadData];
        NSLog(@"OutlineView reloadData finished on main queue.");

        // *** Explicitly trigger layout updates AFTER reloadData ***
        NSLog(@"Adjusting splitView subviews.");
        [self.splitView adjustSubviews]; // Force split view to recalculate layout
        NSLog(@"LayoutIfNeeded on sidebarScrollView.");
        [self.sidebarScrollView layoutSubtreeIfNeeded]; // Force scroll view layout

        NSLog(@"OutlineView reloaded and layout triggered.");
    });
     NSLog(@"loadFileSystemItems method finished.");
}


// --- NSOutlineViewDataSource Methods ---

// Returns the number of child items for a given item.
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item {
    NSLog(@"numberOfChildrenOfItem: item = %@", item); // <-- Log entry

    if (item == nil) {
        // item is nil for the root level
        NSInteger count = self.rootItems ? self.rootItems.count : 0;
        // Add detailed logging for the root case
        NSLog(@"numberOfChildrenOfItem: item = nil (root). self.rootItems count = %ld. Array pointer: %p", (long)count, self.rootItems);
         if (self.rootItems == nil) {
             // This warning might appear during initial setup before loading, which is okay.
             // Consider adding context if logging this warning.
              NSLog(@" -> WARNING: self.rootItems is nil when querying root children count!");
         }
        NSLog(@" -> Returning %ld children for root item.", (long)count); // <-- Log return value
        return count;
    }
    // For this simple version, items (files/folders) don't have children shown
     NSLog(@"numberOfChildrenOfItem: item = %@. Returning 0 children.", item);
    return 0;
}

// Returns the actual child item at a specific index for a given parent item.
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item {
     NSLog(@"***** dataSource: outlineView:child:ofItem: CALLED! index=%ld, item=%@", (long)index, item);

     if (item == nil) { // Root item
         if (self.rootItems && index >= 0 && index < self.rootItems.count) {
             NSLog(@" -> Returning child %ld for root: %@", (long)index, self.rootItems[index]);
             return self.rootItems[index]; // Return the NSString filename
         }
          NSLog(@" -> Returning nil for root child (index %ld out of bounds or rootItems nil)", (long)index);
     } else { // No children for file/folder items in this simple model
          NSLog(@" -> Returning nil (item %@ is not root)", item);
     }
     return nil;
}

// Determines if a given item can be expanded (i.e., if it's a directory).
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    NSLog(@"***** dataSource: outlineView:isItemExpandable: CALLED! item=%@", item);
    // Regardless of whether it's a directory or file, in this simple flat list model,
    // items are never expandable by the user clicking a disclosure triangle.
    // The 'item == nil' case refers to the invisible root.
    NSLog(@" -> Returning NO (items are not expandable in this view)");
    return NO; // <-- CHANGE THIS: Always return NO for simplicity
}

// Returns the value to display in a specific column for a given item.
- (nullable id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn byItem:(nullable id)item {
    NSLog(@"***** dataSource: outlineView:objectValueForTableColumn:byItem: CALLED! item=%@", item);

    // 'item' should be the NSString filename returned by child:ofItem:
    if (item && [item isKindOfClass:[NSString class]]) {
         NSString *value = (NSString *)item; // Just use the filename directly
         NSLog(@" -> Preparing to return value: %@", value);
         return value;
    }
    NSLog(@" -> Returning nil (item is not NSString or is nil: %@)", item);
    return nil;
}

// --- NSOutlineViewDelegate Methods ---

// Called when the selection in the outline view changes.
- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    // Get the selected item.
    id selectedItem = [self.outlineView itemAtRow:[self.outlineView selectedRow]];
     NSLog(@"outlineViewSelectionDidChange: selectedItem = %@", selectedItem); // <-- Log selection change

    if (selectedItem) {
        // Ensure selectedItem is an NSString
        if (![selectedItem isKindOfClass:[NSString class]]) { // <-- Check if it's NOT a string
            NSLog(@" -> Selected item is not an NSString: %@", selectedItem); // <-- Log inside the block
            [self.textView setString:@"Error: Selected item is not a valid path."];
            self.currentlyOpenFile = nil;
            return; // Exit early if type is wrong
        }

        // Now we know selectedItem is an NSString
        NSString *relativePath = (NSString *)selectedItem;
        NSString *fullPath = [self.rootPath stringByAppendingPathComponent:relativePath];
        BOOL isDir = NO;

        // Check if the selected item is a file.
        if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir] && !isDir) {
             NSLog(@" -> Selected item is a file: %@", fullPath); // <-- Log file selected
            NSError *error = nil;
            // Read the file content as a string.
            NSString *fileContent = [NSString stringWithContentsOfFile:fullPath
                                                              encoding:NSUTF8StringEncoding // Assume UTF-8
                                                                 error:&error];

            if (error) {
                NSLog(@" -> Error reading file %@: %@", fullPath, error);
                // Display error in text view or show an alert.
                [self.textView setString:[NSString stringWithFormat:@"Error loading file:\n%@", [error localizedDescription]]];
                self.currentlyOpenFile = nil; // Cannot save if loading failed
                NSAlert *alert = [NSAlert alertWithError:error];
                [alert runModal];
            } else {
                 NSLog(@" -> Successfully read file. Setting text view content."); // <-- Log file read success
                // Display the content in the text view.
                [self.textView setString:fileContent ? fileContent : @""]; // Handle nil content
                // Keep track of the currently open file path for saving.
                self.currentlyOpenFile = fullPath;
                // Update window title to include file name
                 [self.mainWindow setTitle:[NSString stringWithFormat:@"Text Folder - %@", [fullPath lastPathComponent]]];
            }
        } else {
             NSLog(@" -> Selected item is a directory or does not exist: %@", fullPath); // <-- Log directory selected
            // If a directory is selected, clear the text view and current file path.
            [self.textView setString:@""];
            self.currentlyOpenFile = nil;
            // Reset window title to folder name
            [self.mainWindow setTitle:[NSString stringWithFormat:@"Text Folder - %@", [self.rootPath lastPathComponent]]];
        }
    } else {
         NSLog(@" -> Selection cleared."); // <-- Log selection cleared
        // No selection, clear the text view.
        [self.textView setString:@""];
        self.currentlyOpenFile = nil;
         // Reset window title to folder name (if rootPath exists)
        if(self.rootPath) {
           [self.mainWindow setTitle:[NSString stringWithFormat:@"Text Folder - %@", [self.rootPath lastPathComponent]]];
        } else {
           [self.mainWindow setTitle:@"Text Folder"];
        }
    }
}

// --- NSSplitViewDelegate Methods ---

// Optional: Constrain the minimum size of the sidebar.
- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    // dividerIndex 0 is between the first and second view (sidebar and editor)
    if (dividerIndex == 0) {
        return 150.0; // Minimum width for the sidebar
    }
    return proposedMinimumPosition; // Default constraint for other dividers (if any)
}

// Optional: Constrain the maximum size of the sidebar.
- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
     if (dividerIndex == 0) {
         // Allow editor to shrink, set max width for sidebar (e.g., half the window)
         return splitView.bounds.size.width - 200.0; // Ensure editor has at least 200px
     }
     return proposedMaximumPosition;
}

// Optional: Adjust subview sizes after dragging the divider or resizing the window
- (void)splitViewDidResizeSubviews:(NSNotification *)notification {
    // You could potentially force layout updates here if needed, but autoresizing should handle it.
    // NSLog(@"Split view did resize subviews.");
    // [self.splitView adjustSubviews]; // Might help sometimes, but usually not necessary
}


// This delegate method controls which subview grows when the splitview itself grows
// We want the editor (index 1) to grow.
- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)subview {
     // Identify the subviews more reliably, e.g., by comparing pointers
     if (subview == self.editorScrollView) { // Check if it's the editor's scroll view
         NSLog(@"SplitView: Allowing editorScrollView to adjust size."); // <-- Uncomment log
         return YES; // Allow the editor view to resize
     }
     if (subview == self.sidebarScrollView) { // Check if it's the sidebar's scroll view
        NSLog(@"SplitView: Preventing sidebarScrollView from adjusting size."); // <-- Uncomment log
         return NO; // Keep the sidebar size fixed during window resize
     }
     // Default case if more subviews were added somehow
     NSLog(@"SplitView: Defaulting to YES for unknown subview: %@", subview); // <-- Add log for default case
     return YES;
 }


@end

