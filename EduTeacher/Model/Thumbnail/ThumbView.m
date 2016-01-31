//
//  ThumbView.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 20.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import "ThumbView.h"

@implementation ThumbView

#pragma mark - Initialization

- (instancetype) initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame: frame];
    
    if (self) {
        
        self.autoresizesSubviews = NO;
        self.userInteractionEnabled = NO;
        
        self.contentMode = UIViewContentModeRedraw;
        self.autoresizingMask = UIViewAutoresizingNone;
        self.backgroundColor = [UIColor clearColor];
        
        _imageView = [[UIImageView alloc] initWithFrame: self.bounds];

        _imageView.autoresizesSubviews = NO;
        _imageView.userInteractionEnabled = NO;
        _imageView.autoresizingMask = UIViewAutoresizingNone;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;

        [self addSubview: _imageView];
    }
    
    return self;
}

#pragma mark - Instance methods

- (void) showImage:(UIImage *)image {
    
    self.imageView.image = image;
}

- (void) showTouched:(BOOL)currentTouched {
    
    // todo
}

- (void) reuse {
    
    self.targetTag = 0;
    
    // Cancel current operation
    [self.operation cancel];
    
    self.imageView.image = nil;
}


- (void) removeFromSuperview {

    // Clear target tag
    self.targetTag = 0;
    
    // Cancel current operation
    [self.operation cancel];
    
    // Remove view
    [super removeFromSuperview];
}

@end
