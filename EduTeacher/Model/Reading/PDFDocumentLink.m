//
//  PDFDocumentLink.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 22.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import "PDFDocumentLink.h"

@implementation PDFDocumentLink

#pragma mark - Initialization

+ (instancetype) newWithRect:(CGRect)linkRect dictionary:(CGPDFDictionaryRef)linkDictionary {

    return [[PDFDocumentLink alloc] initWithRect: linkRect dictionary: linkDictionary];
}

- (instancetype) initWithRect:(CGRect)linkRect dictionary:(CGPDFDictionaryRef)linkDictionary {
    self = [super init];
    
    if (self) {

        // Setup links
        _dictionaryReference = linkDictionary;
        
        // Setup rect
        _rect = linkRect;
    }
    
    return self;
}

@end