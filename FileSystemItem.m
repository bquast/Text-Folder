#import "FileSystemItem.h"

@implementation FileSystemItem

- (instancetype)initWithPath:(NSString *)path relativeTo:(NSString *)basePath {
    self = [super init];
    if (self) {
        _fullPath = [path copy];
        // Ensure relativePath doesn't start with / if it's directly under base
        if ([path hasPrefix:basePath]) {
             NSString *tempPath = [path substringFromIndex:[basePath length]];
             _relativePath = [tempPath stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
        } else {
            // Fallback if path somehow doesn't start with basePath (shouldn't happen with current logic)
             _relativePath = [[path stringByReplacingOccurrencesOfString:basePath withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
        }

        _displayName = [_fullPath lastPathComponent];

        BOOL isDir = NO;
        // Check existence and type
        [[NSFileManager defaultManager] fileExistsAtPath:_fullPath isDirectory:&isDir];
        _isDirectory = isDir;
        _children = nil; // Children are loaded lazily
    }
    return self;
}

// Lazily load children when requested
- (void)loadChildrenRelativeTo:(NSString *)basePath {
    // Prevent reloading or loading for non-directories
    if (!self.isDirectory || self.children != nil) {
        if(self.children != nil) {
             NSLog(@"Children already loaded for: %@", self.relativePath);
        }
        return;
    }

    NSLog(@"Lazily loading children for: %@", self.relativePath);
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    // Important: Get contents of self.fullPath, not basePath
    NSArray *contents = [fm contentsOfDirectoryAtPath:self.fullPath error:&error];

    if (error) {
        NSLog(@"Error loading children for %@: %@", self.fullPath, error);
        _children = @[]; // Mark as loaded (empty due to error) to prevent retrying
        // Optionally: Display error to user
        return;
    }

    NSMutableArray<FileSystemItem *> *childItems = [NSMutableArray array];
    for (NSString *name in contents) {
        if (![name hasPrefix:@"."]) { // Skip hidden files/folders
            NSString *childFullPath = [self.fullPath stringByAppendingPathComponent:name];
            // Pass the ORIGINAL basePath to maintain correct relative paths
            FileSystemItem *childItem = [[FileSystemItem alloc] initWithPath:childFullPath relativeTo:basePath];
            [childItems addObject:childItem];
        }
    }

    // Sort children alphabetically by display name
    [childItems sortUsingComparator:^NSComparisonResult(FileSystemItem *obj1, FileSystemItem *obj2) {
        return [obj1.displayName localizedStandardCompare:obj2.displayName];
    }];

    _children = [childItems copy]; // Assign the loaded children
    NSLog(@" -> Loaded %lu children for %@", (unsigned long)_children.count, self.relativePath);
}

// Override description for easier debugging
- (NSString *)description {
    return [NSString stringWithFormat:@"<FileSystemItem: %@ (%@)>", self.relativePath.length > 0 ? self.relativePath : @"(root level item)", self.isDirectory ? @"Dir" : @"File"];
}

@end 