//
//  ThumbOperation.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 20.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import "ThumbOperation.h"

@implementation ThumbOperation

#pragma mark - Initialization

- (instancetype) initWithGUID:(NSString *)guid {
    
    self = [super init];
    
    if (self) {
        _guid = guid;
    }
    
    return self;
}

@end