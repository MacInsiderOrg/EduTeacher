//
//  ThumbOperation.h
//  EduTeacher
//
//  Created by Andrew Kochulab on 20.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThumbOperation : NSOperation

@property (strong, nonatomic, readonly) NSString* guid;

- (instancetype) initWithGUID:(NSString *)guid;

@end