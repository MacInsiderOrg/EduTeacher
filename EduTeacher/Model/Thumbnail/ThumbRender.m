//
//  ThumbRender.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 20.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import "ThumbRender.h"
#import "ThumbCache.h"
#import "ThumbView.h"
#import "Functions.h"

#import <ImageIO/ImageIO.h>

@interface ThumbRender ()

@property (strong, nonatomic) ThumbRequest* thumbRequest;

@end


@implementation ThumbRender

#pragma mark - Initialization

- (instancetype) initWithRequest:(ThumbRequest *)thumbRequest {
    
    self = [super initWithGUID: thumbRequest.guid];
    
    if (self) {
        _thumbRequest = thumbRequest;
    }
    
    return self;
}

#pragma mark - Instance methods

- (void) cancel {
    
    // Cancel current operation
    [super cancel];
    
    // Break current operation
    self.thumbRequest.thumbView.operation = nil;
    
    // Release target thumb view
    self.thumbRequest.thumbView = nil;
    
    [[ThumbCache sharedInstance] removeNullForKey: self.thumbRequest.cacheKey];
}

- (NSURL *) thumbFileURL {
    
    // Init file manager instance
    NSFileManager* fileManager = [NSFileManager new];
    
    // Get current path for cache
    NSString* cachePath = [ThumbCache thumbCachePathForGUID: self.thumbRequest.guid];
    
    [fileManager createDirectoryAtPath: cachePath
           withIntermediateDirectories: NO
                            attributes: nil
                                 error: NULL];
    
    // Get File name
    NSString* fileName = [[NSString alloc] initWithFormat: @"%@.png", self.thumbRequest.thumbName];
    
    return [NSURL fileURLWithPath: [cachePath stringByAppendingPathComponent: fileName]];
}

- (void) main {
    
    // Get current thumb page number
    NSInteger page = self.thumbRequest.thumbPage;
    
    // Get document password
    NSString* password = self.thumbRequest.filePassword;
    
    // Create image and file references
    CGImageRef imageReference = nil;
    CFURLRef fileURL = (__bridge CFURLRef) self.thumbRequest.fileURL;
    
    // Initialize documentReference by fileUrl and password
    CGPDFDocumentRef documentReference = CGPDFDocumentCreateUsingUrl(fileURL, password);
    
    // Check if current document exist
    if (documentReference != NULL) {
        
        // Initialize current page reference in document
        CGPDFPageRef pdfPageReference = CGPDFDocumentGetPage(documentReference, page);
        
        // Check if current page exist
        if (pdfPageReference != NULL) {
            
            // Setup thumb width and height
            CGFloat thumbWidth = self.thumbRequest.thumbSize.width;
            CGFloat thumbHeight = self.thumbRequest.thumbSize.height;
            
            CGRect cropBoxRect = CGPDFPageGetBoxRect(pdfPageReference, kCGPDFCropBox);
            CGRect mediaBoxRect = CGPDFPageGetBoxRect(pdfPageReference, kCGPDFMediaBox);
            CGRect effectiveRect = CGRectIntersection(cropBoxRect, mediaBoxRect);
            
            // Setup angle for rotating page
            NSInteger pageRotate = CGPDFPageGetRotationAngle(pdfPageReference);
            
            CGFloat pageWidth = 0.f;
            CGFloat pageHeight = 0.f;
            
            // Rotate current page (in degrees)
            switch (pageRotate) {
                
                default:
                case 0:
                case 180:
                    pageWidth = CGRectGetWidth(effectiveRect);
                    pageHeight = CGRectGetHeight(effectiveRect);
                    break;
                    
                case 90:
                case 270:
                    pageWidth = CGRectGetHeight(effectiveRect);
                    pageHeight = CGRectGetWidth(effectiveRect);
                    break;
            }
            
            // Make scale sizes
            CGFloat scaleWidth = thumbWidth / pageWidth;
            CGFloat scaleHeight = thumbHeight / pageHeight;
            
            // Page to target thumb size scale
            CGFloat scale = 0.f;
            
            if (pageHeight > pageWidth) {

                // For Portrait
                scale = (thumbHeight > thumbWidth) ? scaleWidth : scaleHeight;

            } else {

                // For Landscape
                scale = (thumbHeight < thumbWidth) ? scaleHeight : scaleWidth;
            }
            
            // Make target sizes
            NSInteger targetWidth = pageWidth * scale;
            NSInteger targetHeight = pageHeight * scale;
            
            if (targetWidth % 2) {
                targetWidth--;
            }
            
            if (targetHeight % 2) {
                targetHeight--;
            }
            
            // Current screen scale
            targetWidth *= self.thumbRequest.scale;
            targetHeight *= self.thumbRequest.scale;
            
            // Create RGB color space
            CGColorSpaceRef rgbRef = CGColorSpaceCreateDeviceRGB();
            
            CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst;
            
            CGContextRef context = CGBitmapContextCreate(NULL, targetWidth, targetHeight, 8, 0, rgbRef, bitmapInfo);
            
            // Context must have a valid CGBitmap context
            // to draw into
            if (context != NULL) {
                
                // Target thumb rect
                CGRect thumbRect = CGRectMake(0.f, 0.f, targetWidth, targetHeight);
                
                // Setup white fill
                CGContextSetRGBFillColor(context, 1.f, 1.f, 1.f, 1.f);
                CGContextFillRect(context, thumbRect);
                
                CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(pdfPageReference, kCGPDFCropBox, thumbRect, 0, true));
                
                // Render current PDF page
                CGContextDrawPDFPage(context, pdfPageReference);
                
                // Create CGImage from custom CGBitmap context
                imageReference = CGBitmapContextCreateImage(context);
                
                // Release custom CGBitmap context reference
                CGContextRelease(context);
            }
            
            // Release RGB device
            CGColorSpaceRelease(rgbRef);
        }
        
        // Release document reference
        CGPDFDocumentRelease(documentReference);
    }
    
    // Create UIImage by reference for CGImage,
    // display it save it into PNG image
    if (imageReference != NULL) {
        
        UIImage* image = [UIImage imageWithCGImage: imageReference scale: self.thumbRequest.scale orientation: UIImageOrientationUp];
        
        // Update current cache
        [[ThumbCache sharedInstance] setObject: image forKey: self.thumbRequest.cacheKey];
        
        // Show the image on main thread
        if (self.isCancelled == NO) {
            
            // Target thumb view for image
            ThumbView* thumbView = self.thumbRequest.thumbView;
            
            // Target referene tag for image
            NSUInteger targetTag = self.thumbRequest.targetTag;
            
            // Show image on main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (thumbView.targetTag == targetTag) {
                    
                    //thumbView.backgroundColor = [UIColor whiteColor];
                    [thumbView showImage: image];
                }
            });
        }
        
        // Thumb cache path with PNG file
        CFURLRef thumbURL = (__bridge CFURLRef) [self thumbFileURL];
        
        CGImageDestinationRef thumbReference = CGImageDestinationCreateWithURL(thumbURL, (CFStringRef) @"public.png", 1, NULL);
        
        // Write the thumb image file out to the thumb cache directory
        if (thumbReference != NULL) {
            
            // Add the image
            CGImageDestinationAddImage(thumbReference, imageReference, NULL);
            
            // Finalize the image file
            CGImageDestinationFinalize(thumbReference);
            
            // Release thumb reference
            CFRelease(thumbReference);
        }
        
        // Release image reference
        CGImageRelease(imageReference);
    }
    
    // No image - remove object from cache
    else {
        
        [[ThumbCache sharedInstance] removeNullForKey: self.thumbRequest.cacheKey];
    }
    
    // Break retain loop
    self.thumbRequest.thumbView.operation = nil;
}


@end