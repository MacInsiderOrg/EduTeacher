//
//  ThumbFetch.h
//  EduTeacher
//
//  Created by Andrew Kochulab on 20.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import "ThumbQueue.h"
#import "ThumbOperation.h"

@class ThumbRequest;

@interface ThumbFetch : ThumbOperation

- (instancetype) initWithRequest:(ThumbRequest *)thumbRequest;

@end
