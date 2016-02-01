//
//  MainPagebar.h
//  EduTeacher
//
//  Created by Andrew Kochulab on 20.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThumbView.h"

@class PDFDocument;
@class MainPagebar;

// Using in PDFDocumentViewController
@protocol MainPagebarDelegate <NSObject>

- (void)pagebar:(MainPagebar *)pageBar gotoPage:(NSInteger)page;

@end

// Using for display pages list in bottom of super view
@interface MainPagebar : UIView

@property (weak, nonatomic) id <MainPagebarDelegate> delegate;

- (instancetype) initWithFrame:(CGRect)frame document:(PDFDocument *)document;

- (void) showPagebar;
- (void) hidePagebar;

- (void) updatePagebar;

@end