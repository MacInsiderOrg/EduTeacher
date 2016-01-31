//
//  ThumbView.h
//  EduTeacher
//
//  Created by Andrew Kochulab on 20.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThumbView : UIView

@property (strong, nonatomic) UIImageView* imageView;
@property (strong, atomic) NSOperation* operation;
@property (assign, nonatomic) NSUInteger targetTag;

- (void) showImage:(UIImage *)image;
- (void) showTouched:(BOOL)currentTouched;

- (void) reuse;

@end
