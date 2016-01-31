//
//  ContentView.h
//  EduTeacher
//
//  Created by Andrew Kochulab on 20.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThumbView.h"

@class ContentView;

@protocol ContentViewDelegate <NSObject>

- (void) contentView:(ContentView *)contentView touchesBegan:(NSSet *)touches;
//- (void) contentView:(ContentView *)contentView touchesCanceled:(NSSet *)touches;

@end


@interface ContentView : UIScrollView

@property (weak, nonatomic) id <ContentViewDelegate> message;

- (instancetype) initWithFrame:(CGRect)frame fileURL:(NSURL *)fileURL page:(NSInteger)page password:(NSString *)password;

- (void) showPageThumb:(NSURL *)fileURL page:(NSInteger)page password:(NSString *)password guid:(NSString *)guid;

- (id) processSingleTap:(UIGestureRecognizer *)recognizer;

- (void) zoomIncrement:(UITapGestureRecognizer *)recognizer;
- (void) zoomDecrement:(UITapGestureRecognizer *)recognizer;

- (void) zoomResetAnimated:(BOOL)animated;

- (void) setContentDrawingImageView:(UIImage *)drawingImage;

@end
