//
//  ToolPropertiesController.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 27.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import "ToolPropertiesController.h"
#import "DrawingToolbar.h"
#import "UIImage+Overlay.h"

@implementation ToolPropertiesController

- (instancetype) initWithLineColor:(UIColor *)lineColor lineWidth:(CGFloat)lineWidth lineAlpha:(CGFloat)lineAlpha {
    
    self = [super init];
    
    if (self) {
        
        _lineColor = lineColor;
        _lineWidth = lineWidth;
        _lineAlpha = 1.f - lineAlpha;
    }
    
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.preferredContentSize = CGSizeMake(340, 170);
    
    // Setup labels
    [self.view addSubview: [self setupLabelWithFrame: CGRectMake(15, 25, 120, 20) andText: @"Color:"]];
    [self.view addSubview: [self setupLabelWithFrame: CGRectMake(15, 75, 120, 20) andText: @"Thickness:"]];
    [self.view addSubview: [self setupLabelWithFrame: CGRectMake(15, 125, 120, 20) andText: @"Opacity:"]];
    
    // Setup color buttons
    NSArray* colors = [NSArray arrayWithObjects:
                       [UIColor colorWithRed: .086f green: .627f blue: .522f alpha: 1.f],
                       [UIColor colorWithRed: .161f green: .502f blue: .725f alpha: 1.f],
                       [UIColor colorWithRed: .173f green: .243f blue: .314f alpha: 1.f],
                       [UIColor colorWithRed: .949f green: .792f blue: .153f alpha: 1.f],
                       [UIColor colorWithRed: .906f green: .298f blue: .325f alpha: 1.f],
                       nil];

    NSMutableArray* colorButtons = [NSMutableArray array];
    NSInteger colorsCount = 5;
    
    for (int i = 0; i < colorsCount; i++) {
        
        [colorButtons addObject: [self setupButtonWithFrame: CGRectMake(128 + 40 * i, 20, 30, 30)
                                                    bgColor: [colors objectAtIndex: i]
                                                buttonIndex: (i + 1)]];
        
        [self.view addSubview: [colorButtons objectAtIndex: i]];
    }
    
    // Setup thickness slider

    UISlider* thicknessSlider = [self setupSliderWithFrame: CGRectMake(128, 70, 190, 30)
                                                  minValue: 1.f
                                                  maxValue: 30.f
                                              startupValue: self.lineWidth];

    [thicknessSlider addTarget: self
                        action: @selector(thicknessSliderUpdate:)
              forControlEvents: UIControlEventValueChanged];
    
    [self.view addSubview: thicknessSlider];
    
    // Setup opacity slider

    UISlider* opacitySlider = [self setupSliderWithFrame: CGRectMake(128, 115, 190, 30)
                                                minValue: 0.f
                                                maxValue: 1.f
                                            startupValue: self.lineAlpha];
    
    [opacitySlider addTarget: self
                      action: @selector(opacitySliderUpdate:)
            forControlEvents: UIControlEventValueChanged];
    
    [self.view addSubview: opacitySlider];
}

#pragma mark - Setup Labels

- (UILabel *) setupLabelWithFrame:(CGRect)frame andText:(NSString *)text {
    
    UILabel* label = [[UILabel alloc] initWithFrame: frame];
    label.text = text;
    label.font = [UIFont fontWithName: @"Avenir-Book" size: 18];
    
    return label;
}

#pragma mark - Setup Buttons

- (UIButton *) setupButtonWithFrame:(CGRect)frame bgColor:(UIColor *)bgColor buttonIndex:(NSInteger)buttonIndex {
    
    UIButton* button = [[UIButton alloc] initWithFrame: frame];
    button.backgroundColor = bgColor;
    
    // Setup background, when user clicked on the button
    [button setBackgroundImage: [UIImage imageFromColor: [UIColor colorWithRed: .22f green: .33f blue: .44f alpha: .6f] withFrame: CGRectMake(0, 0, 1, 1)]
                      forState: UIControlStateHighlighted];
    
    // Add tapped target for touch up event
    [button addTarget: self
               action: @selector(colorButtonTapped:)
     forControlEvents: UIControlEventTouchUpInside];
    
    button.autoresizingMask = UIViewAutoresizingNone;
    button.exclusiveTouch = YES;
    button.tag = buttonIndex;
    
    return button;
}

- (void) colorButtonTapped:(UIButton *)button {
    
    if (self.lineColor != button.backgroundColor) {
        
        self.lineColor = button.backgroundColor;
        
        if ([self.delegate respondsToSelector: @selector(colorValueUpdated:)] == YES) {
            
            [self.delegate colorValueUpdated: self.lineColor];
        }
    }
}

#pragma mark - Setup Sliders

- (UISlider *) setupSliderWithFrame:(CGRect)frame minValue:(CGFloat)minValue maxValue:(CGFloat)maxValue startupValue:(CGFloat)value {
    
    UISlider* slider = [[UISlider alloc] initWithFrame: frame];
    slider.minimumValue = minValue;
    slider.maximumValue = maxValue;
    slider.value = value;
    
    return slider;
}

- (void) thicknessSliderUpdate:(UISlider *)slider {
    
    CGFloat value = slider.value;

    if (value != self.lineWidth) {
        
        self.lineWidth = value;
        
        if ([self.delegate respondsToSelector: @selector(thickessValueUpdated:)] == YES) {
            
            [self.delegate thickessValueUpdated: self.lineWidth];
        }
    }
}

- (void) opacitySliderUpdate:(UISlider *)slider {
    
    CGFloat value = 1.f - slider.value;
    
    if (value != self.lineAlpha) {
        
        self.lineAlpha = value;
        
        if ([self.delegate respondsToSelector: @selector(thickessValueUpdated:)] == YES) {
            
            [self.delegate opacityValueUpdated: self.lineAlpha];
        }
    }
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end