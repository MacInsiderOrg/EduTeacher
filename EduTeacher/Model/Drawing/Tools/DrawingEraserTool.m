//
//  DrawingEraserTool.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 26.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import "DrawingEraserTool.h"

@implementation DrawingEraserTool

#pragma mark - Instance methods

- (void) draw {
    
    // Initialize new context
    CGContextRef contextReference = UIGraphicsGetCurrentContext();
    
    // Setup context with copy of current graphics context
    CGContextSaveGState(contextReference);
    
    // Add previously created a routes that will be used
    // to remove parts of its own
    CGContextAddPath(contextReference, self.pathReference);
    
    // Setup styles for the endpoint of drawing lines
    CGContextSetLineCap(contextReference, kCGLineCapRound);
    
    // Setup width of line for graphics context
    CGContextSetLineWidth(contextReference, self.lineWidth);
    
    // Setup clear utility mode
    CGContextSetBlendMode(contextReference, kCGBlendModeClear);
    
    // Erase area, where user tapped
    CGContextStrokePath(contextReference);
    
    // Restore context and setup it to recently saved state
    CGContextRestoreGState(contextReference);
}

@end
