//
//  ThumbCache.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 20.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import "ThumbCache.h"
#import "ThumbFetch.h"
#import "ThumbView.h"

@interface ThumbCache ()

@property (strong, nonatomic) NSCache* thumbCache;
@property (assign, nonatomic) NSInteger cacheSize;

@end


@implementation ThumbCache

#pragma mark - Initialization

- (instancetype) init {
    self = [super init];
    
    if (self) {

        _cacheSize = 2097152;
        
        // Init new cache
        _thumbCache = [NSCache new];
        
        [_thumbCache setName: @"ThumbCache"];
        [_thumbCache setTotalCostLimit: _cacheSize];
    }
    
    return self;
}

#pragma mark - Instance methods

- (id) thumbRequest:(ThumbRequest *)thumbRequest priority:(BOOL)priority {
    
    // Lock using mutex
    @synchronized(self.thumbCache) {
        
        id thumbObj = [self.thumbCache objectForKey: thumbRequest.cacheKey];
        
        // If current thumb does not exist in cache
        if (thumbObj == nil) {
            
            thumbObj = [NSNull null];
            
            // Cache the placeholder thumb object
            [self.thumbCache setObject: thumbObj forKey: thumbRequest.cacheKey cost: 2];
            
            // Init thumb fetch operation
            ThumbFetch* thumbFetch = [[ThumbFetch alloc] initWithRequest: thumbRequest];
            
            // Setup thread priority
            [thumbFetch setQueuePriority: (priority ? NSOperationQueuePriorityNormal : NSOperationQueuePriorityLow)];
            
            thumbRequest.thumbView.operation = thumbFetch;
            //[thumbFetch setThreadPriority :(priority ? 0.55 : 0.35)];
            [thumbFetch setQualityOfService: NSQualityOfServiceUserInteractive];
            
            // Singleton Queue for operations
            [[ThumbQueue sharedInstance] addLoadOperation: thumbFetch];
        }
        
        return thumbObj;
    }
}

- (void) setObject:(UIImage *)image forKey:(NSString *)key {
    
    // Lock using mutex
    @synchronized(self.thumbCache) {
        
        NSUInteger bytes = (image.size.width * image.size.height * 4.f);
        
        // Cache current image
        [self.thumbCache setObject: image forKey: key cost: bytes];
    }
}

- (void) removeObjectForKey:(NSString *)key {
    
    // Lock using mutex
    @synchronized(self.thumbCache) {
        
        [self.thumbCache removeObjectForKey: key];
    }
}

- (void) removeNullForKey:(NSString *)key {
    
    // Lock using mutex
    @synchronized(self.thumbCache) {
        
        // Initialize thumb instance by key
        id thumbObj = [self.thumbCache objectForKey: key];
        
        // Checking if current instance is not null
        if ([thumbObj isMemberOfClass: [NSNull class]]) {
            
            // Remove nulled object from cache
            [self.thumbCache removeObjectForKey: key];
        }
    }
}

- (void) removeAllObjects {
    
    // Lock using mutex
    @synchronized(self.thumbCache) {
        
        [self.thumbCache removeAllObjects];
    }
}

#pragma mark - Thumb Cache static methods

+ (instancetype) sharedInstance {
    
    static dispatch_once_t predicate = 0;
    
    // Create ThumbCache object
    static ThumbCache* thumbCache = nil;
    
    dispatch_once(&predicate, ^{
        
        // Initialize instance at one time
        thumbCache = [self new];
    });
    
    // and return (Singleton)
    return thumbCache;
}

+ (NSString *) appCachesPath {
    
    static dispatch_once_t predicate = 0;
    
    // App caches path string
    static NSString* cachesPath = nil;
    
    // Save a copy of app caches path
    // the first time if it needed
    dispatch_once(&predicate, ^{

        NSArray* cachesPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        
        // Keep current copy for later usage
        cachesPath = [[cachesPaths objectAtIndex: 0] copy];
    });
    
    return cachesPath;
}

+ (NSString *) thumbCachePathForGUID:(NSString *)guid {
    
    // Get caches path
    NSString* cachesPath = [ThumbCache appCachesPath];
    
    return [cachesPath stringByAppendingPathComponent: guid];
}

+ (void) createThumbCacheWithGUID:(NSString *)guid {
    
    // Init file manager instance
    NSFileManager* fileManager = [NSFileManager new];
    
    // Get caches path
    NSString* cachePath = [ThumbCache thumbCachePathForGUID: guid];
    
    [fileManager createDirectoryAtPath: cachePath
           withIntermediateDirectories: NO
                            attributes: nil
                                 error: nil];
}

+ (void) removeThumbCacheWithGUID:(NSString *)guid {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        // Init new file manager instance
        NSFileManager* fileManager = [NSFileManager new];
        
        // Get caches path
        NSString* cachePath = [ThumbCache thumbCachePathForGUID: guid];
        
        // Remove thumb cache directory by cache path
        [fileManager removeItemAtPath: cachePath error: nil];
    });
}

+ (void) touchThumbCacheWithGUID:(NSString *)guid {
    
    // Init new file manager instance
    NSFileManager* fileManager = [NSFileManager new];
    
    // Get caches path
    NSString* cachePath = [ThumbCache thumbCachePathForGUID: guid];
    
    // Create attributes of files dict
    NSDictionary* attributes = [NSDictionary dictionaryWithObject: [NSDate date] forKey: NSFileModificationDate];
    
    [fileManager setAttributes: attributes ofItemAtPath: cachePath error: nil];
}

+ (void) purgeThumbCachesOlderThan:(NSTimeInterval)age {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
       
        // Get current date
        NSDate* currentDate = [NSDate date];
        
        // Get caches path
        NSString* cachesPath = [ThumbCache appCachesPath];
        
        // Init new file manager
        NSFileManager* fileManager = [NSFileManager new];
        
        // Get all caches
        NSArray* cachesList = [fileManager contentsOfDirectoryAtPath: cachesPath error: nil];
        
        // Caches process in everyone of directory
        if (cachesList != nil) {
         
            // Enumerate all contents in directory
            for (NSString* cacheName in cachesList) {

                // This is a hack (using for ident kludge)
                if (cacheName.length == 36) {

                    NSString* cachePath = [cachesPath stringByAppendingPathComponent: cacheName];
                    
                    // Get all attributes for cachePath
                    NSDictionary* attributes = [fileManager attributesOfItemAtPath: cachePath error:nil];
                    
                    NSDate* currentCacheDate = [attributes objectForKey: NSFileModificationDate];
                    
                    // Get interval of current and cache dates
                    NSTimeInterval seconds = [currentDate timeIntervalSinceDate: currentCacheDate];
                    
                    // If cache time is older than age value, remove current thumb cache
                    if (seconds > age) {

                        [fileManager removeItemAtPath: cachePath error: nil];
                    }
                }
            }
        }
    });
}

@end