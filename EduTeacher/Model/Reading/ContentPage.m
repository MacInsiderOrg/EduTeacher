//
//  DrawingPage.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 20.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import "ContentPage.h"
#import "PDFDocumentLink.h"
#import "Functions.h"
#import "ContentTile.h"

@implementation ContentPage {
    
    NSMutableArray* links;
    UIImageView* drawingImageView;
    
    CGPDFDocumentRef documentReference;
    CGPDFPageRef pageReference;
    
    NSInteger pageAngle;
    
    CGFloat pageWidth;
    CGFloat pageHeight;
    
    CGFloat pageOffsetX;
    CGFloat pageOffsetY;
}

+ (Class) layerClass {
    
    return [ContentTile class];
}

#pragma mark - Initialization
- (instancetype) initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame: frame];
    
    if (self) {
        self.autoresizesSubviews = NO;
        self.userInteractionEnabled = NO;
        self.contentMode = UIViewContentModeRedraw;
        self.autoresizingMask = UIViewAutoresizingNone;
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (instancetype) initWithUrl:(NSURL *)fileUrl page:(NSInteger)page password:(NSString *)password {
    
    CGRect viewRect = CGRectZero;
    
    // Check if current file url is existed
    if (fileUrl != nil) {
        
        // Get document reference by file url and pass
        documentReference = CGPDFDocumentCreateUsingUrl((__bridge CFURLRef) fileUrl, password);
        
        // Check if document reference is created
        if (documentReference != NULL) {
            
            if (page < 1) {
                page = 1;
            }
            
            // Get count of pages
            NSInteger pages = CGPDFDocumentGetNumberOfPages(documentReference);
            
            if (page > pages) {
                page = pages;
            }
            
            // Create page reference from document by page number
            pageReference = CGPDFDocumentGetPage(documentReference, page);
            
            // Check if page reference is existed
            if (pageReference != NULL) {
                
                // Retain current page
                CGPDFPageRetain(pageReference);
                
                // Create rectangles
                CGRect cropBoxRect = CGPDFPageGetBoxRect(pageReference, kCGPDFCropBox);
                CGRect mediaBoxRect = CGPDFPageGetBoxRect(pageReference, kCGPDFMediaBox);
                CGRect effectiveRect = CGRectIntersection(cropBoxRect, mediaBoxRect);
                
                // Get angle by page
                pageAngle = CGPDFPageGetRotationAngle(pageReference);
                
                switch (pageAngle) {
                        
                    default:
                    case 0:
                    case 180:
                        pageWidth = CGRectGetWidth(effectiveRect);
                        pageHeight = CGRectGetHeight(effectiveRect);
                        pageOffsetX = CGRectGetMinX(effectiveRect);
                        pageOffsetY = CGRectGetMinY(effectiveRect);
                        break;
                        
                    case 90:
                    case 270:
                        pageWidth = CGRectGetHeight(effectiveRect);
                        pageHeight = CGRectGetWidth(effectiveRect);
                        pageOffsetX = CGRectGetMinY(effectiveRect);
                        pageOffsetY = CGRectGetMinX(effectiveRect);
                        break;
                }
            }
            
            NSInteger pWidth = pageWidth;
            NSInteger pHeight = pageHeight;
            
            if (pWidth % 2) {
                pWidth--;
            }
            
            if (pHeight % 2) {
                pHeight--;
            }
            
            viewRect.size = CGSizeMake(pWidth, pHeight);
        }
        else {
            NSLog(@"Error");
        }
    }
    else {
        NSLog(@"Error");
    }
    
    ContentPage* contentPageView = [self initWithFrame: viewRect];
    
    if (contentPageView != nil) {
        
        [self buildAnnotationLinksList];
    }
    
    drawingImageView = [[UIImageView alloc] initWithImage: nil];
    [self addSubview: drawingImageView];
    
    return contentPageView;
}

#pragma mark - Instance methods

- (void) dealloc {
    
    // Break retain page reference
    CGPDFPageRelease(pageReference);
    pageReference = NULL;
    
    // Break retain document reference
    CGPDFDocumentRelease(documentReference);
    documentReference = NULL;
}

- (void) showDrawingView:(UIImage *)previewImage {
    
    drawingImageView.image = previewImage;
    
    drawingImageView.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    
    drawingImageView.hidden = NO;
}

- (void) hideDrawingView {
    
    drawingImageView.hidden = YES;
}

- (UIImage *) getDrawingImage {
    
    return drawingImageView.image;
}

- (void) removeFromSuperview {
    
    [drawingImageView removeFromSuperview];
    drawingImageView = nil;
    
    self.layer.delegate = nil;
    
    [super removeFromSuperview];
}

- (void) buildAnnotationLinksList {
    
    // Initialize links list array
    links = [NSMutableArray new];
    
    // Create page annotations array
    CGPDFArrayRef pageAnnotations = NULL;
    
    // Setup page dictionary
    CGPDFDictionaryRef pageDict = CGPDFPageGetDictionary(pageReference);
    
    // Checking if array exists in dictionary
    if (CGPDFDictionaryGetArray(pageDict, "Annots", &pageAnnotations) == true) {
        
        // Setup number of annotations
        NSInteger count = CGPDFArrayGetCount(pageAnnotations);
        
        // Iterate through all array annotations
        for (NSInteger index = 0; index < count; index++) {
            
            // Create PDF annotation link
            CGPDFDictionaryRef annotationDict = NULL;
            
            if (CGPDFArrayGetDictionary(pageAnnotations, index, &annotationDict) == true) {
                
                // Create page annotation subtype string
                const char* annotationSubtype = NULL;
                
                if (CGPDFDictionaryGetName(annotationDict, "Subtype", &annotationSubtype) == true) {
                    
                    // If found annotation with current subtype
                    if (strcmp(annotationSubtype, "Link") == 0) {
                        
                        // Initialize document link
                        PDFDocumentLink* documentLink = [self linkFromAnnotation: annotationDict];
                        
                        if (documentLink != nil) {
                            
                            // Add this link to list
                            [links insertObject: documentLink atIndex: 0];
                        }
                    }
                }
            }
        }
    }
}

- (PDFDocumentLink *) linkFromAnnotation:(CGPDFDictionaryRef)annotationDict {
    
    // Create document link object
    PDFDocumentLink* documentLink = nil;
    
    // Create annotation array, which contain all links coordinates
    CGPDFArrayRef annotationArrayReference = NULL;
    
    if (CGPDFDictionaryGetArray(annotationDict, "Rect", &annotationArrayReference)) {
        
        // Init lower left X and lower left Y values
        CGPDFReal lowerLeftX = 0.f;
        CGPDFReal lowerLeftY = 0.f;
        
        // Init upper right X and upper Right Y values
        CGPDFReal upperRightX = 0.f;
        CGPDFReal upperRightY = 0.f;
        
        // Setup lower left X and Y coordinates
        CGPDFArrayGetNumber(annotationArrayReference, 0, &lowerLeftX);
        CGPDFArrayGetNumber(annotationArrayReference, 1, &lowerLeftY);
        
        // Setup upper right X and Y coordinates
        CGPDFArrayGetNumber(annotationArrayReference, 2, &upperRightX);
        CGPDFArrayGetNumber(annotationArrayReference, 3, &upperRightY);
        
        // Checking and normalizating Xs
        if (lowerLeftX > upperRightX) {
            
            // Swap lowerLeftX and upperRightX
            CGPDFReal t = lowerLeftX;
            lowerLeftX = upperRightX;
            upperRightX = t;
        }
        
        // Checking and normalizating Ys
        if (lowerLeftY > upperRightY) {
            
            // Swap lowerLeftY and upperRightY
            CGPDFReal t = lowerLeftY;
            lowerLeftY = upperRightY;
            upperRightY = t;
        }
        
        // Descending page offset for all coordinates
        lowerLeftX -= pageOffsetX;
        lowerLeftY -= pageOffsetY;
        
        upperRightX -= pageOffsetX;
        upperRightY -= pageOffsetY;
        
        // Page rotation angle
        switch (pageAngle) {
            case 90: {
                
                CGPDFReal swapValue;
                
                // Swap lowerLeftY and lowerLeftX values
                swapValue = lowerLeftY;
                lowerLeftY = lowerLeftX;
                lowerLeftX = swapValue;
                
                // Swap upperRightY and upperRightX values
                swapValue = upperRightY;
                upperRightY = upperRightX;
                upperRightX = swapValue;
                
                break;
            }
                
            case 270: {
                
                CGPDFReal swapValue;
                
                // Swap lowerLeftY and lowerLeftX values
                swapValue = lowerLeftY;
                lowerLeftY = lowerLeftX;
                lowerLeftX = swapValue;
                
                // Swap upperRightY and upperRightX values
                swapValue = upperRightY;
                upperRightY = upperRightX;
                upperRightX = swapValue;
                
                lowerLeftX = (0.f - lowerLeftX) + pageWidth;
                upperRightX = (0.f - upperRightX) + pageWidth;
            }
                
            case 0: {
                lowerLeftY = (0.f - lowerLeftY) + pageHeight;
                upperRightY = (0.f - upperRightY) + pageHeight;
                break;
            }
        }
        
        // Make new rect coordinates
        NSInteger viewRectX = lowerLeftX;
        NSInteger viewRectY = lowerLeftY;
        NSInteger viewRectWidth = upperRightX - lowerLeftX;
        NSInteger viewRectHeight = upperRightY - lowerLeftY;
        
        CGRect viewRect = CGRectMake(viewRectX, viewRectY, viewRectWidth, viewRectHeight);
        documentLink = [PDFDocumentLink newWithRect: viewRect dictionary: annotationDict];
    }
    
    return documentLink;
}

- (void) highlightPageLinks {
    
    // Add highlight views for all links
    if (links.count > 0) {
     
        UIColor* highlightColor = [UIColor colorWithRed: 0.f green: 0.f blue: 1.f alpha: 0.15f];
        
        // Enumerate all links in document
        for (PDFDocumentLink* link in links) {
            
            // Make highlight View for own link
            UIView* highlightView = [[UIView alloc] initWithFrame: link.rect];
            
            highlightView.autoresizesSubviews = NO;
            highlightView.userInteractionEnabled = NO;
            highlightView.contentMode = UIViewContentModeRedraw;
            highlightView.autoresizingMask = UIViewAutoresizingNone;
            
            // Setup blue color for link
            highlightView.backgroundColor = highlightColor;
            
            [self addSubview: highlightView];
        }
    }
}

- (CGPDFArrayRef) destinationWithName:(const char *)destinationName inDestsTree:(CGPDFDictionaryRef)node {

    // Create array, which contains destinations for all links
    CGPDFArrayRef destinationArray = NULL;
    
    // Create limits array for all links
    CGPDFArrayRef limitsArray = NULL;
    
    if (CGPDFDictionaryGetArray(node, "Limits", &limitsArray) == true) {

        CGPDFStringRef lowerLimit = NULL;
        CGPDFStringRef upperLimit = NULL;
        
        // Setup lower and upper limits
        if (CGPDFArrayGetString(limitsArray, 0, &lowerLimit) == true) {

            if (CGPDFArrayGetString(limitsArray, 1, &upperLimit) == true) {
                
                // Setup lower string
                const char* lowerString = (const char *)CGPDFStringGetBytePtr(lowerLimit);
                
                // Setup upper string
                const char* upperString = (const char *)CGPDFStringGetBytePtr(upperLimit);
                
                if ((strcmp(destinationName, lowerString) < 0) || (strcmp(destinationName, upperString) > 0))
                {
                    // Destination name currently is outside
                    // and this all nodes hasnt limits
                    return NULL;
                }
            }
        }
    }
    
    // Create names array
    CGPDFArrayRef namesArray = NULL;
    
    if (CGPDFDictionaryGetArray(node, "Names", &namesArray) == true) {
        
        // Calculate count of names in document
        NSInteger namesCount = CGPDFArrayGetCount(namesArray);
        
        // Iterate of everyone name in names array
        for (NSInteger index = 0; index < namesCount; index += 2) {

            // Create destination name string
            CGPDFStringRef destName;
            
            if (CGPDFArrayGetString(namesArray, index, &destName) == true) {

                const char* currentDestinationName = (const char *)CGPDFStringGetBytePtr(destName);
                
                // Checking if found the destination name
                if (strcmp(currentDestinationName, destinationName) == 0) {

                    if (CGPDFArrayGetArray(namesArray, (index + 1), &destinationArray) == false) {

                        // Create dictionary with destinations
                        CGPDFDictionaryRef destinationDictionary = NULL; // Destination dictionary
                        
                        if (CGPDFArrayGetDictionary(namesArray, (index + 1), &destinationDictionary) == true) {
                            
                            // Setup destination array by keys and values of dictionary
                            CGPDFDictionaryGetArray(destinationDictionary, "D", &destinationArray);
                        }
                    }
                    
                    return destinationArray;
                }
            }
        }
    }
    
    // Create kids array
    CGPDFArrayRef kidsArray = NULL;
    
    if (CGPDFDictionaryGetArray(node, "Kids", &kidsArray) == true) {

        // Calculate count of elements in kids array
        NSInteger kidsCount = CGPDFArrayGetCount(kidsArray);
        
        // Iterate each element in kids array
        for (NSInteger index = 0; index < kidsCount; index++) {

            // Create current kid node dictionary
            CGPDFDictionaryRef currentKidNode = NULL;
            
            // Recurse it into node
            if (CGPDFArrayGetDictionary(kidsArray, index, &currentKidNode) == true) {
                
                // Fill destination array with kid nodes
                destinationArray = [self destinationWithName: destinationName inDestsTree: currentKidNode];
                
                if (destinationArray != NULL) {
                    
                    return destinationArray;
                }
            }
        }
    }
    
    return NULL;
}

- (id) annotationLinkTarget:(CGPDFDictionaryRef)annotationDictionary {
    
    // Create link target object
    id linkTarget = nil;
    
    // Create destination name and string variables
    CGPDFStringRef destinationName = NULL;
    const char* destinationString = NULL;
    
    // Create dictionary with actions
    CGPDFDictionaryRef actionDictionary = NULL;
    
    // Create destination array
    CGPDFArrayRef destinationArray = NULL;
    
    if (CGPDFDictionaryGetDictionary(annotationDictionary, "A", &actionDictionary) == true) {

        // Create annotation type string
        const char* actionType = NULL;
        
        if (CGPDFDictionaryGetName(actionDictionary, "S", &actionType) == true) {

            // Goto current action type
            if (strcmp(actionType, "GoTo") == 0) {
                if (CGPDFDictionaryGetArray(actionDictionary, "D", &destinationArray) == false) {
                    CGPDFDictionaryGetString(actionDictionary, "D", &destinationName);
                }
            }
            
            // Handle other link action type
            else {

                // URI action type
                if (strcmp(actionType, "URI") == 0) {

                    // Create action's URI string
                    CGPDFStringRef uriString = NULL;
                    
                    if (CGPDFDictionaryGetString(actionDictionary, "URI", &uriString) == true) {

                        // Create destination URI string
                        const char* uri = (const char *)CGPDFStringGetBytePtr(uriString);
                        
                        // Create target with UTF8 coding
                        NSString* target = [NSString stringWithCString:uri encoding:NSUTF8StringEncoding];
                        
                        linkTarget = [NSURL URLWithString:[target stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    }
                }
            }
        }
    }
    
    // Handle other link target
    else {

        if (CGPDFDictionaryGetArray(annotationDictionary, "Dest", &destinationArray) == false) {

            if (CGPDFDictionaryGetString(annotationDictionary, "Dest", &destinationName) == false) {

                CGPDFDictionaryGetName(annotationDictionary, "Dest", &destinationString);
            }
        }
    }
    
    // Handle a destination name
    if (destinationName != NULL) {
        
        // Initialize catalog dictionary by document
        CGPDFDictionaryRef catalogDictionary = CGPDFDocumentGetCatalog(documentReference);
        
        // Create dictionary with names
        CGPDFDictionaryRef namesDictionary = NULL;
        
        if (CGPDFDictionaryGetDictionary(catalogDictionary, "Names", &namesDictionary) == true) {

            // Create dictionary which contain information
            // about current document destinations
            CGPDFDictionaryRef destsDictionary = NULL;
            
            if (CGPDFDictionaryGetDictionary(namesDictionary, "Dests", &destsDictionary) == true) {
                
                // Setup destination name string
                const char* destName = (const char *)CGPDFStringGetBytePtr(destinationName);
                
                // Setup destination array
                destinationArray = [self destinationWithName: destName inDestsTree: destsDictionary];
            }
        }
    }
    
    // Checking if nowly destination string is not initialized
    if (destinationString != NULL) {
        
        // Initialize catalog dictionary by document
        CGPDFDictionaryRef catalogDictionary = CGPDFDocumentGetCatalog(documentReference);
        
        // Craete dictionary with document destinations
        CGPDFDictionaryRef destsDictionary = NULL;
        
        if (CGPDFDictionaryGetDictionary(catalogDictionary, "Dests", &destsDictionary) == true) {
            
            // Create target dictionary by destination targets
            CGPDFDictionaryRef targetDictionary = NULL;
            
            if (CGPDFDictionaryGetDictionary(destsDictionary, destinationString, &targetDictionary) == true) {

                CGPDFDictionaryGetArray(targetDictionary, "D", &destinationArray);
            }
        }
    }

    // Handle a destination array
    if (destinationArray != NULL) {
        
        // Init target page number, default = 0
        NSInteger targetPageNumber = 0;
        
        // Setup reference for page dictionary from destination array
        CGPDFDictionaryRef pageDictionaryFromDestArray = NULL;
        
        if (CGPDFArrayGetDictionary(destinationArray, 0, &pageDictionaryFromDestArray) == true) {
            
            // Calculate count of pages
            NSInteger pageCount = CGPDFDocumentGetNumberOfPages(documentReference);
            
            // Iterate of each one page in pages array
            for (NSInteger pageNumber = 1; pageNumber <= pageCount; pageNumber++) {
                
                // Get reference for current page in document
                CGPDFPageRef pageRef = CGPDFDocumentGetPage(documentReference, pageNumber);
                
                // Make dictionary reference from page
                CGPDFDictionaryRef pageDictionaryFromPage = CGPDFPageGetDictionary(pageRef);
                
                // If found it, save page number
                if (pageDictionaryFromPage == pageDictionaryFromDestArray) {
                    
                    targetPageNumber = pageNumber; break;
                }
            }
        }
        
        // If not succeded below,
        // try page number from array
        else {
            
            // Setup default page number in array
            CGPDFInteger pageNumber = 0;
            
            if (CGPDFArrayGetInteger(destinationArray, 0, &pageNumber) == true) {
                
                // Setup first page in document
                targetPageNumber = (pageNumber + 1); // 1-based
            }
        }
        
        // If target page number is setup, get link target
        if (targetPageNumber > 0) {

            linkTarget = [NSNumber numberWithInteger:targetPageNumber];
        }
    }
    
    return linkTarget;
}

- (void) didMoveToWindow {
    
    // Override scale factor
    self.contentScaleFactor = 1.0f;
}

- (id) processSingleTap:(UITapGestureRecognizer *)recognizer {
    
    // Create tap result object
    id result = nil;
    
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        
        // Process the single tap
        if (links.count > 0) {
            
            // Get point by from tapping position
            CGPoint point = [recognizer locationInView: self];
            
            // Enumerate all links
            for (PDFDocumentLink *link in links) {
                
                // If found current point, setup result value
                if (CGRectContainsPoint(link.rect, point) == true) {

                    result = [self annotationLinkTarget: link.dictionaryReference];
                    break;
                }
            }
        }
    }
    
    return result;
}

#pragma mark - CATiledLayer delegate methods

- (void) drawLayer:(CATiledLayer *)layer inContext:(CGContextRef)context {
    
    // Retain current instance
    ContentPage *contentPage = self;
    
    // Fill by rgb color
    CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
    
    // Fill self rectangle
    CGContextFillRect(context, CGContextGetClipBoundingBox(context));

    // Changes the origin of the user context
    CGContextTranslateCTM(context, 0.0f, CGRectGetHeight(self.bounds));
    CGContextScaleCTM(context, 1.0f, -1.0f);
    
    // Transform user coordinate system to context
    CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(pageReference, kCGPDFCropBox, self.bounds, 0, true));
    
    // Rendering current PDF page into the context
    CGContextDrawPDFPage(context, pageReference);
    
    if (contentPage != nil) {

        // Release self
        contentPage = nil;
    }
}

@end
