//
//  MainPagebar.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 20.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import "MainPagebar.h"
#import "PagebarTrackControl.h"
#import "PagebarThumb.h"
#import "PagebarShadow.h"
#import "PDFDocument.h"
#import "ThumbRequest.h"
#import "ThumbCache.h"

@interface MainPagebar ()

@property (strong, nonatomic) PDFDocument* document;
@property (strong, nonatomic) PagebarTrackControl* trackControl;
@property (strong, nonatomic) PagebarThumb* pageThumbView;

@property (strong, nonatomic) NSMutableDictionary* thumbViews;

@end


@implementation MainPagebar {
    
    NSTimer* trackTimer;
    NSTimer* enableTimer;
    
    UILabel* pageNumberLabel;
    UIView*  pageNumberView;
    
    CGFloat pageNumberWidth;
    CGFloat pageNumberHeight;
    CGFloat pageNumberSpaceSmall;
    CGFloat pageNumberSpaceLarge;
    
    CGFloat thumbSmallGap;
    CGFloat thumbSmallWidth;
    CGFloat thumbSmallHeight;
    
    CGFloat thumbLargeWidth;
    CGFloat thumbLargeHeight;
    
    CGFloat shadowHeight;
}

+ (Class) layerClass {

    return [CAGradientLayer class];
}

#pragma mark - Initialization

- (instancetype) initWithFrame:(CGRect)frame {

    return [self initWithFrame: frame document: nil];
}

- (instancetype) initWithFrame:(CGRect)frame document:(PDFDocument *)document {
    
    self = [super initWithFrame: frame];
    
    if (self) {
        
        pageNumberWidth      = 96.f;
        pageNumberHeight     = 30.f;
        pageNumberSpaceSmall = 16.f;
        pageNumberSpaceLarge = 32.f;
        
        thumbSmallGap        = 2.f;
        thumbSmallWidth      = 30.f;//22
        thumbSmallHeight     = 38.f;//28
        
        thumbLargeWidth      = 42.f;//32
        thumbLargeHeight     = 52.f;//42
        
        self.autoresizesSubviews = YES;
        self.userInteractionEnabled = YES;
        
        self.contentMode = UIViewContentModeRedraw;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
        if ([self.layer isKindOfClass: [CAGradientLayer class]]) {
            
            self.backgroundColor = [UIColor clearColor];
            
            CAGradientLayer* layer = (CAGradientLayer *) self.layer;
            
            UIColor* liteColor = [UIColor colorWithWhite: 0.82f alpha: 0.8f];
            UIColor* darkColor = [UIColor colorWithWhite: 0.32f alpha: 0.8f];
            
            layer.colors = [NSArray arrayWithObjects: (id)liteColor.CGColor, (id)darkColor.CGColor, nil];
            
            CGRect shadowRect = self.bounds;
            shadowRect.size.height = shadowHeight;
            shadowRect.origin.y -= CGRectGetHeight(shadowRect);
            
            PagebarShadow* shadowView = [[PagebarShadow alloc] initWithFrame: shadowRect];
            
            [self addSubview: shadowView];

        } else {

            self.backgroundColor = [UIColor colorWithWhite: 0.94f alpha: 0.94f];
            
            CGRect lineRect = self.bounds;
            lineRect.size.height = 1.f;
            lineRect.origin.y -= CGRectGetHeight(lineRect);
            
            UIView* lineView = [[UIView alloc] initWithFrame: lineRect];
            lineView.autoresizesSubviews = NO;
            lineView.userInteractionEnabled = NO;
            lineView.contentMode = UIViewContentModeRedraw;
            lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            lineView.backgroundColor = [UIColor colorWithWhite: 0.64f alpha: 0.94f];
            
            [self addSubview: lineView];
        }
        
        CGFloat space = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
            ? pageNumberSpaceLarge
            : pageNumberSpaceSmall;
        
        CGFloat numY = 0.f - (pageNumberHeight + space);
        CGFloat numX = (CGRectGetWidth(self.bounds) - pageNumberWidth) * 0.5f;
        
        CGRect numberRect = CGRectMake(numX, numY, pageNumberWidth, pageNumberHeight);
        
        pageNumberView = [[UIView alloc] initWithFrame: numberRect];
        
        pageNumberView.autoresizesSubviews = NO;
        pageNumberView.userInteractionEnabled = NO;
        
        pageNumberView.autoresizingMask =   UIViewAutoresizingFlexibleLeftMargin |
                                            UIViewAutoresizingFlexibleRightMargin;
        
        pageNumberView.backgroundColor = [UIColor colorWithWhite: 0.f alpha: 0.4f];
        
        pageNumberView.layer.shadowOffset = CGSizeMake(0.f, 0.f);
        pageNumberView.layer.shadowColor = [UIColor colorWithWhite: 0.f alpha:0.6f].CGColor;
        pageNumberView.layer.shadowPath = [UIBezierPath bezierPathWithRect: pageNumberView.bounds].CGPath;
        pageNumberView.layer.shadowRadius = 2.f;
        pageNumberView.layer.shadowOpacity = 1.f;
        
        // Inset all text as a bits
        CGRect textRect = CGRectInset(pageNumberView.bounds, 4.f, 2.f);
        
        // Init page number label
        pageNumberLabel = [[UILabel alloc] initWithFrame: textRect];
        
        pageNumberLabel.autoresizesSubviews = NO;
        pageNumberLabel.autoresizingMask = UIViewAutoresizingNone;
        pageNumberLabel.textAlignment = NSTextAlignmentCenter;
        pageNumberLabel.backgroundColor = [UIColor clearColor];
        pageNumberLabel.textColor = [UIColor whiteColor];
        
        pageNumberLabel.font = [UIFont systemFontOfSize: 16.f];
        pageNumberLabel.shadowOffset = CGSizeMake(0.f, 1.f);
        pageNumberLabel.shadowColor = [UIColor blackColor];
        pageNumberLabel.adjustsFontSizeToFitWidth = YES;
        pageNumberLabel.minimumScaleFactor = 0.75f;
        
        // Add label to pageNumbers UIView
        [pageNumberView addSubview: pageNumberLabel];
        
        // Add page numbers to super UIView
        [self addSubview: pageNumberView];
        
        _trackControl = [[PagebarTrackControl alloc] initWithFrame: self.bounds];
        
        [_trackControl addTarget: self
                          action: @selector(trackViewTouchDown:)
                forControlEvents: UIControlEventTouchDown];
        
        [_trackControl addTarget: self
                          action: @selector(trackViewValueChanged:)
                forControlEvents: UIControlEventValueChanged];
        
        [_trackControl addTarget: self
                          action: @selector(trackViewTouchUp:)
                forControlEvents: UIControlEventTouchUpOutside];
        
        [_trackControl addTarget: self
                          action: @selector(trackViewTouchUp:)
                forControlEvents: UIControlEventTouchUpInside];
        
        [self addSubview: _trackControl];
        
        _document = document;
        
        [self updatePageNumberText: [document.pageNumber integerValue]];

        _thumbViews = [NSMutableDictionary new];
    }
    
    return self;
}

#pragma mark - Show/Hide Pagebar

- (void) showPagebar {
    
    if (self.hidden == YES) {
    
        [self updatePagebarViews];
        
        [UIView animateWithDuration: 0.25f
                              delay: 0.0
                            options: UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                         animations: ^{

                             self.hidden = NO;
                             self.alpha = 1.f;
                             
                             CGRect pagebarRect = self.frame;
                             
                             self.frame = CGRectMake(CGRectGetMinX(pagebarRect), CGRectGetMinY(pagebarRect) - 48, CGRectGetWidth(pagebarRect), CGRectGetHeight(pagebarRect));
                         }
                         completion: nil];
    }
}

- (void) hidePagebar {
    
    if (self.hidden == NO) {
        
        [UIView animateWithDuration: 0.25f
                              delay: 0.0
                            options: UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                         animations: ^{
                             
                             self.alpha = 0.f;
                             
                             CGRect pagebarRect = self.frame;
                             
                             self.frame = CGRectMake(CGRectGetMinX(pagebarRect), CGRectGetMinY(pagebarRect) + 48, CGRectGetWidth(pagebarRect), CGRectGetHeight(pagebarRect));
                         }
                         completion: ^(BOOL finished) {

                             self.hidden = YES;
                         }];
    }
}

#pragma mark - Format pagebar

- (void) layoutSubviews {
    
    // Make rect of MainPagebar bounds with initted insets
    CGRect controlRect = CGRectInset(self.bounds, 4.f, 0.f);
    
    // Get width for thumb
    CGFloat currentThumbWidth = thumbSmallWidth + thumbSmallGap;
    
    // Get thumbs
    NSInteger thumbs = CGRectGetWidth(controlRect) / currentThumbWidth;
    
    // Get count of pages in document
    NSInteger pages = [self.document.pageCount integerValue];
    
    // If exist more than total pages
    if (thumbs > pages) {
        thumbs = pages;
    }
    
    CGFloat controlWidth = thumbs * currentThumbWidth - thumbSmallGap;
    
    // Update control width by calculated value - controlWidth
    controlRect.size.width = controlWidth;
    
    CGFloat deltaWidth = CGRectGetWidth(self.bounds) - controlWidth;
    
    NSInteger x = deltaWidth * 0.5f;
    controlRect.origin.x = x;
    
    self.trackControl.frame = controlRect;
    
    // Create page thumb if needed
    if (self.pageThumbView == nil) {
        
        CGFloat deltaHeight = CGRectGetHeight(controlRect) - thumbLargeHeight;
        
        NSInteger thumbX = 0;
        NSInteger thumbY = deltaHeight * 0.5f;
        
        // Make rect for thumb
        CGRect thumbRect = CGRectMake(thumbX, thumbY, thumbLargeWidth, thumbLargeHeight);
        
        // Create new thumb view
        self.pageThumbView = [[PagebarThumb alloc] initWithFrame: thumbRect];
        
        // Z position - it sits on top of the small thumbs
        self.pageThumbView.layer.zPosition = 1.f;
        
        [self.trackControl addSubview: self.pageThumbView];
    }
    
    // Update page thumb view by current page number
    [self updatePageThumb: [self.document.pageNumber integerValue]];
    
    NSInteger strideThumbs = thumbs - 1;
    
    if (strideThumbs < 1) {
        strideThumbs = 1;
    }
    
    // Current page stride
    CGFloat stride = (CGFloat)pages / (CGFloat)strideThumbs;
    
    CGFloat deltaHeight = CGRectGetHeight(controlRect) - thumbSmallHeight;
    
    NSInteger thumbX = 0;
    NSInteger thumbY = deltaHeight * 0.5f;
    
    CGRect thumbRect = CGRectMake(thumbX, thumbY, thumbSmallWidth, thumbSmallHeight);
    
    NSMutableDictionary* thumbsToHide = [self.thumbViews mutableCopy];
    
    // Iterate through needed thumbs
    for (NSInteger thumbIndex = 0; thumbIndex < thumbs; thumbIndex++) {
        
        NSInteger page = stride * thumbIndex + 1;
        
        if (page > pages) {
            page = pages;
        }
        
        // Page number key for thumb view
        NSNumber* key = [NSNumber numberWithInteger: page];
        
        // Thumb view
        PagebarThumb* smallThumb = [self.thumbViews objectForKey: key];
        
        // If small thumb is nil, create new small thumb
        if (smallThumb == nil) {
            
            CGSize thumbSize = CGSizeMake(thumbSmallWidth, thumbSmallHeight);
            
            NSURL* fileURL = self.document.fileURL;
            NSString* guid = self.document.guid;
            NSString* password = self.document.filePassword;
            
            // Create a small thumb view
            smallThumb = [[PagebarThumb alloc] initWithFrame: thumbRect smallThumb: YES];
            
            // Request the thumb
            ThumbRequest* thumbRequest = [ThumbRequest newForView: smallThumb
                                                          fileURL: fileURL
                                                         password: password
                                                             guid: guid
                                                             page: page
                                                             size: thumbSize];
            
            // Get thumb image from cache
            UIImage* image = [[ThumbCache sharedInstance] thumbRequest: thumbRequest priority: NO];
            
            // Request the image
            if ([image isKindOfClass: [UIImage class]]) {
                [smallThumb showImage: image];
            }
            
            [self.trackControl addSubview: smallThumb];
            [self.thumbViews setObject: smallThumb forKey: key];
        }
        
        // Resue existing small thumb for current page number
        else {
            
            smallThumb.hidden = NO;
            [thumbsToHide removeObjectForKey: key];
            
            if (CGRectEqualToRect(smallThumb.frame, thumbRect) == false) {
                
                // Update exist thumb frame
                smallThumb.frame = thumbRect;
            }
        }
        
        // Go to next thumb (change x position)
        thumbRect.origin.x += currentThumbWidth;
    }
    
    [thumbsToHide enumerateKeysAndObjectsUsingBlock:
     ^(id key, id thumbObj, BOOL* stop) {
         
         PagebarThumb* pagebarThumb = thumbObj;
         pagebarThumb.hidden = YES;
     }];
}


- (void) updatePagebar {
    
    if (self.hidden == NO) {
        [self updatePagebarViews];
    }
}

- (void) updatePagebarViews {

    NSInteger page = [self.document.pageNumber integerValue];
    [self updatePageNumberText: page];
    [self updatePageThumb: page];
}


- (void) updatePageNumberText:(NSInteger)page {
    
    if (page != pageNumberLabel.tag) {
        
        NSInteger pages = [self.document.pageCount integerValue];
        NSString* format = NSLocalizedString(@"%i of %i", @"format");
        NSString* pageNumberText = [[NSString alloc] initWithFormat: format, (int) page, (int) pages];
        
        pageNumberLabel.text = pageNumberText;
        pageNumberLabel.tag = page;
    }
}

- (void) updatePageThumb:(NSInteger)page {
    
    NSInteger pages = [self.document.pageCount integerValue];
    
    // Only update frame if count of pages is greater than one
    if (pages > 1) {
        
        CGFloat controlWidth = CGRectGetWidth(self.trackControl.bounds);
        CGFloat useableWidth = controlWidth - thumbLargeWidth;
        
        // Setup page stride
        CGFloat stride = useableWidth / (pages - 1);
        
        NSInteger x = stride * (page - 1);
        CGFloat pageThumbX = x;
        
        // Make thumb frame
        CGRect pageThumbRect = self.pageThumbView.frame;
        
        if (pageThumbX != CGRectGetMinX(pageThumbRect)) {
            
            // Setup new x position to thumb frame
            pageThumbRect.origin.x = pageThumbX;
            
            // Update exist frame
            self.pageThumbView.frame = pageThumbRect;
        }
    }
    
    // Useable if current page number is changed
    if (page != self.pageThumbView.tag) {
        
        self.pageThumbView.tag = page;
        
        // Reuse current page thumb
        [self.pageThumbView reuse];
        
        CGSize size = CGSizeMake(thumbLargeWidth, thumbLargeHeight);
        
        NSURL* fileUrl = self.document.fileURL;
        NSString* password = self.document.filePassword;
        NSString* guid = self.document.guid;
        
        ThumbRequest* thumbRequest = [ThumbRequest newForView: self.pageThumbView
                                                      fileURL: fileUrl
                                                     password: password
                                                         guid: guid
                                                         page: page
                                                         size: size];
        
        // Request the thumb
        UIImage* image = [[ThumbCache sharedInstance] thumbRequest: thumbRequest priority: YES];
        
        UIImage* thumbImage = [image isKindOfClass: [UIImage class]] ? image : nil;
        //self.pageThumbView.backgroundColor = [UIColor whiteColor];
        [self.pageThumbView showImage: thumbImage];
    }
}

- (void) removeFromSuperview {
    
    [trackTimer invalidate];
    [enableTimer invalidate];
    
    [super removeFromSuperview];
}

#pragma mark - TrackControl methods

- (void) trackTimerFired:(NSTimer *)timer {
    
    // Cleanup timer
    [trackTimer invalidate];
    trackTimer = nil;
    
    if (self.trackControl.tag != [self.document.pageNumber integerValue]) {
        
        // Go to document page
        [self.delegate pagebar: self gotoPage: self.trackControl.tag];
    }
}

- (void) enableTimerFired:(NSTimer *)timer {
    
    // Cleanup timer
    [enableTimer invalidate];
    enableTimer = nil;
    
    // Enable track control interaction
    self.trackControl.userInteractionEnabled = YES;
}

- (void) restartTrackTimer {
    
    if (trackTimer != nil) {

        // Cleanup timer
        [trackTimer invalidate];
        trackTimer = nil;
    }
    
    trackTimer = [NSTimer scheduledTimerWithTimeInterval: 0.25f
                                                  target: self
                                                selector: @selector(trackTimerFired:)
                                                userInfo: nil
                                                 repeats: NO];
}

- (void) startEnableTimer {

    if (enableTimer != nil) {
        
        // Cleanup timer
        [enableTimer invalidate];
        enableTimer = nil;
    }
    
    enableTimer = [NSTimer scheduledTimerWithTimeInterval: 0.25f
                                                   target: self
                                                 selector: @selector(enableTimerFired:)
                                                 userInfo: nil
                                                  repeats: NO];
}

- (NSInteger) trackViewPageNumber:(PagebarTrackControl *)trackView {
    
    CGFloat controlWidth = CGRectGetWidth(trackView.bounds);
    
    CGFloat stride = controlWidth / [self.document.pageCount integerValue];
    
    // Current page
    NSInteger page = (trackView.value / stride) + 1;
    
    return page;
}


- (void) trackViewTouchDown:(PagebarTrackControl *)trackView {
    
    NSInteger page = [self trackViewPageNumber: trackView];
    
    if (page != [self.document.pageNumber integerValue]) {

        // Update page number text
        [self updatePageNumberText: page];
        
        // Update page thumb view
        [self updatePageThumb: page];
        
        // Start track timer
        [self restartTrackTimer];
    }
    
    trackView.tag = page;
}

- (void) trackViewValueChanged:(PagebarTrackControl *)trackView {
    
    NSInteger page = [self trackViewPageNumber: trackView];
    
    if (page != trackView.tag) {
        
        // Update page number text
        [self updatePageNumberText: page];
        
        // Update page thumb view
        [self updatePageThumb: page];
        
        trackView.tag = page;
        
        // Start track timer
        [self restartTrackTimer];
    }
}

- (void) trackViewTouchUp:(PagebarTrackControl *)trackView {
    
    // Cleanup timer
    [trackTimer invalidate];
    trackTimer = nil;
    
    if (trackView.tag != [self.document.pageNumber integerValue]) {
        
        // Disable track control interaction
        trackView.userInteractionEnabled = NO;
        
        // Go to document page
        [self.delegate pagebar: self gotoPage: trackView.tag];
        
        // Start track timer
        [self startEnableTimer];
    }
    
    // Reset page tracking
    trackView.tag = 0;
}

@end