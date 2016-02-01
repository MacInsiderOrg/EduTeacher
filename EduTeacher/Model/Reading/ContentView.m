//
//  DrawingView.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 20.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import "ContentView.h"
#import "ContentThumb.h"
#import "ContentPage.h"
#import "ThumbRequest.h"
#import "ThumbCache.h"

@interface ContentView () <UIScrollViewDelegate>

@property (strong, nonatomic) UIView* containerView;
@property (strong, nonatomic) ContentPage* contentPage;
@property (strong, nonatomic) ContentThumb* thumbView;

@end


@implementation ContentView {
    
    UIUserInterfaceIdiom userInterfaceIdiom;
    
    CGFloat realMaximumZoom;
    CGFloat tempMaximumZoom;
    
    BOOL zoomBounced;
    
    CGFloat zoomFactor;
    CGFloat zoomMaximum;
    
    CGFloat pageThumbLarge;
    CGFloat pageThumbSmall;
}

static void* PDFContentViewContext = &PDFContentViewContext;
static CGFloat g_BugFixWidthInset = 0.f;

static inline CGFloat zoomScaleThatFits(CGSize targetSize, CGSize sourceSize) {
    
    CGFloat widthScale = targetSize.width / (sourceSize.width + g_BugFixWidthInset);
    CGFloat heightScale = targetSize.height / sourceSize.height;
    
    return (widthScale < heightScale) ? widthScale : heightScale;
}

#pragma mark - Initialization

- (instancetype) initWithFrame:(CGRect)frame fileURL:(NSURL *)fileURL page:(NSInteger)page password:(NSString *)password {
    
    self = [super initWithFrame: frame];
    
    if (self) {
        
        zoomFactor = 2.f;
        zoomMaximum = 16.f;
        
        pageThumbLarge = 240.f;
        pageThumbSmall = 144.f;
        
        self.scrollsToTop = NO;
        self.delaysContentTouches = NO;
        
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        
        self.contentMode = UIViewContentModeRedraw;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.backgroundColor = [UIColor clearColor];
        
        self.autoresizesSubviews = NO;
        self.clipsToBounds = NO;
        
        self.delegate = self;
        
        // Setup user interface idiom
        userInterfaceIdiom = [UIDevice currentDevice].userInterfaceIdiom;
        
        // Initialize current content page
        self.contentPage = [[ContentPage alloc] initWithUrl: fileURL page: page password: password];
        
        // Content page must have a valid and initialize all of the content,
        // which she's contain
        if (self.contentPage != nil) {
            
            self.containerView = [[UIView alloc] initWithFrame: self.contentPage.bounds];
            
            self.containerView.autoresizesSubviews = NO;
            self.containerView.userInteractionEnabled = NO;
            self.containerView.contentMode = UIViewContentModeRedraw;
            self.containerView.autoresizingMask = UIViewAutoresizingNone;
            self.containerView.backgroundColor = [UIColor clearColor];
            
            self.containerView.layer.shadowOffset = CGSizeMake(0.f, 0.f);
            self.containerView.layer.shadowRadius = 4.f;
            self.containerView.layer.shadowOpacity = 1.f;
            self.containerView.layer.shadowPath = [UIBezierPath bezierPathWithRect: self.containerView.bounds].CGPath;
            
            // Setup content size
            self.contentSize = self.contentPage.bounds.size;
            [self centerScrollViewContent];
            
            // Initialize page thumb view
            self.thumbView = [[ContentThumb alloc] initWithFrame: self.contentPage.bounds];
            
            // Add the page thumb to container view
            [self.containerView addSubview: self.thumbView];
            
            // Add the content page to container view
            [self.containerView addSubview: self.contentPage];
            
            // Add the container view to scroll view
            [self addSubview: self.containerView];
            
            // Update min and max zoom scales
            [self updateMinimumAndMaximumZoom];
            
            // Change default zoom scale (using for fit page content)
            self.zoomScale = self.minimumZoomScale;
            
            [self addObserver: self
                   forKeyPath: @"frame"
                      options: 0
                      context: PDFContentViewContext];
        }
        
        self.tag = page;
    }
    
    return self;
}

#pragma mark - Instance methods

- (void) dealloc {
    
    [self removeObserver: self forKeyPath: @"frame" context: PDFContentViewContext];
}

- (void) updateMinimumAndMaximumZoom {

    CGFloat zoomScale = zoomScaleThatFits(self.bounds.size, self.contentPage.bounds.size);
    
    self.minimumZoomScale = zoomScale;
    self.maximumZoomScale = zoomScale * zoomMaximum;
    
    realMaximumZoom = self.maximumZoomScale;
    tempMaximumZoom = realMaximumZoom * zoomFactor;
}

- (void) centerScrollViewContent {
    
    // Create content width and height insets
    CGFloat widthInset = 0.f;
    CGFloat heightInset = 0.f;
    
    // Initialize bounds and content sizes
    CGSize boundsSize = self.bounds.size;
    CGSize contentSize = self.contentSize;

    if (contentSize.width < boundsSize.width) {
        
        widthInset = (boundsSize.width - contentSize.width) * 0.5f;
    }
    
    if (contentSize.height < boundsSize.height) {
        
        heightInset = (boundsSize.height - contentSize.height) * 0.5f;
    }
    
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(heightInset, widthInset, heightInset, widthInset);
    
    if (UIEdgeInsetsEqualToEdgeInsets(self.contentInset, edgeInsets) == false) {
        
        // Setup new content inset
        self.contentInset = edgeInsets;
    }
}

- (void) setContentDrawingImageView:(UIImage *)drawingImage {
    
    [self.contentPage showDrawingView: drawingImage];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    // Testing our context
    if (context == PDFContentViewContext) {
        
        if (object == self && [keyPath isEqualToString: @"frame"]) {
            
            // Center current content
            [self centerScrollViewContent];
            
            CGFloat oldMinimumZoomScale = self.minimumZoomScale;
            
            // Update zoom scale limits
            [self updateMinimumAndMaximumZoom];
            
            // Checking old minimum scale
            if (self.zoomScale == oldMinimumZoomScale) {
                
                self.zoomScale = self.minimumZoomScale;
            }
            
            // Check against minimum zoom scale
            else {
                
                if (self.zoomScale < self.minimumZoomScale) {
                    
                    self.zoomScale = self.minimumZoomScale;
                }
                
                // Check against maximum zoom scale
                else {
                    
                    if (self.zoomScale > self.maximumZoomScale) {
                        
                        self.zoomScale = self.maximumZoomScale;
                    }
                }
            }
        }
    }
}

- (void) showPageThumb:(NSURL *)fileURL page:(NSInteger)page password:(NSString *)password guid:(NSString *)guid {
    
    CGSize size = (userInterfaceIdiom == UIUserInterfaceIdiomPad)
        ? CGSizeMake(pageThumbLarge, pageThumbLarge)
        : CGSizeMake(pageThumbSmall, pageThumbSmall);
    
    ThumbRequest* thumbRequest = [ThumbRequest newForView: self.thumbView
                                                  fileURL: fileURL
                                                 password: password
                                                     guid: guid
                                                     page: page
                                                     size: size];
    
    // Request the current page thumb
    UIImage* image = [[ThumbCache sharedInstance] thumbRequest: thumbRequest priority: YES];
    
    if ([image isKindOfClass: [UIImage class]]) {
        
        // Display image from cache
        [self.thumbView showImage: image];
    }
}

#pragma mark - Zooming Methods
- (void) zoomIncrement:(UITapGestureRecognizer *)recognizer {
    
    // Get current page zoom
    CGFloat zoomScale = self.zoomScale;
    
    // Get point, where user tapped
    CGPoint point = [recognizer locationInView: self.contentPage];
    
    // If user zoom in
    if (zoomScale < self.maximumZoomScale) {
        
        zoomScale *= zoomFactor;
        
        if (zoomScale > self.maximumZoomScale) {

            zoomScale = self.maximumZoomScale;
        }
        
        CGRect zoomRect = [self zoomRectForScale: zoomScale withCenter: point];
        
        [self zoomToRect: zoomRect animated: YES];
    }
    
    // Handle if user fully zoomed in
    else {
        
        // Check if not zoom bounced
        if (zoomBounced == NO) {
            
            self.maximumZoomScale = tempMaximumZoom;
            [self setZoomScale: tempMaximumZoom animated: YES];
        }
        
        // Setup maximum zoom
        else {
            
            zoomScale = self.minimumZoomScale;
            [self setZoomScale: zoomScale animated: YES];
        }
    }
}

- (void) zoomDecrement:(UITapGestureRecognizer *)recognizer {

    // Get current page zoom
    CGFloat zoomScale = self.zoomScale;
    
    // Get point, where user tapped
    CGPoint point = [recognizer locationInView: self.contentPage];
    
    // If user zoom out
    if (zoomScale > self.minimumZoomScale) {
        
        zoomScale /= zoomFactor;
        
        if (zoomScale < self.minimumZoomScale) {
            zoomScale = self.minimumZoomScale;
        }
        
        CGRect zoomRect = [self zoomRectForScale: zoomScale withCenter: point];
        
        [self zoomToRect: zoomRect animated: YES];
    }
    
    // Handle if user fully zoomed out
    else {
        
        zoomScale = self.maximumZoomScale;
        
        CGRect zoomRect = [self zoomRectForScale: zoomScale withCenter: point];
        [self zoomToRect: zoomRect animated: YES];
    }
}

- (void) zoomResetAnimated:(BOOL)animated {
    
    // Reset current zoom
    if (self.zoomScale > self.minimumZoomScale) {
        
        if (animated) {
            
            [self setZoomScale: self.minimumZoomScale animated: YES];

        } else {
            
            self.zoomScale = self.minimumZoomScale;
        }
        
        zoomBounced = NO;
    }
}


- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {

    return self.containerView;
}

- (CGRect) zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center {
    
    // Create zoom rect, which must be centered zoom scale
    CGRect zoomRect;
    
    zoomRect.size.width = CGRectGetWidth(self.bounds) / scale;
    zoomRect.size.height = CGRectGetHeight(self.bounds) / scale;
    
    zoomRect.origin.x = center.x - CGRectGetWidth(zoomRect) * 0.5f;
    zoomRect.origin.y = center.y - CGRectGetHeight(zoomRect) * 0.5f;
    
    return zoomRect;
}

#pragma mark - ScrollView Methods

- (void) scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    
    // Bounce back to real max zoom scale
    if (self.zoomScale > realMaximumZoom) {
        
        [self setZoomScale: realMaximumZoom animated: YES];
        self.maximumZoomScale = realMaximumZoom;
        zoomBounced = YES;
    }
    
    // Normal scroll view did end zooming
    else {

        if (self.zoomScale < realMaximumZoom) {

            zoomBounced = NO;
        }
    }
}

- (void) scrollViewDidZoom:(UIScrollView *)scrollView {
    
    [self centerScrollViewContent];
}

#pragma mark - Touch methods

- (id) processSingleTap:(UITapGestureRecognizer *)recognizer {
    
    return [self.contentPage processSingleTap: recognizer];
}

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [super touchesBegan: touches withEvent: event];
    
    [self.message contentView: self touchesBegan: touches];
}

- (void) touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [super touchesCancelled: touches withEvent: event];
}

- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [super touchesEnded: touches withEvent: event];
}

- (void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [super touchesMoved: touches withEvent: event];
}

@end