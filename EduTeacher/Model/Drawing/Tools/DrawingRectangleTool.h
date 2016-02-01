//
//  DrawingRectangleTool.h
//  EduTeacher
//
//  Created by Andrew Kochulab on 26.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DrawingTool.h"

@interface DrawingRectangleTool : NSObject <DrawingTool>

@property (assign, nonatomic) BOOL fill;

@end