//
//  ContentThumb.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 23.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import "ContentThumb.h"

@implementation ContentThumb

#pragma mark - Initialization

- (instancetype) initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame: frame];
    
    if (self) {
        
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
    }
    
    return self;
}

@end