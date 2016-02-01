//
//  DrawingPenTool.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 26.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import "DrawingPenTool.h"

@implementation DrawingPenTool

@synthesize lineColor = _lineColor;
@synthesize lineAlpha = _lineAlpha;

#pragma mark - Initialization

- (instancetype) init {
    
    self = [super init];
    
    if (self) {
        
        self.lineCapStyle = kCGLineJoinRound;
        _pathReference = CGPathCreateMutable();
    }
    
    return self;
}

#pragma mark - Instance methods

- (void) dealloc {
    
    CGPathRelease(self.pathReference);
    
    self.lineColor = nil;
}

- (CGPoint) middlePoint:(CGPoint)firstPoint secondPoint:(CGPoint)secondPoint {
    
    return CGPointMake((firstPoint.x + secondPoint.x) * 0.5f, (firstPoint.y + secondPoint.y) * 0.5f);
}

- (void) setInitialPosition:(CGPoint)position {
    
    [self moveToPoint: position];
}

- (void) moveFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint {
    
    [self addQuadCurveToPoint: [self middlePoint: endPoint secondPoint: startPoint] controlPoint: startPoint];
}

- (CGRect) addPathSecondPreviousPoint:(CGPoint)secondPreviousPoint withFirstPreviousPoint:(CGPoint)firstPreviousPoint withCurrentPoint:(CGPoint)currentPoint {
    
    // Calculate middle point between first and second points
    CGPoint firstMiddlePoint = [self middlePoint: firstPreviousPoint secondPoint: secondPreviousPoint];
    
    // Calculate middle point between current point and first point
    CGPoint secondMiddlePoint = [self middlePoint: currentPoint secondPoint: firstPreviousPoint];
    
    // Create mutable path, which can be changed in future
    CGMutablePathRef subPathReference = CGPathCreateMutable();
    
    // Initialize a new subpath, which start at first middle point
    CGPathMoveToPoint(subPathReference, NULL, firstMiddlePoint.x, firstMiddlePoint.y);
    
    // Add a quadratic Bezier curve for current subpath
    CGPathAddQuadCurveToPoint(subPathReference, NULL, firstPreviousPoint.x, firstPreviousPoint.y, secondMiddlePoint.x, secondMiddlePoint.y);
    
    // Initialize a frame, which contains all points in
    // current graphical path
    CGRect bounds = CGPathGetBoundingBox(subPathReference);
    
    // Add path to current mutable path reference
    CGPathAddPath(self.pathReference, NULL, subPathReference);

    // Release subpath
    CGPathRelease(subPathReference);
    
    // Return current frame
    return bounds;
}

- (void) draw {
    
    // Initialize new context
    CGContextRef contextReference = UIGraphicsGetCurrentContext();
    
    // Add previously created a routes that will be used
    // to concatinate parts of its own
    CGContextAddPath(contextReference, self.pathReference);
    
    // Setup styles for the endpoint of drawing lines
    CGContextSetLineCap(contextReference, kCGLineCapRound);
    
    // Setup width of line for graphics context
    CGContextSetLineWidth(contextReference, self.lineWidth);
    
    // Setup color of stroke for graphics context
    CGContextSetStrokeColorWithColor(contextReference, self.lineColor.CGColor);
    
    // Setup pen tool drawing mode
    CGContextSetBlendMode(contextReference, kCGBlendModeNormal);
    
    // Setup alpha component for new curve
    CGContextSetAlpha(contextReference, self.lineAlpha);
    
    // Paints a curve by context path
    CGContextStrokePath(contextReference);
}

@end