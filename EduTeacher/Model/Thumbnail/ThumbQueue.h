//
//  ThumbQueue.h
//  EduTeacher
//
//  Created by Andrew Kochulab on 20.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThumbQueue : NSObject <NSObject>

+ (instancetype) sharedInstance;

- (void) addLoadOperation:(NSOperation *)operation;
- (void) addWorkOperation:(NSOperation *)operation;

- (void) cancelOperationsWithGUID:(NSString *)guid;
- (void) cancelAllOperations;

@end
