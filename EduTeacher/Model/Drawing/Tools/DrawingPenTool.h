//
//  DrawingPenTool.h
//  EduTeacher
//
//  Created by Andrew Kochulab on 26.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawingTool.h"

@interface DrawingPenTool : UIBezierPath <DrawingTool>

@property (assign, nonatomic) CGMutablePathRef pathReference;

- (CGRect) addPathSecondPreviousPoint:(CGPoint)secondPreviousPoint withFirstPreviousPoint:(CGPoint)firstPreviousPoint withCurrentPoint:(CGPoint)currentPoint;

@end