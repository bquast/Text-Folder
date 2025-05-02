#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FileSystemItem : NSObject

@property (nonatomic, copy, readonly) NSString *fullPath;
@property (nonatomic, copy, readonly) NSString *relativePath; // Path relative to the root chosen by user
@property (nonatomic, copy, readonly) NSString *displayName;
@property (nonatomic, assign, readonly) BOOL isDirectory;
@property (nonatomic, strong, nullable) NSArray<FileSystemItem *> *children; // Children, nil until loaded

// Designated initializer
- (instancetype)initWithPath:(NSString *)path relativeTo:(NSString *)basePath;

// Helper to lazily load children
- (void)loadChildrenRelativeTo:(NSString *)basePath;

@end

NS_ASSUME_NONNULL_END 