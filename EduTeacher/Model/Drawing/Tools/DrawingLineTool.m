//
//  DrawingLineTool.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 26.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import "DrawingLineTool.h"

@interface DrawingLineTool ()

@property (assign, nonatomic) CGPoint firstPoint;
@property (assign, nonatomic) CGPoint lastPoint;

@end


@implementation DrawingLineTool

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
    
    // Setup color of stroke for graphics context
    CGContextSetStrokeColorWithColor(contextReference, self.lineColor.CGColor);
    
    // Setup styles for the endpoint of drawing lines
    CGContextSetLineCap(contextReference, kCGLineCapRound);
    
    // Setup width of line for graphics context
    CGContextSetLineWidth(contextReference, self.lineWidth);
    
    // Setup alpha component for new line
    CGContextSetAlpha(contextReference, self.lineAlpha);
    
    // Initialize the line from point
    CGContextMoveToPoint(contextReference, self.firstPoint.x, self.firstPoint.y);
    
    // To point
    CGContextAddLineToPoint(contextReference, self.lastPoint.x, self.lastPoint.y);
    
    // Paints a line by context path
    CGContextStrokePath(contextReference);
}

@end
