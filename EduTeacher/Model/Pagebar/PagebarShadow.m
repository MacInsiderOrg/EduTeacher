//
//  PagebarShadow.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 21.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import "PagebarShadow.h"

@implementation PagebarShadow

+ (Class)layerClass {
    
    // Return the layer for current instance
    return [CAGradientLayer class];
}

#pragma mark - Initialization

- (instancetype) initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame: frame];
    
    if (self) {
        
        self.autoresizesSubviews = NO;
        self.userInteractionEnabled = NO;
        self.contentMode = UIViewContentModeRedraw;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];
        
        CAGradientLayer* layer = (CAGradientLayer *) self.layer;
        UIColor* blackColor = [UIColor colorWithWhite: 0.42f alpha: 1.f];
        UIColor* clearColor = [UIColor colorWithWhite: 0.42f alpha: 0.f];
        
        layer.colors = [NSArray arrayWithObjects: (id) clearColor.CGColor, (id) blackColor.CGColor, nil];
    }
    
    return self;
}

@end
