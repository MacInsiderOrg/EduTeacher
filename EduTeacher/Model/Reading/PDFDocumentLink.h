//
//  PDFDocumentLink.h
//  EduTeacher
//
//  Created by Andrew Kochulab on 22.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PDFDocumentLink : NSObject <NSObject>

@property (assign, nonatomic) CGRect rect;
@property (assign, nonatomic) CGPDFDictionaryRef dictionaryReference;

+ (instancetype) newWithRect:(CGRect) linkRect dictionary:(CGPDFDictionaryRef)linkDictionary;

@end