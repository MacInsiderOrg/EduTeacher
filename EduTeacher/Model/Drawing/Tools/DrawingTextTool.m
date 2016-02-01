//
//  DrawingTextTool.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 26.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import "DrawingTextTool.h"
#import <CoreText/CoreText.h>

@interface DrawingTextTool ()

@property (assign, nonatomic) CGPoint firstPoint;
@property (assign, nonatomic) CGPoint lastPoint;

@end


@implementation DrawingTextTool

@synthesize lineColor = _lineColor;
@synthesize lineAlpha = _lineAlpha;
@synthesize lineWidth = _lineWidth;
@synthesize attributedText = _attributedText;

#pragma mark - Instance methods

- (void) dealloc {
    
    self.lineColor = nil;
    self.attributedText = nil;
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
    
    // Setup context with copy of current graphics context
    CGContextSaveGState(contextReference);
    
    // Setup alpha component for new text tool
    CGContextSetAlpha(contextReference, self.lineAlpha);
    
    // Setup text tool points
    CGRect viewBounds = CGRectMake(MIN(self.firstPoint.x, self.lastPoint.x),
                                   MIN(self.firstPoint.y, self.lastPoint.y),
                                   fabs(self.firstPoint.x - self.lastPoint.x),
                                   fabs(self.firstPoint.y - self.lastPoint.y));
    
    // Flip current context coordinates
    CGContextTranslateCTM(contextReference, 0, CGRectGetHeight(viewBounds));
    CGContextScaleCTM(contextReference, 1.f, -1.f);
    
    // Set the text matrix
    CGContextSetTextMatrix(contextReference, CGAffineTransformIdentity);
    
    // Create a path, which bounds the area,
    // where user will be drawing text.
    CGMutablePathRef pathReference = CGPathCreateMutable();
    
    // Initialize a rectangular path
    CGRect bounds = CGRectMake(CGRectGetMinX(viewBounds),
                               - (CGRectGetMinY(viewBounds)),
                               CGRectGetWidth(viewBounds),
                               CGRectGetHeight(viewBounds));
    
    CGPathAddRect(pathReference, NULL, bounds);
    
    // Create a framesetter with initial attributed string text
    CTFramesetterRef framesetterReference = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) self.attributedText);
    
    // Create a frame
    CTFrameRef frame = CTFramesetterCreateFrame(framesetterReference, CFRangeMake(0, 0), pathReference, NULL);
    
    // Draw the specified frame in current context
    CTFrameDraw(frame, contextReference);
    
    // Release all objects, which we used
    CFRelease(frame);
    CFRelease(framesetterReference);
    CFRelease(pathReference);
    
    // Restore context and setup it to recently saved state
    CGContextRestoreGState(contextReference);
}

@end