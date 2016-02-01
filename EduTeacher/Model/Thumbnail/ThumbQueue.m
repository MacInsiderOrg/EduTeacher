//
//  ThumbQueue.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 20.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import "ThumbQueue.h"
#import "ThumbOperation.h"

@interface ThumbQueue ()

@property (strong, nonatomic) NSOperationQueue* loadQueue;
@property (strong, nonatomic) NSOperationQueue* workQueue;

@end


@implementation ThumbQueue

#pragma mark - Singleton Method

+ (instancetype) sharedInstance {
    
    static dispatch_once_t predicate = 0;
    
    // Create Thumb Queue object
    static ThumbQueue* thumbQueue = nil;
    
    dispatch_once(&predicate, ^{
        
        // Initialize object at one time
        thumbQueue = [self new];
    });
    
    return thumbQueue;
}

#pragma mark - Instance methods

- (instancetype) init {
 
    self = [super init];
    
    if (self) {
        
        // Init load queue
        self.loadQueue = [NSOperationQueue new];
        
        // Setup name and max concurrent operations
        [self.loadQueue setName: @"ThumbLoadQueue"];
        [self.loadQueue setMaxConcurrentOperationCount: 1];
        
        // Init work queue
        self.workQueue = [NSOperationQueue new];
        
        // Setup name and max concurrent operations
        [self.workQueue setName: @"ThumbWorkQueue"];
        [self.workQueue setMaxConcurrentOperationCount: 1];
    }
    
    return self;
}

- (void) addLoadOperation:(NSOperation *)operation {
    
    // Check if input operation is instance of ThumbOperation class
    if ([operation isKindOfClass: [ThumbOperation class]]) {

        // Add this instance to queue
        [self.loadQueue addOperation: operation];
    }
}

- (void) addWorkOperation:(NSOperation *)operation {
    
    // Check if input operation is instance of ThumbOperation class
    if ([operation isKindOfClass: [ThumbOperation class]]) {
        
        // Add this instance to queue
        [self.workQueue addOperation: operation];
    }
}

- (void) cancelOperationsWithGUID:(NSString *)guid {
    
    // Stop execution all of queues
    [self.loadQueue setSuspended: YES];
    [self.workQueue setSuspended: YES];
    
    // Cancel all operations, which loadQueue contains
    for (ThumbOperation* operation in self.loadQueue.operations) {
        
        // Check class of instance
        if ([operation isKindOfClass: [ThumbOperation class]]) {
            if ([operation.guid isEqualToString: guid]) {
                [operation cancel];
            }
        }
    }
    
    // Cancel all operations, which workQueue contains
    for (ThumbOperation* operation in self.workQueue.operations) {
        
        // Check class of instance
        if ([operation isKindOfClass: [ThumbOperation class]]) {
            if ([operation.guid isEqualToString: guid]) {
                [operation cancel];
            }
        }
    }
    
    // Resume execution
    [self.loadQueue setSuspended: NO];
    [self.workQueue setSuspended: NO];
}

- (void) cancelAllOperations {
    
    // Cancel executing all operations in queues
    [self.loadQueue cancelAllOperations];
    [self.workQueue cancelAllOperations];
}

@end