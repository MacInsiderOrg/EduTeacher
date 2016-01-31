//
//  ThumbFetch.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 20.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import "ThumbFetch.h"
#import "ThumbRequest.h"
#import "ThumbView.h"
#import "ThumbCache.h"
#import "ThumbRender.h"
#import <ImageIO/ImageIO.h>
#import "Functions.h"

@interface ThumbFetch ()

@property (strong, nonatomic) ThumbRequest* thumbRequest;

@end


@implementation ThumbFetch

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
    
    // Break retain loop
    self.thumbRequest.thumbView.operation = nil;
    
    // Release target thumb on cancel
    self.thumbRequest.thumbView = nil;
    
    [[ThumbCache sharedInstance] removeNullForKey: self.thumbRequest.cacheKey];
}

- (NSURL *) thumbFileURL {
    
    // Get current cache path
    NSString* cachePath = [ThumbCache thumbCachePathForGUID: self.thumbRequest.guid];
    
    // Thumb file name
    NSString* fileName = [[NSString alloc] initWithFormat: @"%@.png", self.thumbRequest.thumbName];
    
    // File URL
    return [NSURL fileURLWithPath: [cachePath stringByAppendingPathComponent: fileName]];
}

- (void) main {
    
    CGImageRef imageReference = nil;
    NSURL* thumbURL = [self thumbFileURL];
    
    // Init image source references
    CGImageSourceRef imageSourceReference = CGImageSourceCreateWithURL((__bridge CFURLRef) thumbURL, NULL);
    
    // Load an existing thumb image
    if (imageSourceReference != nil) {
        
        // Load image reference
        imageReference = CGImageSourceCreateImageAtIndex(imageSourceReference, 0, NULL);
        
        // Release CGImageSource
        CFRelease(imageSourceReference);
    }
    
    // If existing thumb image not found
    // then create it with render operation
    else {
        
        // Init ThumbRender operation
        ThumbRender* thumbRender = [[ThumbRender alloc] initWithRequest: self.thumbRequest];
        
        // Setup Priorities
        [thumbRender setQueuePriority: self.queuePriority];
        //[thumbRender setThreadPriority: (self.threadPriority - 0.1)];
        [thumbRender setQualityOfService: NSQualityOfServiceUserInteractive];
        
        // We're not cancelled,
        // add the render operation to the work queue
        if (self.isCancelled == NO) {
            
            // Update current thumb view operation to new operation
            self.thumbRequest.thumbView.operation = thumbRender;
            
            // Queue current operation
            [[ThumbQueue sharedInstance] addWorkOperation: thumbRender];
            
            return;
        }
    }
    
    // Create a UIImage by CGImage and display it
    if (imageReference != NULL) {
        
        UIImage* image = [UIImage imageWithCGImage: imageReference
                                             scale: self.thumbRequest.scale
                                       orientation: UIImageOrientationUp];
        
        // Release current image reference
        CGImageRelease(imageReference);
        
        // Make graphics context
        UIGraphicsBeginImageContextWithOptions(image.size, YES, self.thumbRequest.scale);
        
        // Draw an image in background thread
        [image drawAtPoint: CGPointZero];
        
        // Get decoded image
        UIImage* decoded = UIGraphicsGetImageFromCurrentImageContext();
        
        // Cleanup after the bitmap graphics drawing context
        UIGraphicsEndImageContext();
        
        // Cache decoded image
        [[ThumbCache sharedInstance] setObject: decoded forKey: self.thumbRequest.cacheKey];
        
        // Show the image on the main thread
        if (self.isCancelled == NO) {
            
            // Target thumb view for image show
            ThumbView* thumbView = self.thumbRequest.thumbView;
            
            // Target reference tag for image show
            NSUInteger targetTag = self.thumbRequest.targetTag;
            
            // Show image on main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (thumbView.targetTag == targetTag) {
                    [thumbView showImage: decoded];
                }
            });
        }
    }
    
    // Break current operation
    self.thumbRequest.thumbView.operation = nil;
}

@end
