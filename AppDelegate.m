// AppDelegate.m
#import "AppDelegate.h"
#import "FileSystemItem.h"

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
    NSLog(@"loadFileSystemItems called for path: %@", self.rootPath);
    if (!self.rootPath) {
        self.rootItems = @[]; // Empty array if no path
        dispatch_async(dispatch_get_main_queue(), ^{ [self.outlineView reloadData]; });
        return;
    }

    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    // Get contents, skip hidden files and subdirectories
    NSArray *rawContents = [fm contentsOfDirectoryAtPath:self.rootPath error:&error];

    if (error) {
        NSLog(@"Error reading root directory %@: %@", self.rootPath, error);
        self.rootItems = @[];
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert runModal];
    } else {
        NSMutableArray<FileSystemItem *> *items = [NSMutableArray array];
        for (NSString *name in rawContents) {
            if (![name hasPrefix:@"."]) { // Basic filter for hidden files
                NSString *fullPath = [self.rootPath stringByAppendingPathComponent:name];
                // Create FileSystemItem objects for the top level
                FileSystemItem *item = [[FileSystemItem alloc] initWithPath:fullPath relativeTo:self.rootPath];
                [items addObject:item];
            }
        }
        // Sort top-level items alphabetically
        [items sortUsingComparator:^NSComparisonResult(FileSystemItem *obj1, FileSystemItem *obj2) {
            return [obj1.displayName localizedStandardCompare:obj2.displayName];
        }];
        self.rootItems = [items copy]; // Assign the array of FileSystemItem
        NSLog(@"Loaded %lu root items: %@", (unsigned long)self.rootItems.count, self.rootItems);
    }

    // IMPORTANT: Reload the outline view data on the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Executing reloadData on main queue.");
        [self.outlineView reloadData];
        NSLog(@"OutlineView reloadData finished on main queue.");
        // Optional: Trigger layout updates if needed
        // NSLog(@"Adjusting splitView subviews.");
        // [self.splitView adjustSubviews];
        // NSLog(@"LayoutIfNeeded on sidebarScrollView.");
        // [self.sidebarScrollView layoutSubtreeIfNeeded];
    });
     NSLog(@"loadFileSystemItems method finished.");
}


// --- NSOutlineViewDataSource Methods ---

// How many children does 'item' have?
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item {
    if (item == nil) {
        // item is nil for the root level
        NSInteger count = self.rootItems ? self.rootItems.count : 0;
        NSLog(@"numberOfChildrenOfItem: item = nil (root). Returning %ld", (long)count);
        return count;
    } else if ([item isKindOfClass:[FileSystemItem class]]) {
        FileSystemItem *fsItem = (FileSystemItem *)item;
        if (!fsItem.isDirectory) {
             NSLog(@"numberOfChildrenOfItem: item = %@ (File). Returning 0", fsItem.relativePath);
            return 0; // Files have no children
        }
        // For directories, load children if needed, then return count
        if (fsItem.children == nil) { // Check if children need loading
             [fsItem loadChildrenRelativeTo:self.rootPath];
        }
         NSInteger count = fsItem.children ? fsItem.children.count : 0;
         NSLog(@"numberOfChildrenOfItem: item = %@ (Dir). Returning %ld", fsItem.relativePath, (long)count);
        return count;
    }
    NSLog(@"numberOfChildrenOfItem: item = %@ (Unknown type). Returning 0", item);
    return 0;
}

// What is the child at 'index' for 'item'?
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item {
    NSLog(@"***** dataSource: outlineView:child:ofItem: CALLED! index=%ld, item=%@", (long)index, item);
    if (item == nil) { // Root item
        if (self.rootItems && index >= 0 && index < self.rootItems.count) {
             NSLog(@" -> Returning root child %ld: %@", (long)index, self.rootItems[index]);
            return self.rootItems[index];
        }
    } else if ([item isKindOfClass:[FileSystemItem class]]) {
        FileSystemItem *fsItem = (FileSystemItem *)item;
        // Ensure children are loaded before accessing
        if (fsItem.isDirectory && fsItem.children == nil) {
            [fsItem loadChildrenRelativeTo:self.rootPath];
        }
        // Return the specific child if it exists
        if (fsItem.children && index >= 0 && index < fsItem.children.count) {
             NSLog(@" -> Returning child %ld for %@: %@", (long)index, fsItem.relativePath, fsItem.children[index]);
            return fsItem.children[index];
        }
    }
     NSLog(@" -> Returning nil (index %ld out of bounds, item not dir, or unknown item type: %@)", (long)index, item);
    return nil;
}

// Can 'item' be expanded (does it have children)?
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
     NSLog(@"***** dataSource: outlineView:isItemExpandable: CALLED! item=%@", item);
    if (item == nil) {
         NSLog(@" -> Returning NO (root is not expandable)");
        return NO; // Root is not visually expandable
    }
    if ([item isKindOfClass:[FileSystemItem class]]) {
        FileSystemItem *fsItem = (FileSystemItem *)item;
        BOOL expandable = fsItem.isDirectory; // Only directories are expandable
         NSLog(@" -> Returning %@ for %@", expandable ? @"YES" : @"NO", fsItem.relativePath);
        return expandable;
    }
     NSLog(@" -> Returning NO (unknown item type)");
    return NO;
}

// What value should be displayed for 'item' in 'tableColumn'?
- (nullable id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn byItem:(nullable id)item {
    NSLog(@"***** dataSource: outlineView:objectValueForTableColumn:byItem: CALLED! item=%@", item);
    if ([item isKindOfClass:[FileSystemItem class]]) {
        FileSystemItem *fsItem = (FileSystemItem *)item;
        // We only have one column, display the item's name
         NSString *value = fsItem.displayName;
         NSLog(@" -> Returning displayName: %@", value);
        return value;
    }
    NSLog(@" -> Returning nil (unknown item type)");
    return nil;
}

// --- NSOutlineViewDelegate Methods ---

// Called when the user selects a different row
- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    NSLog(@"outlineViewSelectionDidChange:"); // Log entry
    NSInteger selectedRow = [self.outlineView selectedRow];
    self.currentlyOpenFile = nil; // Reset current file
    // Don't clear text view immediately, only if selection is invalid or a directory

    if (selectedRow != -1) {
        // Get the FileSystemItem associated with the selected row
        id selectedItem = [self.outlineView itemAtRow:selectedRow];

        if (selectedItem && [selectedItem isKindOfClass:[FileSystemItem class]]) {
            FileSystemItem *fsItem = (FileSystemItem *)selectedItem;
             NSLog(@" -> Selected FileSystemItem: %@", fsItem); // Log the selected item

            // Check if the selected item is a file.
            if (!fsItem.isDirectory) {
                NSLog(@" -> Selected item is a file: %@", fsItem.fullPath);
                NSError *error = nil;
                // Read the file content as a string.
                NSString *fileContent = [NSString stringWithContentsOfFile:fsItem.fullPath
                                                                  encoding:NSUTF8StringEncoding // Assume UTF-8
                                                                     error:&error];

                if (error) {
                    NSLog(@" -> Error reading file %@: %@", fsItem.fullPath, error);
                    [self.textView setString:[NSString stringWithFormat:@"Error loading file:\n%@", [error localizedDescription]]];
                    self.currentlyOpenFile = nil; // Cannot save if loading failed
                    [self.mainWindow setTitle:[NSString stringWithFormat:@"Text Folder - %@", [self.rootPath lastPathComponent]]]; // Reset title
                    NSAlert *alert = [NSAlert alertWithError:error];
                    [alert runModal];
                } else {
                    NSLog(@" -> Successfully read file. Setting text view content.");
                    [self.textView setString:fileContent ? fileContent : @""]; // Handle nil content
                    self.currentlyOpenFile = fsItem.fullPath; // Keep track for saving
                    [self.mainWindow setTitle:[NSString stringWithFormat:@"Text Folder - %@", fsItem.displayName]]; // Update title
                }
            } else {
                NSLog(@" -> Selected item is a directory: %@", fsItem.fullPath);
                // If a directory is selected, clear the text view and current file path.
                [self.textView setString:@""];
                self.currentlyOpenFile = nil;
                [self.mainWindow setTitle:[NSString stringWithFormat:@"Text Folder - %@", [self.rootPath lastPathComponent]]]; // Reset window title
                 // Optional: automatically expand the selected directory?
                 // if (![self.outlineView isItemExpanded:fsItem]) {
                 //    [self.outlineView expandItem:fsItem];
                 // }
            }
        } else {
             NSLog(@" -> Selected item is nil or not a FileSystemItem: %@", selectedItem);
             [self.textView setString:@""]; // Clear view if selection is weird
             self.currentlyOpenFile = nil;
             [self.mainWindow setTitle:[NSString stringWithFormat:@"Text Folder - %@", [self.rootPath lastPathComponent]]]; // Reset title
        }
    } else {
        NSLog(@" -> Selection cleared.");
        // If selection is cleared, clear the text view and current file path.
        [self.textView setString:@""];
        self.currentlyOpenFile = nil;
         // Reset window title to folder name if rootPath exists
         if (self.rootPath) {
             [self.mainWindow setTitle:[NSString stringWithFormat:@"Text Folder - %@", [self.rootPath lastPathComponent]]];
         } else {
              [self.mainWindow setTitle:@"Text Folder"];
         }
    }
     // Ensure text view scrolls to top after changing content
     dispatch_async(dispatch_get_main_queue(), ^{
         [self.textView scrollRangeToVisible:NSMakeRange(0, 0)];
          NSLog(@" -> Scrolled text view to top.");
     });
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

