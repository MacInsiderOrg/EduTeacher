//
//  DrawingTool.h
//  EduTeacher
//
//  Created by Andrew Kochulab on 26.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol DrawingTool <NSObject>

@property (strong, nonatomic) UIColor* lineColor;
@property (assign, nonatomic) CGFloat lineWidth;
@property (assign, nonatomic) CGFloat lineAlpha;

// Setup initial position (when user start drawing)
- (void) setInitialPosition:(CGPoint)position;

// Setup start and end points for drawing tool
- (void) moveFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint;

// Using for display current drawing tool in user screen
- (void) draw;

@end
