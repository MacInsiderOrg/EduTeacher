//
//  DrawingView.h
//  EduTeacher
//
//  Created by Andrew Kochulab on 20.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawingTool.h"

typedef enum {
    
    DrawingToolTypePen,
    DrawingToolTypeLine,
    DrawingToolTypeRectangleStroke,
    DrawingToolTypeRectangleFill,
    DrawingToolTypeEllipseStroke,
    DrawingToolTypeEllipseFill,
    DrawingToolTypeText,
    DrawingToolTypeEraser
    
} DrawingToolType;

@protocol DrawingViewDelegate;

@interface DrawingView : UIView <UITextViewDelegate>

// Storing selected drawing tool
@property (assign, nonatomic) DrawingToolType drawingTool;

// Receive message (start, stop drawing)
@property (assign, nonatomic) id <DrawingViewDelegate> delegate;

// Properties, which using for setup drawing tool preferences
@property (strong, nonatomic) UIColor* lineColor;
@property (assign, nonatomic) CGFloat lineWidth;
@property (assign, nonatomic) CGFloat lineAlpha;

// Properties for getting current drawing
@property (strong, nonatomic, readonly) UIImage* image;
@property (strong, nonatomic) UIImage* previousImage;
@property (assign, nonatomic) NSUInteger undoSteps;

// Using for loading external image
- (void) loadImage:(UIImage *)image;
- (void) loadImageData:(NSData *)imageData;

// Undo and redo methods
- (BOOL) canUndo;
- (void) undoLatestStep;

- (BOOL) canRedo;
- (void) redoLatestStep;

// Erase all drawings
- (void) clear;

@end


@protocol DrawingViewDelegate <NSObject>

@optional
- (void) drawingView:(DrawingView *)drawingView willBeginDrawUsingTool:(id <DrawingTool>)drawingTool;

- (void) drawingView:(DrawingView *)drawingView didEndDrawUsingTool:(id<DrawingTool>)drawingTool;

@end
