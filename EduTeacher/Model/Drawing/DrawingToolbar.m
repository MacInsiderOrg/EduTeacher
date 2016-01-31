//
//  DrawingToolbar.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 19.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import "DrawingToolbar.h"
#import "UIImage+Overlay.h"

@implementation DrawingToolbar {

    NSBundle* currentBundle;
    
    CGFloat buttonX;
    CGFloat buttonY;
    CGFloat buttonWidth;
    CGFloat buttonHeight;
    CGFloat buttonSpacing;
    
    CGFloat titleY;
    CGFloat leftButtonY;
    CGFloat titleHeight;
    CGFloat iconButtonHeight;
}

#pragma mark - Initialization

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame: frame];
    
    if (self) {
        
        // Init default values for private properties
        buttonX = buttonY = 8.f;
        buttonWidth = buttonHeight = 36.f;
        buttonSpacing = 2.f;
        
        currentBundle = [NSBundle bundleForClass: [self class]];
        
        titleY = buttonY;
        leftButtonY = buttonY;
        titleHeight = (CGRectGetHeight(self.bounds) - titleY * 2);
        iconButtonHeight = buttonHeight;
        
        // Init buttons with image and target
        
        _penButton = [self setupButton: _penButton withImagePath: @"pen-button" andTag: 1 enabledMargin: YES];
        _textButton = [self setupButton: _textButton withImagePath: @"text-button" andTag: 2 enabledMargin: YES];
        _lineButton = [self setupButton: _lineButton withImagePath: @"line-button" andTag: 3 enabledMargin: YES];
        _squareButton = [self setupButton: _squareButton withImagePath: @"square-button" andTag: 4 enabledMargin: YES];
        _highlightButton = [self setupButton: _highlightButton withImagePath: @"squarefill-button" andTag: 5 enabledMargin: YES];
        _circleButton = [self setupButton: _circleButton withImagePath: @"circle-button" andTag: 6 enabledMargin: YES];
        _circleFillButton = [self setupButton: _circleButton withImagePath: @"circlefill-button" andTag: 7 enabledMargin: YES];
        _eraserButton = [self setupButton: _eraserButton withImagePath: @"eraser-button" andTag: 8 enabledMargin: YES];
        _colorButton = [self setupButton: _colorButton withImagePath: @"square-button" andTag: 9 enabledMargin: YES];
        _undoButton = [self setupButton: _undoButton withImagePath: @"undo-button" andTag: 10 enabledMargin: YES];
        _redoButton = [self setupButton: _redoButton withImagePath: @"redo-button" andTag: 11 enabledMargin: YES];
        _clearButton = [self setupButton: _clearButton withImagePath: @"clear-button" andTag: 12 enabledMargin: NO];
        
        // Setup color button image by blue color
        [_colorButton setImage: [UIImage imageFromColor: [UIColor colorWithRed: .173f green: .243f blue: .314f alpha: 1.f]
                                                     withFrame: CGRectMake(0, 0, buttonWidth / 2, buttonHeight / 2)]
                      forState: UIControlStateNormal];
        
        _colorButton.imageView.layer.cornerRadius = 10;
        _colorButton.imageView.layer.borderColor = [UIColor colorWithRed: .22f green: .33f blue: .44f alpha: 1.f].CGColor;
        _colorButton.imageView.layer.borderWidth = 1;
        
        _colorButton.adjustsImageWhenHighlighted = NO;
        [_colorButton setHighlighted: NO];
        
        [_colorButton addTarget: self
                         action: @selector(touchCanceled:)
               forControlEvents: UIControlEventTouchUpOutside];
        
        // Add all button to DrawingToolbar view
        [self addSubview: _penButton];
        [self addSubview: _textButton];
        [self addSubview: _lineButton];
        [self addSubview: _squareButton];
        [self addSubview: _circleButton];
        [self addSubview: _circleFillButton];
        [self addSubview: _highlightButton];
        [self addSubview: _colorButton];
        [self addSubview: _undoButton];
        [self addSubview: _redoButton];
        [self addSubview: _eraserButton];
        [self addSubview: _clearButton];
        
        // Clear all buttons selection
        [self clearButtonSelection: 12];
    }
    
    return self;
}

#pragma mark - Instance methods

- (UIButton *) setupButton:(UIButton *)button
             withImagePath:(NSString *)imagePath
                    andTag:(NSInteger)tag
             enabledMargin:(BOOL)hasMargin {

    // Initialize custom button
    button = [UIButton buttonWithType: UIButtonTypeCustom];
    button.frame = CGRectMake(buttonX, leftButtonY, buttonWidth, iconButtonHeight);

    // Setup image
    UIImage* image = [[UIImage imageNamed: imagePath
                                 inBundle: currentBundle
            compatibleWithTraitCollection: nil]
                      imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate];
    
    [button setImage: image forState: UIControlStateNormal];
    
    button.tintColor = [UIColor blackColor];
    
    // Add tapped target for touch up event
    [button addTarget: self
               action: @selector(drawButtonTapped:)
     forControlEvents: UIControlEventTouchUpInside];
    
    // Setup image in background
    [button setBackgroundImage: [UIImage imageFromColor: [[UIColor colorWithRed: 0.22f green: 0.33f blue: 0.44f alpha: 1.f] colorWithAlphaComponent: 0.4f]
                                                     withFrame: CGRectMake(0, 0, 1, 1)]
                      forState: UIControlStateHighlighted];
    
    button.autoresizingMask = UIViewAutoresizingNone;
    button.exclusiveTouch = YES;
    button.tag = tag;

    // If current image not last, increment instance values
    if (hasMargin == YES) {
        leftButtonY += (iconButtonHeight + buttonSpacing);
        titleY += (iconButtonHeight + buttonSpacing);
        titleHeight -= (iconButtonHeight + buttonSpacing);
    }
    
    return button;
}

- (void) showToolbar {
    
    if (self.hidden == YES) {
        [UIView animateWithDuration: 0.25f
                              delay: 0.f
                            options: UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                         animations: ^{

                             self.hidden = NO;
                             self.alpha = 1.f;
                             
                             CGRect toolbarRect = self.frame;
                             
                             self.frame = CGRectMake(CGRectGetMinX(toolbarRect) + 52.f, CGRectGetMinY(toolbarRect), CGRectGetWidth(toolbarRect), CGRectGetHeight(toolbarRect));
                         }
                         completion: nil];
    }
}

- (void) hideToolbar {
    
    if (self.hidden == NO) {
        [UIView animateWithDuration: 0.25f
                              delay: 0.f
                            options: UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                         animations: ^{
                             
                             self.alpha = 0.f;
                             CGRect toolbarRect = self.frame;
                             
                             self.frame = CGRectMake(CGRectGetMinX(toolbarRect) - 52.f, CGRectGetMinY(toolbarRect), CGRectGetWidth(toolbarRect), CGRectGetHeight(toolbarRect));
                         }
                         completion: ^(BOOL finished) {

                             self.hidden = YES;
                         }];
    }
}

- (void) drawButtonTapped:(UIButton *)button {
    [self.delegate tappedInToolbar: self drawButton: button];
}

- (void) touchCanceled:(UIButton *)button {
    [self.delegate drawingToolbar: self touchesCanceled: button];
}

- (void) clearButtonSelection:(NSInteger)upto {
    
    NSArray* buttons = [NSArray arrayWithObjects:
                        self.penButton,
                        self.textButton,
                        self.lineButton,
                        self.squareButton,
                        self.circleButton,
                        self.circleFillButton,
                        self.highlightButton,
                        self.eraserButton,
                        self.colorButton,
                        self.undoButton,
                        self.redoButton,
                        self.clearButton,
                        nil];
    
    for (UIButton* button in buttons) {
        
        if (upto >= button.tag) {
            
            // Clear selection
            button.backgroundColor = [UIColor clearColor];
            button.tintColor = [UIColor blackColor];
        }
    }
}

@end
