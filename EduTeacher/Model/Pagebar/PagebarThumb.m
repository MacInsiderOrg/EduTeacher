//
//  PagebarThumb.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 21.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import "PagebarThumb.h"

@implementation PagebarThumb

#pragma mark - Initialization

- (instancetype) initWithFrame:(CGRect)frame {
    return [self initWithFrame: frame smallThumb: NO];
}

- (instancetype) initWithFrame:(CGRect)frame smallThumb:(BOOL)isSmallThumb {
    
    self = [super initWithFrame: frame];
    
    if (self) {
        
        CGFloat value = (isSmallThumb ? 0.6f : 0.7f);
        
        UIColor* bgColor = [UIColor colorWithWhite: 0.8f alpha: value];
        self.backgroundColor = bgColor;
        self.imageView.backgroundColor = bgColor;
        
        self.imageView.layer.borderColor = [UIColor colorWithWhite: 0.4f alpha: 0.6f].CGColor;
        self.imageView.layer.borderWidth = 1.f;
    }
    
    return self;
}

@end
