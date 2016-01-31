//
//  Functions.h
//  EduTeacher
//
//  Created by Andrew Kochulab on 20.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface Functions : NSObject

CGPDFDocumentRef CGPDFDocumentCreateUsingUrl(CFURLRef theURL, NSString *password);

@end