//
//  PDFDocumentViewController.h
//  EduTeacher
//
//  Created by Andrew Kochulab on 19.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import <UIKit/UIKit.h>

// View Controller (displaying pdf document and given oportunity
// to drawing elements in View

@class DrawingView;
@class PDFDocument;

@interface PDFDocumentViewController : UIViewController

@property (strong, nonatomic) DrawingView* drawingView;

@property (strong, nonatomic) UIColor* lineColor;
@property (strong, nonatomic) NSNumber* lineWidth;
@property (strong, nonatomic) NSNumber* lineAlpha;

- (instancetype) initWithPDFDocument:(PDFDocument *)document;

@end