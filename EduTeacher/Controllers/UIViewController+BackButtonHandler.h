//
//  UIViewController+BackButtonHandler.h
//  EduTeacher
//
//  Created by Andrew Kochulab on 06.02.16.
//  Copyright © 2016 Andrew Kochulab. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BackButtonHandler <NSObject>

@optional
- (BOOL) navigationShouldPopOnBackButton;

@end

@interface UIViewController (BackButtonHandler) <BackButtonHandler>

@end