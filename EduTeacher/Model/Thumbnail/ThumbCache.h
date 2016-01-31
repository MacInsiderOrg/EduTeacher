//
//  ThumbCache.h
//  EduTeacher
//
//  Created by Andrew Kochulab on 20.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThumbRequest.h"

@interface ThumbCache : NSObject <NSObject>

+ (instancetype) sharedInstance;

+ (void) touchThumbCacheWithGUID:(NSString *)guid;
+ (void) createThumbCacheWithGUID:(NSString *)guid;
+ (void) removeThumbCacheWithGUID:(NSString *)guid;
+ (void) purgeThumbCachesOlderThan:(NSTimeInterval)age;
+ (NSString *) thumbCachePathForGUID:(NSString *)guid;

- (id) thumbRequest:(ThumbRequest *)thumbRequest priority:(BOOL)priority;

- (void) setObject:(UIImage *)image forKey:(NSString *)key;
- (void) removeObjectForKey:(NSString *)key;
- (void) removeNullForKey:(NSString *)key;
- (void) removeAllObjects;

@end
