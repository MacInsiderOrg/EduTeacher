//
//  ContentPage.h
//  EduTeacher
//
//  Created by Andrew Kochulab on 20.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentPage : UIView

- (instancetype) initWithUrl:(NSURL *)fileUrl page:(NSInteger)page password:(NSString *)password;

- (UIImage *) getDrawingImage;

- (void) showDrawingView:(UIImage *)image;
- (void) hideDrawingView;

- (id) processSingleTap: (UITapGestureRecognizer *)recognizer;

@end