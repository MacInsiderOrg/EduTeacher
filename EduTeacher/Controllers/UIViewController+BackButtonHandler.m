//
//  UIViewController+BackButtonHandler.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 06.02.16.
//  Copyright © 2016 Andrew Kochulab. All rights reserved.
//

#import "UIViewController+BackButtonHandler.h"

@implementation UIViewController (BackButtonHandler)

@end

@implementation UINavigationController (ShouldPopOnBackButton)

- (BOOL) navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    
    if ([self.viewControllers count] < [navigationBar.items count]) {
        return YES;
    }
    
    BOOL shouldPop = YES;
    UIViewController* viewController = [self topViewController];
    
    if ([viewController respondsToSelector:@selector(navigationShouldPopOnBackButton)]) {
        shouldPop = [viewController navigationShouldPopOnBackButton];
    }
    
    if (shouldPop) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self popViewControllerAnimated:YES];
        });
    }
    
    else {
        for (UIView* subview in [navigationBar subviews]) {
            if (subview.alpha < 1.f) {
                [UIView animateWithDuration:.25f animations:^{
                    subview.alpha = 1.f;
                }];
            }
        }
    }
    
    return NO;
}

@end