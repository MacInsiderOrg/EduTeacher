//
//  PDFDocumentViewController.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 19.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import "PDFDocumentViewController.h"
#import "PDFDocument.h"
#import "DrawingToolbar.h"
#import "DrawingView.h"
#import "ContentView.h"
#import "ContentPage.h"
#import "ThumbCache.h"
#import "ThumbQueue.h"
#import "MainPagebar.h"
#import "ToolPropertiesController.h"
#import "UIImage+Overlay.h"

@interface PDFDocumentViewController () <
    UIScrollViewDelegate,
    UIGestureRecognizerDelegate,
    DrawingToolbarDelegate,             // left toolbar (using for drawing)
    MainPagebarDelegate,                // bottom pagebar (using for changing page)
    ContentViewDelegate,                // content (using for displaying pdf page as image)
    DrawingViewDelegate,                // drawing lines, rectangles, ellipses, texts, etc.
    ToolPropertiesDelegate              // change color, line width and opacity
>

@property (strong, nonatomic) PDFDocument* document;
@property (strong, nonatomic) UIScrollView* scrollView;
@property (strong, nonatomic) DrawingToolbar* drawingToolbar;
@property (strong, nonatomic) MainPagebar* mainPagebar;

@property (strong, nonatomic) NSMutableDictionary* contentViews;
@property (strong, nonatomic) NSCache* imagesCache;

@end


@implementation PDFDocumentViewController {
    
    NSInteger currentPage;
    NSInteger minPage;
    NSInteger maxPage;
    
    UIPrintInteractionController* printInteraction;
    NSDate* lastHideTime;
    
    CGSize lastAppearSize;
    CGFloat drawbarWidth;
    CGFloat drawbarHeight;
    CGFloat tapAreaSize;
    
    CGFloat scrollViewOutset;
    BOOL ignoreDidScroll;
}

#pragma mark - UIViewController methods

- (instancetype) initWithPDFDocument:(PDFDocument *)document {
    self = [super initWithNibName: nil bundle: nil];
    
    if (self) {
        
        // Get default notification center
        NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
        
        [notificationCenter addObserver: self
                               selector: @selector(applicationWillResign:)
                                   name: UIApplicationWillTerminateNotification
                                 object: nil];
        
        [notificationCenter addObserver: self
                               selector: @selector(applicationWillResign:)
                                   name: UIApplicationWillResignActiveNotification
                                 object: nil];
        
        scrollViewOutset = 8.f;
        
        // retain the supplied document object
        [document updateDocumentProperties];
        _document = document;
        
        // Touch thumb cache directory
        [ThumbCache touchThumbCacheWithGUID: document.guid];
        
        // Initialize image cache
        //self.imagesCache = [[NSCache alloc] init];
    }
    
    return self;
}

- (void) dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    drawbarWidth = 52.f;
    drawbarHeight = 470.f;
    
    tapAreaSize = 48.f;
    
    self.view.backgroundColor = [UIColor colorWithRed: 0.56f green: 0.56f blue: 0.56f alpha: 1.f];
    
    // Make Scroll View
    self.scrollView = [self makeScrollView];
    self.scrollView.delegate = self;
    [self.view addSubview: self.scrollView];
    
    // Make Drawing Bar
    self.drawingToolbar = [self makeDrawingToolbar];
    self.drawingToolbar.delegate = self;
    [self.view addSubview: self.drawingToolbar];
    
    // Make Page Bar
    self.mainPagebar = [self makeMainPageToolbar];
    self.mainPagebar.delegate = self;
    [self.view addSubview: self.mainPagebar];
    
    // Setup tap gesture recognizers
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                                action: @selector(handleSingleTap:)];
    singleTap.numberOfTouchesRequired = 1;
    singleTap.numberOfTapsRequired = 1;
    singleTap.delegate = self;
    
    UITapGestureRecognizer* doubleTapOne = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                                   action: @selector(handleDoubleTap:)];
    doubleTapOne.numberOfTouchesRequired = 1;
    doubleTapOne.numberOfTapsRequired = 2;
    doubleTapOne.delegate = self;
    
    UITapGestureRecognizer* doubleTapTwo = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                                   action: @selector(handleDoubleTap:)];
    doubleTapTwo.numberOfTouchesRequired = 2;
    doubleTapTwo.numberOfTapsRequired = 2;
    doubleTapTwo.delegate = self;
    
    [singleTap requireGestureRecognizerToFail: doubleTapOne];
    
    [self.view addGestureRecognizer: singleTap];
    [self.view addGestureRecognizer: doubleTapOne];
    [self.view addGestureRecognizer: doubleTapTwo];

    // Setup default values for drawing tool properties
    self.lineColor = [UIColor colorWithRed: .173f green: .243f blue: .314f alpha: 1.f];
    self.lineWidth = [NSNumber numberWithFloat: 8.f];
    self.lineAlpha = [NSNumber numberWithFloat: 0.8f];
    
    [self updateDrawingView];
    
    self.contentViews = [NSMutableDictionary new];
    lastHideTime = [NSDate date];
    
    minPage = 1;
    maxPage = [self.document.pageCount integerValue];
    
    // Setup save document button
    [self.navigationItem setRightBarButtonItem: [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemSave
                                                                                              target: self
                                                                                              action: @selector(saveDocument)]];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    if (CGSizeEqualToSize(lastAppearSize, CGSizeZero) == false) {
        if (CGSizeEqualToSize(lastAppearSize, self.view.bounds.size) == false) {
            
            // Update Content View
            [self updateContentViews: self.scrollView];
        }
        
        lastAppearSize = CGSizeZero;
    }
    
    self.title = self.document.fileName;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    if (CGSizeEqualToSize(self.scrollView.contentSize, CGSizeZero) == true) {
        
        [self performSelector: @selector(showPDFDocument)
                   withObject: nil
                   afterDelay: 0.f];
    }
}

- (void) viewWillDisappear:(BOOL)animated {

    lastAppearSize = self.view.bounds.size;
    [self presentCheckSaveDocumentAlert];
    [super viewWillDisappear: animated];
}

- (void) presentCheckSaveDocumentAlert {
    
    if ([self.navigationController.viewControllers indexOfObject: self] == NSNotFound) {
        
        if (self.imagesCache != nil) {
            
            // Check if user want to save document
            UIAlertController* alert = [UIAlertController alertControllerWithTitle: @"Question"
                                                                           message: @"Do you want to save changes into your document?"
                                                                    preferredStyle: UIAlertControllerStyleAlert];
            
            UIAlertAction* okButton = [UIAlertAction actionWithTitle: @"Ok"
                                                               style: UIAlertActionStyleDefault
                                                             handler: ^(UIAlertAction* action) {
                                                                 [self saveDocument];
                                                                 [alert dismissViewControllerAnimated: YES completion: nil];
                                                                 [self.navigationController popViewControllerAnimated:NO];
                                                             }];
            
            UIAlertAction* cancelButton = [UIAlertAction actionWithTitle: @"Cancel"
                                                                   style: UIAlertActionStyleCancel
                                                                 handler: ^(UIAlertAction* action) {
                                                                     [alert dismissViewControllerAnimated: YES completion: nil];
                                                                     [self.navigationController popViewControllerAnimated:NO];
                                                                 }];
            
            [alert addAction: okButton];
            [alert addAction: cancelButton];
            
            [self presentViewController: alert animated: YES completion: nil];
        }
    }
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
}

- (BOOL) prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    if (printInteraction != nil) {
        [printInteraction dismissAnimated: NO];
    }

    ignoreDidScroll = YES;
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    if (CGSizeEqualToSize(self.scrollView.contentSize, CGSizeZero) == false) {
        
        [self updateContentViews: self.scrollView];
        lastAppearSize = CGSizeZero;
        
        [self.drawingToolbar setFrame: CGRectMake(self.drawingToolbar.frame.origin.x, self.drawingToolbar.frame.origin.y, drawbarWidth, drawbarHeight)];
    }
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    ignoreDidScroll = NO;
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma Instance Methods

- (UIScrollView *) makeScrollView {
    
    // Make rect by super view bounds
    CGRect viewRect = self.view.bounds;
    CGRect scrollViewRect = CGRectInset(viewRect, - scrollViewOutset, 0.f);
    
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame: scrollViewRect];
    scrollView.autoresizesSubviews = NO;
    
    // Redraw scrollView if bounds changing
    scrollView.contentMode = UIViewContentModeRedraw;
    
    // Disable scroll indicators
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    
    scrollView.scrollsToTop = NO;
    scrollView.delaysContentTouches = NO;
    scrollView.pagingEnabled = YES;
    
    // Setup autoresizing by width and height
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    scrollView.backgroundColor = [UIColor clearColor];
    
    return scrollView;
}

- (DrawingToolbar *) makeDrawingToolbar {
    
    // Make rect by super view bounds
    CGRect viewRect = self.view.bounds;
    
    // Get navigation bar height
    CGFloat navbarHeight = CGRectGetHeight(self.navigationController.navigationBar.bounds); //44.f;
    
    CGRect drawingBarRect = CGRectMake(22, CGRectGetMinX(viewRect) + navbarHeight + 40, drawbarWidth, drawbarHeight);
    
    // Init drawing toolbar by initial rect
    DrawingToolbar* drawingToolbar = [[DrawingToolbar alloc] initWithFrame: drawingBarRect];
    //drawingToolbar.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent: 0.4f];
    drawingToolbar.backgroundColor = [UIColor colorWithRed: 0.89f green: 0.89f blue: 0.89f alpha: 0.6f];
    
    
    return drawingToolbar;
}

- (MainPagebar *) makeMainPageToolbar {
    
    // Make rect by super view bounds
    CGRect viewRect = self.view.bounds;
    CGRect pagebarRect = viewRect;
    
    // Setup pagebar height
    pagebarRect.size.height = 58.f; // 48
    pagebarRect.origin.y = CGRectGetHeight(viewRect) - CGRectGetHeight(pagebarRect);
    
    MainPagebar* mainPagebar = [[MainPagebar alloc] initWithFrame: pagebarRect document: self.document];
    
    return mainPagebar;
}

#pragma mark - PDFDocumentViewController methods

- (void) updateContentSize:(UIScrollView *)scrollView {
    
    CGFloat contentWidth = CGRectGetWidth(scrollView.bounds) * maxPage;
    CGFloat contentHeight = CGRectGetHeight(scrollView.bounds);
    
    scrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
}

- (void) updateContentViews:(UIScrollView *)scrollView {
    
    // Update current content size
    [self updateContentSize: self.scrollView];
    
    [self.contentViews enumerateKeysAndObjectsUsingBlock:
        ^(NSNumber* key, ContentView* contentView, BOOL* stop) {
         
            // Current page number
            NSInteger page = [key integerValue];
         
            CGRect viewRect = CGRectZero;
            viewRect.size = scrollView.bounds.size;
            viewRect.origin.x = CGRectGetWidth(viewRect) * (page - 1);
         
            contentView.frame = CGRectInset(viewRect, scrollViewOutset, 0.f);
        }
     ];
    
    // Update scroll view outset to current page
    NSInteger page = currentPage;
    
    CGPoint contentOffset = CGPointMake(CGRectGetWidth(scrollView.bounds) * (page - 1), 0.f);
    
    if (CGPointEqualToPoint(scrollView.contentOffset, contentOffset) == false) {
        
        // Update content offset
        scrollView.contentOffset = contentOffset;
    }
    
    [self.mainPagebar updatePagebar];
}

- (void) addContentView:(UIScrollView *)scrollView page:(NSInteger)page {
    
    CGRect viewRect = CGRectZero;
    
    // Setup content view
    viewRect.size = scrollView.bounds.size;
    viewRect.origin.x = CGRectGetWidth(viewRect) * (page - 1);
    viewRect = CGRectInset(viewRect, scrollViewOutset, 0.f);
    
    // Setup document properties
    NSURL* fileURL = self.document.fileURL;
    NSString* password = self.document.filePassword;
    NSString* guid = self.document.guid;
    
    // Init content view
    ContentView* contentView = [[ContentView alloc] initWithFrame: viewRect
                                                          fileURL: fileURL
                                                             page: page
                                                         password: password];
    
    contentView.message = self;
    [self.contentViews setObject: contentView forKey: [NSNumber numberWithInteger: page]];
    
    [scrollView addSubview: contentView];
    
    // Request page preview thumb
    [contentView showPageThumb: fileURL page: page password: password guid: guid];
    
    if (self.imagesCache != nil) {
        // Get annotation by page
        NSNumber* pageNumber = [NSNumber numberWithInteger: page];
        
        if ([self.imagesCache objectForKey: pageNumber]) {
            UIImage* image = [UIImage imageWithData: [self.imagesCache objectForKey: pageNumber]];
            [contentView setContentDrawingImageView: image];
        }
    }
}

- (void) layoutContentViews:(UIScrollView *)scrollView {
    
    CGFloat viewWidth = CGRectGetWidth(scrollView.bounds);
    CGFloat contentOffsetX = scrollView.contentOffset.x;
    
    NSInteger pageB = (CGFloat)(contentOffsetX + viewWidth - 1.f) / viewWidth;
    NSInteger pageA = contentOffsetX / viewWidth;
    pageB += 2;
    
    if (pageA < minPage) {
        pageA = minPage;
    }
    
    if (pageB > maxPage) {
        pageB = maxPage;
    }
    
    NSRange pageRange = NSMakeRange(pageA, (pageB - pageA + 1));
    
    NSMutableIndexSet* pageSet = [[NSMutableIndexSet alloc] init];
    pageSet = [NSMutableIndexSet indexSetWithIndexesInRange: pageRange];
    
    for (NSNumber* key in [self.contentViews allKeys]) {
        
        NSInteger page = [key integerValue];
        
        if ([pageSet containsIndex: page] == NO) {
            
            ContentView* contentView = [self.contentViews objectForKey: key];
            [contentView removeFromSuperview];
            
            [self.contentViews removeObjectForKey: key];
        }
        
        else {
            [pageSet removeIndex: page];
        }
    }
    
    NSInteger pages = pageSet.count;
    
    if (pages > 0) {
        
        NSEnumerationOptions options = 0;
        
        if (pages == 2) {
            
            if (maxPage > 2 && [pageSet lastIndex] == maxPage) {
                
                options = NSEnumerationReverse;
            }
        }
        
        else if (pages == 3) {
            
            NSMutableIndexSet* workSet = [pageSet mutableCopy];
            options = NSEnumerationReverse;
            
            [workSet removeIndex: [pageSet firstIndex]];
            [workSet removeIndex: [pageSet lastIndex]];
            
            NSInteger page = [workSet firstIndex];
            [pageSet removeIndex: page];
            
            [self addContentView: scrollView page: page];
        }
        
        [pageSet enumerateIndexesWithOptions: options usingBlock:
             ^(NSUInteger page, BOOL* stop) {
                 [self addContentView: scrollView page: page];
             }
         ];
    }
}

- (void) handleScrollViewDidEnd:(UIScrollView *)scrollView {
    
    // Get scrollView width
    CGFloat viewWidth = CGRectGetWidth(scrollView.bounds);
    
    // Get content offset by x
    CGFloat contentOffsetX = scrollView.contentOffset.x;
    
    // Setup current page
    NSInteger page = (contentOffsetX / viewWidth) + 1;
    
    if (page != currentPage) {
        
        currentPage = page;
        self.document.pageNumber = [NSNumber numberWithInteger: page];
        
        [self.contentViews enumerateKeysAndObjectsUsingBlock:
             ^(NSNumber* key, ContentView* contentView, BOOL* stop) {
                 
                 if ([key integerValue] != page) {
                     [contentView zoomResetAnimated: NO];
                 }
             }
         ];
        
        [self.mainPagebar updatePagebar];
    }
}

- (void) showDocumentPage: (NSInteger)pageNumber {
    
    if (currentPage != pageNumber) {
        
        if (pageNumber < minPage || pageNumber > maxPage) {
            return;
        }
        
        [self saveAnnotation];
        
        currentPage = pageNumber;
        self.document.pageNumber = [NSNumber numberWithInteger: pageNumber];
        
        CGPoint contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.bounds) * (pageNumber - 1), 0.f);
        
        if (CGPointEqualToPoint(self.scrollView.contentOffset, contentOffset) == true) {
            [self layoutContentViews: self.scrollView];
        } else {
            [self.scrollView setContentOffset: contentOffset];
        }
        
        [self.contentViews enumerateKeysAndObjectsUsingBlock:
             ^(NSNumber* key, ContentView* contentView, BOOL* stop) {

                 if ([key integerValue] != pageNumber) {
                     [contentView zoomResetAnimated: NO];
                 }
             }
         ];
        
        // Update Pagebar
        [self.mainPagebar updatePagebar];
    }
}

- (void) showPDFDocument {
    
    // Update current content size by scrollView
    [self updateContentSize: self.scrollView];
    
    // Display initial pageNumber in document
    [self showDocumentPage: [self.document.pageNumber integerValue]];
    
    // Update document last open date
    self.document.lastOpenDate = [NSDate date];
}

- (void) closePDFDocument {
    
    if (printInteraction != nil) {
        [printInteraction dismissAnimated: NO];
    }
    
    [self.document archiveDocumentProperties];
    
    [[ThumbQueue sharedInstance] cancelOperationsWithGUID: self.document.guid];
    [[ThumbCache sharedInstance] removeAllObjects];
}

#pragma mark - UIScrollViewDelegate methods

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (ignoreDidScroll == NO) {
        [self layoutContentViews: scrollView];
    }
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [self handleScrollViewDidEnd: scrollView];
}

- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    [self handleScrollViewDidEnd: scrollView];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if ([touch.view isKindOfClass: [UIScrollView class]]) {
        return YES;
    }
    
    return NO;
}

#pragma mark - UIGestureRecognizer methods

- (void) decrementPageNumber {
    
    if (maxPage > minPage && currentPage != minPage) {
        
        CGPoint contentOffset = self.scrollView.contentOffset;
        
        contentOffset.x -= CGRectGetWidth(self.scrollView.bounds);
        
        [self.scrollView setContentOffset: contentOffset animated: YES];
    }
}

- (void) incrementPageNumber {

    if (maxPage > minPage && currentPage != maxPage) {
        
        CGPoint contentOffset = self.scrollView.contentOffset;
        
        contentOffset.x += CGRectGetWidth(self.scrollView.bounds);
        
        [self.scrollView setContentOffset: contentOffset animated: YES];
    }
}

- (void) handleSingleTap:(UITapGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        
        // Get current view bounds
        CGRect viewRect = recognizer.view.bounds;
        
        // Get current touch position
        CGPoint point = [recognizer locationInView: recognizer.view];
        
        // Setup area rect by inset
        CGRect areaRect = CGRectInset(viewRect, tapAreaSize, 0.f);
        
        // If single tap is inside in areaRect
        if (CGRectContainsPoint(areaRect, point) == true) {
            
            // Get current page number key
            NSNumber* key = [NSNumber numberWithInteger: currentPage];
            
            // Setup current target view
            ContentView* contentView = [self.contentViews objectForKey: key];
            
            // Initialize target object
            id targetObj = [contentView processSingleTap: recognizer];
            
            // Handle target object
            if (targetObj != nil) {
                
                // Open new url
                if ([targetObj isKindOfClass: [NSURL class]]) {
                    
                    // Cast target object to NSURL
                    NSURL* url = (NSURL *) targetObj;
                    
                    // Handle missing URL scheme
                    if (url.scheme == nil) {
                        
                        // Get current url string
                        NSString* startUrl = url.absoluteString;
                        
                        // Check up for 'www'
                        if ([startUrl hasPrefix: @"www"] == YES) {
                            
                            // Setup new url
                            NSString* currentHttp = [[NSString alloc] initWithFormat: @"http://%@", startUrl];
                            
                            // Make http-based URL
                            url = [NSURL URLWithString: currentHttp];
                        }
                    }
                }
                
                // If target is not url, check for another object type
                else {
                    
                    // Go to new page
                    if ([targetObj isKindOfClass: [NSNumber class]]) {
                        
                        // Setup page number
                        NSInteger pageNumber = [targetObj integerValue];
                        
                        // Show new page
                        [self showDocumentPage: pageNumber];
                    }
                }
            }
            
            // If not active tapped in the content view
            else {
                
                // Check for delay since last hide
                if ([lastHideTime timeIntervalSinceNow] < -0.75f) {
                    
                    if (self.drawingToolbar.alpha < 1.f ||
                        self.mainPagebar.alpha < 1.f ) {
                        
                        [self.drawingToolbar showToolbar];
                        [self.mainPagebar showPagebar];
                        // [self showNavigationBar: self.navigationController.navigationBar];
                        
                        [[self navigationController] setNavigationBarHidden: NO animated: YES];
                    }
                }
            }
            
            return;
        }
        
        // Setup next page area
        CGRect nextPageRect = viewRect;
        nextPageRect.size.width = tapAreaSize;
        nextPageRect.origin.x = CGRectGetWidth(viewRect) - tapAreaSize;
        
        // Check if user increment page
        if (CGRectContainsPoint(nextPageRect, point) == true) {

            [self incrementPageNumber];
            return;
        }
        
        CGRect previousPageRect = viewRect;
        previousPageRect.size.width = tapAreaSize;
        
        // Check if user decrement page
        if (CGRectContainsPoint(previousPageRect, point) == true) {
            
            [self decrementPageNumber];
            return;
        }
    }
}

- (void) handleDoubleTap:(UITapGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        
        CGRect viewRect = recognizer.view.bounds;
        
        CGPoint point = [recognizer locationInView: recognizer.view];
        
        CGRect zoomArea = CGRectInset(viewRect, tapAreaSize, tapAreaSize);
        
        if (CGRectContainsPoint(zoomArea, point) == true) {
            
            NSNumber* key = [NSNumber numberWithInteger: currentPage];

            ContentView* contentView = [self.contentViews objectForKey: key];
            
            switch (recognizer.numberOfTouchesRequired) {
                case 1:
                    [contentView zoomIncrement: recognizer];
                    break;
                    
                default:
                    [contentView zoomDecrement: recognizer];
                    break;
            }
            
            return;
        }
        
        CGRect nextPageRect = viewRect;
        nextPageRect.size.width = tapAreaSize;
        nextPageRect.origin.x = CGRectGetWidth(viewRect) - tapAreaSize;
        
        if (CGRectContainsPoint(nextPageRect, point) == true) {
            
            [self incrementPageNumber];
            return;
        }
        
        CGRect previousPageRect = viewRect;
        previousPageRect.size.width = tapAreaSize;
        
        if (CGRectContainsPoint(previousPageRect, point) == true) {
            
            [self decrementPageNumber];
            return;
        }
    }
}

#pragma mark - ContentViewDelegate methods

- (void) contentView:(ContentView *)contentView touchesBegan:(NSSet *)touches {
    
    if (self.mainPagebar.alpha > 0.f || self.drawingToolbar.alpha > 0.f) {
        
        if (touches.count == 1) {
            
            UITouch* touch = [touches anyObject];
            
            CGPoint point = [touch locationInView: self.view];
            
            CGRect areaRect = CGRectInset(self.view.bounds, tapAreaSize, tapAreaSize);
            
            if (CGRectContainsPoint(areaRect, point) == false) {
                return;
            }
        }
        
        [self.mainPagebar hidePagebar];
        [self.drawingToolbar hideToolbar];
        [[self navigationController] setNavigationBarHidden: YES animated: YES];
        
        lastHideTime = [NSDate date];
    }
}

#pragma mark - MainPagebarDelegate implementation

- (void) pagebar:(MainPagebar *)pageBar gotoPage:(NSInteger)page {
    
    [self showDocumentPage: page];
}

#pragma mark - UIApplication notification methods 

- (void) applicationWillResign:(NSNotification *)notification {
 
    // Save document changes
    [self.document archiveDocumentProperties];
    
    if (printInteraction != nil) {
        [printInteraction dismissAnimated: NO];
    }
}

- (BOOL) isBlankImage:(UIImage *)image {
    
    typedef struct {
        uint8_t red;
        uint8_t green;
        uint8_t blue;
        uint8_t alpha;
    } PixelColor;
    
    // Initialize image reference by image data
    CGImageRef imageReference = [image CGImage];
    
    // Get a bitmap content for current image
    CGContextRef imageContext =
        CGBitmapContextCreate(NULL,
                              CGImageGetWidth(imageReference),
                              CGImageGetHeight(imageReference),
                              CGImageGetBitsPerComponent(imageReference),
                              CGImageGetBytesPerRow(imageReference),
                              CGImageGetColorSpace(imageReference),
                              CGImageGetBitmapInfo(imageReference));
    
    // Draw current image into created context
    CGContextDrawImage(imageContext, CGRectMake(0, 0, CGImageGetWidth(imageReference), CGImageGetHeight(imageReference)), imageReference);
    
    // Get pixels colors from created image
    PixelColor* pixels = CGBitmapContextGetData(imageContext);
    
    // Get counts of pixels
    size_t pixelsCount = CGImageGetWidth(imageReference) * CGImageGetHeight(imageReference);
    
    // Iterate each one pixel you have
    for (size_t i = 0; i < pixelsCount; i++) {
        
        // Get current pixel by index
        PixelColor pixelColor = pixels[i];
        
        // Check exist image by having colors
        if (pixelColor.red > 0 || pixelColor.green > 0 || pixelColor.blue > 0 || pixelColor.alpha > 0) {
            
            // Current image is not blank
            return NO;
        }
    }
    
    // Current image is blank
    return YES;
}

- (void) drawingToolbar:(DrawingToolbar *)toolbar touchesCanceled:(UIButton *)button {
    
    [self updateColorButtonImage];
}

- (void) tappedInToolbar:(DrawingToolbar *)toolbar drawButton:(UIButton *)button {
 
    // Check if current button is color button
    if (button.tag == 9) {
        
        [button setHighlighted: !button.isHighlighted];
        
        // Initialize new color settings view controller
        [self openToolProperties: button];
        
    } else {
        
        // Block scrolling, for drawing in current page
        [self.scrollView setScrollEnabled: NO];
        
        // Initialize content view for drawing
        ContentView* contentView = (ContentView *) [self.contentViews objectForKey: [NSNumber numberWithInteger: currentPage]];
        
        [contentView setScrollEnabled: NO];
        
        // Iterate child subviews in content view
        for (UIView* subview in contentView.subviews) {
            
            // Enable user interaction
            subview.userInteractionEnabled = YES;
            
            // Iterate child subviews for subview
            for (UIView* childSubview in subview.subviews) {
                
                // Check if current subview is a content page
                if ([childSubview isKindOfClass: [ContentPage class]]) {
                    
                    // Enable user interaction for child subview
                    childSubview.userInteractionEnabled = YES;
                    
                    // Initialize current content page
                    ContentPage* contentPage = (ContentPage *) childSubview;
                    [contentPage hideDrawingView];
                    
                    // Using only in edit mode buttons
                    if (self.drawingView == nil && button.tag <= 8) {
                        
                        // Initialize view by frame of content page
                        self.drawingView = [[DrawingView alloc] initWithFrame: contentPage.frame];
                        
                        // Get current image
                        UIImage* drawingImage = [contentPage getDrawingImage];
                        
                        // Setup drawing view by current image
                        if (drawingImage != nil) {

                            [self.drawingView loadImage: drawingImage];
                        }
                    }
                    
                    // If drawing view is initialized
                    else {
                        
                        // Get current drawing tool
                        DrawingToolType drawingTool = self.drawingView.drawingTool;
                        
                        // Get current button tag
                        NSInteger tag = button.tag;
                        
                        // If button type is drawing type, save current annotation
                        if ( (drawingTool == DrawingToolTypePen && tag == 1)||
                             (drawingTool == DrawingToolTypeText && tag == 2) ||
                             (drawingTool == DrawingToolTypeRectangleStroke && tag == 4) ||
                             (drawingTool == DrawingToolTypeRectangleFill && tag == 5) ||
                             (drawingTool == DrawingToolTypeLine && tag == 3) ||
                             (drawingTool == DrawingToolTypeEllipseStroke && tag == 6) ||
                             (drawingTool == DrawingToolTypeEllipseFill && tag == 7) ||
                             (drawingTool == DrawingToolTypeEraser && tag == 8)) {
                            
                            // Save annotation
                            [self saveAnnotation];
                        }
                    }
                    
                    // Clear selection, when user selected editing button
                    if (button.tag <= 8) {
                        
                        // Clear buttons selection
                        [self.drawingToolbar clearButtonSelection: 8];
                    }
                    
                    // Check if current drawing view is installed
                    if (self.drawingView != nil) {
                        
                        self.drawingView.delegate = self;
                        
                        // Using only for editing buttons
                        if (button.tag <= 8) {
                            
                            button.backgroundColor = [UIColor colorWithRed: 0.22f green: 0.33f blue: 0.44f alpha: 1.f];

                            button.tintColor = [UIColor whiteColor];
                        }
                        
                        switch (button.tag) {
                                
                            // Setup pen button
                            case 1:
                                self.drawingView.drawingTool = DrawingToolTypePen;
                                break;
                                
                            // Setup text button
                            case 2:
                                self.drawingView.drawingTool = DrawingToolTypeText;
                                //self.lineWidth = [NSNumber numberWithFloat: 10.f];
                                break;
                                
                            // Setup line button
                            case 3:
                                self.drawingView.drawingTool = DrawingToolTypeLine;
                                break;
                                
                            // Setup square button
                            case 4:
                                self.drawingView.drawingTool = DrawingToolTypeRectangleStroke;
                                break;
                                
                            // Setup highlight button
                            case 5:
                                self.drawingView.drawingTool = DrawingToolTypeRectangleFill;
                                //self.lineAlpha = [NSNumber numberWithFloat: 0.5f];
                                break;

                            // Setup circle button
                            case 6:
                                self.drawingView.drawingTool = DrawingToolTypeEllipseStroke;
                                break;
                                
                            // Setup circle fill button
                            case 7:
                                self.drawingView.drawingTool = DrawingToolTypeEllipseFill;
                                break;

                            // Setup eraser button
                            case 8:
                                self.drawingView.drawingTool = DrawingToolTypeEraser;
                                break;
                                
                            // Setup color button
                            case 9:
                                [self openToolProperties: button];
                                break;

                            // Setup undo button
                            case 10:

                                // Undo latest step
                                [self.drawingView undoLatestStep];
                                
                                // Update current button status
                                [self updateButtonStatus];

                                break;
                                
                            // Setup redo button
                            case 11:
                                
                                // Redo latest step
                                [self.drawingView redoLatestStep];
                                
                                // Update current button status
                                [self updateButtonStatus];

                                break;
                                
                            // Setup clear button
                            case 12:
                                
                                // Clear modifications in current page
                                [self.drawingView clear];
                                
                                // Update current button status
                                [self updateButtonStatus];
                                
                                break;
                                
                            // Setup default button
                            default:
                                self.drawingView.drawingTool = DrawingToolTypePen;
                                break;
                        }
                        
                        // Update drawing view
                        [self updateDrawingView];
                        
                        // add new subview to current content page
                        [contentPage addSubview: self.drawingView];
                    }
                    
                    break;
                }
            }
        }
    }
}

- (void) saveAnnotation {
    
    // Clear all button selection
    [self.drawingToolbar clearButtonSelection: 8];
    
    ContentView* innerDrawingView = (ContentView *) [self.contentViews objectForKey: [NSNumber numberWithInteger: currentPage]];
    
    [innerDrawingView setScrollEnabled: YES];
    
    // Displaying all inner drawing view
    for (UIView* drawingSubview in innerDrawingView.subviews) {
        
        drawingSubview.userInteractionEnabled = NO;
        
        for (UIView* innerDrawingSubview in drawingSubview.subviews) {
            
            if ( [innerDrawingSubview isKindOfClass: [ContentPage class]] ) {
                
                innerDrawingSubview.userInteractionEnabled = NO;
                
                ContentPage* contentPage = (ContentPage *) innerDrawingSubview;
                
                if (self.drawingView != nil) {
                    
                    // Starting Save image coding
                    
                    if ( ![self isBlankImage: self.drawingView.image] &&
                        self.drawingView.image != nil) {
                        
                        [contentPage showDrawingView: self.drawingView.image];
                        [contentPage addSubview: self.drawingView];
                        
                        NSData* currentImage = UIImagePNGRepresentation(self.drawingView.image);
                        
                        // Add annotation to cache
                        [self updateCacheWithImage: currentImage byPage: [NSNumber numberWithInteger: currentPage]];
                    }
                    
                    [contentPage showDrawingView: self.drawingView.image];
                    [self.drawingView removeFromSuperview];
                }
                
                self.drawingView = nil;
                
                // Save image coding ended...
                break;
            }
        }
    }
    
    [self.scrollView setScrollEnabled: YES];
}

- (void) updateCacheWithImage:(NSData *)image byPage:(NSNumber *)pageNumber {

    if (self.imagesCache == nil) {
        self.imagesCache = [[NSCache alloc] init];
    }

    // Replace image, if it exists in cache
    if ([self.imagesCache objectForKey: pageNumber]) {
        [self.imagesCache removeObjectForKey: pageNumber];
    }
    
    // Add image to cache
    [self.imagesCache setObject: image forKey: pageNumber];
}

- (void) saveDocument {
    
    if (self.imagesCache == nil) {
        return;
    }
    
    BOOL __block documentSaved = NO;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
       
        NSURL* fileURL = [self.document fileURL];
        
        // Initialize local document
        CGPDFDocumentRef documentReference = CGPDFDocumentCreateWithURL((__bridge_retained CFURLRef) fileURL);
        
        NSMutableData* documentData = [NSMutableData data];
        UIGraphicsBeginPDFContextToData(documentData, self.drawingView.bounds, nil);
        
        // Iterate through pages
        for (int page = 1; page <= [self.document.pageCount intValue]; page++) {
            
            // Get current page
            CGPDFPageRef pageReference = CGPDFDocumentGetPage(documentReference, page);
            
            // Setup page frame
            CGRect pageFrame = CGPDFPageGetBoxRect(pageReference, kCGPDFMediaBox);
            
            UIGraphicsBeginPDFPageWithInfo(pageFrame, nil);
            
            // Draw current page
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSaveGState(context);
            CGContextScaleCTM(context, 1.f, -1.f);
            CGContextTranslateCTM(context, 0.f, - CGRectGetHeight(pageFrame));
            CGContextDrawPDFPage(context, pageReference);
            CGContextRestoreGState(context);
            
            UIImage* image = [UIImage imageWithData: [self.imagesCache objectForKey: [NSNumber numberWithInt: page]]];
            
            if (image != nil) {
                [image drawInRect: pageFrame];
            }
        }
        
        UIGraphicsEndPDFContext();
        
        // Release current document reference
        CGPDFDocumentRelease(documentReference);
        
        // Save changes to document
        if ([[NSFileManager defaultManager] createFileAtPath: [self.document filePath] contents: documentData attributes: nil]) {
            documentSaved = YES;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Display information in UI (todo)
            if (documentSaved == YES) {
                NSLog(@"File saved");
                [self.imagesCache removeAllObjects];
                self.imagesCache = nil;
            }
        });
    });
}

- (void) updateDrawingView {
    
    if (self.drawingView != nil) {
        
        // Setup drawing view values
        self.drawingView.lineColor = self.lineColor;
        self.drawingView.lineWidth = [self.lineWidth floatValue];
        self.drawingView.lineAlpha = [self.lineAlpha floatValue];
    }
}

#pragma mark - DrawingViewDelegate methods

- (void) drawingView:(DrawingView *)drawingView didEndDrawUsingTool:(id<DrawingTool>)drawingTool {
    
    [self updateButtonStatus];
}

- (void) updateButtonStatus {
    
    self.drawingToolbar.undoButton.enabled = [self.drawingView canUndo];
    self.drawingToolbar.redoButton.enabled = [self.drawingView canRedo];
}

- (void) openToolProperties:(UIButton *)button {
    
    ToolPropertiesController* toolPropertiesController = [[ToolPropertiesController alloc] initWithLineColor: self.lineColor lineWidth: [self.lineWidth floatValue] lineAlpha: [self.lineAlpha floatValue]];

    toolPropertiesController.delegate = self;
    toolPropertiesController.modalPresentationStyle = UIModalPresentationPopover;
    toolPropertiesController.popoverPresentationController.sourceView = button;
    toolPropertiesController.popoverPresentationController.sourceRect = button.bounds;
    [self presentViewController: toolPropertiesController animated: YES completion: nil];
    
    [self updateColorButtonImage];
}

- (void) updateColorButtonImage {

    self.drawingToolbar.colorButton.imageView.image = [UIImage imageFromColor: self.lineColor
                                                                           withFrame: self.drawingToolbar.colorButton.imageView.bounds];
}

#pragma mark - ToolPropertiesDelegate methods

- (void) colorValueUpdated:(UIColor *)color {
    
    self.lineColor = color;
    
    [self updateColorButtonImage];
    [self updateDrawingView];
}

- (void) thickessValueUpdated:(CGFloat)thickness {
    
    self.lineWidth = [NSNumber numberWithFloat: thickness];
    
    [self updateDrawingView];
}

- (void) opacityValueUpdated:(CGFloat)opacity {
 
    self.lineAlpha = [NSNumber numberWithFloat: opacity];

    [self updateDrawingView];
}

@end