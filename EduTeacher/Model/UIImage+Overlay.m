//
//  UIImage+Overlay.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 28.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import "UIImage+Overlay.h"

@implementation UIImage (Overlay)

+ (UIImage *) imageFromColor:(UIColor *)color withFrame:(CGRect)frame {
    
    // Create a bitmap context
    UIGraphicsBeginImageContext(frame.size);
    
    // Setup current graphics context
    CGContextRef contextReference = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(contextReference, [color CGColor]);
    
    // Fill initial rectangle
    CGContextFillRect(contextReference, frame);
    
    // Create image by contextReference
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Return new colorful image
    return image;
}

@end