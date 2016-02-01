//
//  ToolPropertiesController.h
//  EduTeacher
//
//  Created by Andrew Kochulab on 27.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ToolPropertiesController;

@protocol ToolPropertiesDelegate <NSObject>

- (void) colorValueUpdated:(UIColor *)color;
- (void) thickessValueUpdated:(CGFloat)thickness;
- (void) opacityValueUpdated:(CGFloat)opacity;

@end

@interface ToolPropertiesController : UIViewController

@property (weak, nonatomic) id <ToolPropertiesDelegate> delegate;

@property (strong, nonatomic) UIColor* lineColor;
@property (assign, nonatomic) CGFloat lineWidth;
@property (assign, nonatomic) CGFloat lineAlpha;

- (instancetype) initWithLineColor:(UIColor *)lineColor lineWidth:(CGFloat)lineWidth lineAlpha:(CGFloat)lineAlpha;

@end