//
//  DrawingToolbar.h
//  EduTeacher
//
//  Created by Andrew Kochulab on 19.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DrawingToolbar;

@protocol DrawingToolbarDelegate <NSObject>

- (void) tappedInToolbar:(DrawingToolbar *)toolbar drawButton:(UIButton *)button;
- (void) drawingToolbar:(DrawingToolbar *)toolbar touchesCanceled:(UIButton *)button;

@end


@interface DrawingToolbar : UIView

@property (strong, nonatomic) UIButton* penButton;
@property (strong, nonatomic) UIButton* textButton;
@property (strong, nonatomic) UIButton* colorButton;

@property (strong, nonatomic) UIButton* lineButton;
@property (strong, nonatomic) UIButton* squareButton;
@property (strong, nonatomic) UIButton* circleButton;
@property (strong, nonatomic) UIButton* circleFillButton;
@property (strong, nonatomic) UIButton* highlightButton;

@property (strong, nonatomic) UIButton* undoButton;
@property (strong, nonatomic) UIButton* redoButton;
@property (strong, nonatomic) UIButton* eraserButton;
@property (strong, nonatomic) UIButton* clearButton;

@property (weak, nonatomic) id <DrawingToolbarDelegate> delegate;

- (instancetype) initWithFrame:(CGRect)frame;

- (void) showToolbar;
- (void) hideToolbar;

- (void) clearButtonSelection:(NSInteger)upto;

@end