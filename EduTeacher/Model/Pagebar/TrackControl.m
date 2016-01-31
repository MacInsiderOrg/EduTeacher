//
//  TrackControl.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 21.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import "TrackControl.h"

@implementation TrackControl

#pragma mark - Initialization

- (instancetype) initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame: frame];
    
    if (self) {
        
        self.autoresizesSubviews = NO;
        self.userInteractionEnabled = YES;
        self.contentMode = UIViewContentModeRedraw;
        self.autoresizingMask = UIViewAutoresizingNone;
        self.backgroundColor = [UIColor clearColor];
        self.exclusiveTouch = YES;
    }
    
    return self;
}

#pragma mark - Setup limited value

- (CGFloat) limitValue:(CGFloat)value {
    
    CGFloat minimumX = CGRectGetMinX(self.bounds);
    CGFloat maximumX = CGRectGetWidth(self.bounds) - 1.f;
    
    if (value < minimumX) {
        value = minimumX;
    }
    
    if (value > maximumX) {
        value = maximumX;
    }
    
    return value;
}

#pragma mark - UIControl methods

- (BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    // Current touch point
    CGPoint point = [touch locationInView: self];
    
    // Limit control value
    self.value = [self limitValue: point.x];
    
    return YES;
}

- (BOOL) continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    // Only if user touched inside in Control
    if (self.touchInside == YES) {
        
        // Current touch point
        CGPoint point = [touch locationInView: touch.view];
        
        CGFloat x = [self limitValue: point.x];
        
        if (x != self.value) {
            
            self.value = x;
            [self sendActionsForControlEvents: UIControlEventValueChanged];
        }
    }
    
    return YES;
}

- (void) endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    // Current touch point
    CGPoint point = [touch locationInView: self];
    
    // Limit control value
    self.value = [self limitValue: point.x];
}

@end
