//
//  DrawingRectangleTool.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 26.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import "DrawingRectangleTool.h"

@interface DrawingRectangleTool ()

@property (assign, nonatomic) CGPoint firstPoint;
@property (assign, nonatomic) CGPoint lastPoint;

@end


@implementation DrawingRectangleTool

@synthesize lineColor = _lineColor;
@synthesize lineWidth = _lineWidth;
@synthesize lineAlpha = _lineAlpha;

#pragma mark - Instance methods

- (void) dealloc {
    
    self.lineColor = nil;
}

- (void) setInitialPosition:(CGPoint)position {
    
    self.firstPoint = position;
}

- (void) moveFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint {
    
    self.lastPoint = endPoint;
}

- (void) draw {
    
    // Initialize new context
    CGContextRef contextReference = UIGraphicsGetCurrentContext();
    
    // Setup alpha component for new rectangle
    CGContextSetAlpha(contextReference, self.lineAlpha);
    
    // Setup rectangle points
    CGRect rectToFill = CGRectMake(self.firstPoint.x,
                                   self.firstPoint.y,
                                   self.lastPoint.x - self.firstPoint.x,
                                   self.lastPoint.y - self.firstPoint.y);
    
    // Using, when user clicked in toolbar fill rectangle button
    if (self.fill) {
        
        // Setup fill color for graphics context
        CGContextSetFillColorWithColor(contextReference, self.lineColor.CGColor);
        
        // Fill above created rectangle with current context background color
        CGContextFillRect(UIGraphicsGetCurrentContext(), rectToFill);
    }
    
    // Otherwise, draw rectangle only with stroke and transparent inner part
    else {
        
        // Setup color of stroke for graphics context
        CGContextSetStrokeColorWithColor(contextReference, self.lineColor.CGColor);
        
        // Setup width of line for graphics context
        CGContextSetLineWidth(contextReference, self.lineWidth);
        
        // Fill above created rectangle with given parameters
        CGContextStrokeRect(UIGraphicsGetCurrentContext(), rectToFill);
    }
}

@end