//
//  DrawingView.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 20.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import "DrawingView.h"
#import "DrawingPenTool.h"
#import "DrawingEraserTool.h"
#import "DrawingLineTool.h"
#import "DrawingTextTool.h"
#import "DrawingRectangleTool.h"
#import "DrawingEllipseTool.h"

@interface DrawingView ()

// Saves all paths drawn figures
// for further withdrawal if necessary
@property (strong, nonatomic) NSMutableArray* pathArray;

// Used to store canceled shapes and
// possibilities to restore the previous state
@property (strong, nonatomic) NSMutableArray* bufferArray;

// Saves the selected utility for drawing
@property (strong, nonatomic) id <DrawingTool> currentTool;

@property (strong, nonatomic) UIImage* image;
@property (strong, nonatomic) UITextView* textView;

@property (assign, nonatomic) CGFloat originalFrameYPosition;

@end


// Setup autorelease macros
#define PDF_AUTORELEASE(exp) (exp)

@implementation DrawingView {
    
    CGPoint currentPoint;
    CGPoint firstPreviousPoint;
    CGPoint secondPreviousPoint;
    
    UIColor* defaultLineColor;
    CGFloat defaultLineWidth;
    CGFloat defaultLineAlpha;
}

#pragma mark - Initialization 

- (instancetype) initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame: frame];
    
    if (self) {
        
        [self configure];
    }
    
    return self;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder: aDecoder];
    
    if (self) {

        [self configure];
    }
    
    return self;
}

- (void) configure {
    
    // Setup default values
    defaultLineColor = [UIColor blackColor];
    defaultLineWidth = 10.f;
    defaultLineAlpha = 1.f;
    
    // Init private arrays
    self.pathArray = [NSMutableArray array];
    self.bufferArray = [NSMutableArray array];
    
    // Setup the default values for properties
    // which in the future can be changeble
    self.lineColor = defaultLineColor;
    self.lineWidth = defaultLineWidth;
    self.lineAlpha = defaultLineAlpha;
    
    // Setup transparent background
    self.backgroundColor = [UIColor clearColor];
    
    // Initialize frame y position
    self.originalFrameYPosition = CGRectGetMinY(self.frame);
    
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver: self
                           selector: @selector(keyboardDidShow:)
                               name: UIKeyboardDidShowNotification
                             object: nil];
    
    [notificationCenter addObserver: self
                           selector: @selector(keyboardDidHide:)
                               name: UIKeyboardDidHideNotification
                             object: nil];
}

#pragma mark - Instance methods

#pragma mark - Drawing

- (void) drawRect:(CGRect)rect {
    
    [self.image drawInRect: self.bounds];
    [self.currentTool draw];
}

- (void) updateCacheImage:(BOOL)redraw {
    
    // Initialize current context
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.f);
    
    if (redraw) {
        
        // Erase previous image
        self.image = nil;
        
        // Load previous image
        // Using if user return to previous screen
        [[self.previousImage copy] drawInRect: self.bounds];
        
        // Redraw all objects
        for (id <DrawingTool> tool in self.pathArray) {
            
            // Redraw
            [tool draw];
        }
    }
    
    // If not setup redrawing option
    else {
        
        // Setup the draw point
        [self.image drawAtPoint: CGPointZero];
        [self.currentTool draw];
    }
    
    // Saving current image context
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    
    // End using current context
    UIGraphicsEndImageContext();
}

- (void) finishDrawing {
    
    // Update current image
    [self updateCacheImage: NO];
    
    // Clear the redo queue
    [self.bufferArray removeAllObjects];
    
    // Call the instance delegate
    if ([self.delegate respondsToSelector: @selector(drawingView:didEndDrawUsingTool:)]) {
        
        [self.delegate drawingView: self didEndDrawUsingTool: self.currentTool];
    }
    
    // Clear current drawing tool
    self.currentTool = nil;
}

- (id <DrawingTool>) toolWithCurrentSettings {
    
    switch (self.drawingTool) {

        case DrawingToolTypePen:
            return PDF_AUTORELEASE([DrawingPenTool new]);
        
        case DrawingToolTypeLine:
            return PDF_AUTORELEASE([DrawingLineTool new]);
            
        case DrawingToolTypeText:
            return PDF_AUTORELEASE([DrawingTextTool new]);
            
        case DrawingToolTypeEraser:
            return PDF_AUTORELEASE([DrawingEraserTool new]);
        
        case DrawingToolTypeRectangleStroke: {
            
            DrawingRectangleTool* rectangleTool = PDF_AUTORELEASE([DrawingRectangleTool new]);
            rectangleTool.fill = NO;
            return rectangleTool;
        }
            
        case DrawingToolTypeRectangleFill: {

            DrawingRectangleTool* rectangleTool = PDF_AUTORELEASE([DrawingRectangleTool new]);
            rectangleTool.fill = YES;
            return rectangleTool;
        }
            
        case DrawingToolTypeEllipseStroke: {
            
            DrawingEllipseTool* ellipseTool = PDF_AUTORELEASE([DrawingEllipseTool new]);
            ellipseTool.fill = NO;
            return ellipseTool;
        }
            
        case DrawingToolTypeEllipseFill: {

            DrawingEllipseTool* ellipseTool = PDF_AUTORELEASE([DrawingEllipseTool new]);
            ellipseTool.fill = YES;
            return ellipseTool;
        }
    }
}


#pragma mark - Touch methods

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (self.textView && !self.textView.hidden) {
        
        [self commitAndHideTextEntry];
        return;
    }
    
    // Setup the first touch
    UITouch* touch = [touches anyObject];
    firstPreviousPoint = [touch previousLocationInView: self];
    currentPoint = [touch locationInView: self];
    
    // Initialize the bezier path
    self.currentTool = [self toolWithCurrentSettings];
    self.currentTool.lineColor = self.lineColor;
    self.currentTool.lineWidth = self.lineWidth;
    self.currentTool.lineAlpha = self.lineAlpha;
    
    // Checking if current tool is text tool
    if ([self.currentTool isKindOfClass: [DrawingTextTool class]]) {
        
        // Initialize text box
        [self initializeTextBox: currentPoint];
    }
    
    // Otherwise (for all others tools)
    else {
        
        // Add tool to pathes tools
        [self.pathArray addObject: self.currentTool];
        
        // Setup initial position
        [self.currentTool setInitialPosition: currentPoint];
    }
    
    // Call the instance delegate
    if ([self.delegate respondsToSelector: @selector(drawingView:willBeginDrawUsingTool:)]) {
        
        [self.delegate drawingView: self willBeginDrawUsingTool: self.currentTool];
    }
}

- (void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    // Save all previous touches to the path
    UITouch* touch = [touches anyObject];
    
    secondPreviousPoint = firstPreviousPoint;
    firstPreviousPoint = [touch previousLocationInView: self];
    currentPoint = [touch locationInView: self];
    
    // Detecting pen tool
    if ([self.currentTool isKindOfClass: [DrawingPenTool class]]) {
        
        CGRect bounds = [(DrawingPenTool *) self.currentTool addPathSecondPreviousPoint: secondPreviousPoint withFirstPreviousPoint: firstPreviousPoint withCurrentPoint: currentPoint];
        
        CGRect drawBox = bounds;
        drawBox.origin.x -= self.lineWidth * 2.f;
        drawBox.origin.y -= self.lineWidth * 2.f;
        drawBox.size.width += self.lineWidth * 4.f;
        drawBox.size.height += self.lineWidth * 4.f;
        
        [self setNeedsDisplayInRect: drawBox];
    }
    
    // Detecting text tool
    else if ([self.currentTool isKindOfClass: [DrawingTextTool class]]) {
        
        [self resizeTextViewFrame: currentPoint];
    }
    
    // Using for another drawing tools
    else {
        
        [self.currentTool moveFromPoint: firstPreviousPoint toPoint: currentPoint];
        
        [self setNeedsDisplay];
    }
}

- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    // Check recorded point
    [self touchesMoved: touches withEvent: event];
    
    // Using for text tool
    if ([self.currentTool isKindOfClass: [DrawingTextTool class]]) {
        
        [self startTextEntry];
    }
    
    // Using for all another tools
    else {
        
        [self finishDrawing];
    }
}

- (void) touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    // Check recorded point
    [self touchesEnded: touches withEvent: event];
}

#pragma mark - Text Entry

- (void) initializeTextBox:(CGPoint)startingPoint {
    
    if (!self.textView) {
        
        // Initialize text view, if before it not initialized
        self.textView = [[UITextView alloc] init];
        
        // Setup delegate
        self.textView.delegate = self;
        
        // Setup types for text view
        self.textView.returnKeyType = UIReturnKeyDone;
        self.textView.autocorrectionType = UITextAutocorrectionTypeNo;
        
        // Setup background color and initialize layer
        self.textView.backgroundColor = [UIColor clearColor];
        self.textView.layer.borderWidth = 1.f;
        self.textView.layer.borderColor = [[UIColor grayColor] CGColor];
        self.textView.layer.cornerRadius = 8.f;
        
        // Setup content inset
        [self.textView setContentInset: UIEdgeInsetsZero];
        
        // Add current text view to self view
        [self addSubview: self.textView];
    }
    
    // Multiply lineWidth on three value for setup font size
    int fontSize = self.lineWidth * 3.f;
    
    self.textView.textColor = self.lineColor;
    [self.textView setFont: [UIFont systemFontOfSize: fontSize]];
    self.textView.alpha = self.lineAlpha;
    
    // Setup default values
    int defaultWidth = 200;
    int defaultHeight = fontSize * 2;
    int initialYPosition = startingPoint.y - defaultHeight / 2;
    
    // Make frame using below values
    CGRect frame = CGRectMake(startingPoint.x, initialYPosition, defaultWidth, defaultHeight);
    frame = [self adjustFrameWithinDrawingBounds: frame];
    
    // Setup text view properties
    self.textView.frame = frame;
    self.textView.text = @"";
    self.textView.hidden = NO;
}

- (void) startTextEntry {
 
    if (!self.textView.hidden) {
        
        [self.textView becomeFirstResponder];
    }
}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString: @"\n"]) {

        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void) textViewDidChange:(UITextView *)textView {
    
    CGRect frame = self.textView.frame;
    
    if (self.textView.contentSize.height > CGRectGetHeight(frame)) {

        frame.size.height = self.textView.contentSize.height;
    }
    
    //
    self.textView.frame = frame;
}

- (void) textViewDidEndEditing:(UITextView *)textView {
    
    [self commitAndHideTextEntry];
}

- (void) resizeTextViewFrame:(CGPoint)size {
    
    // Setup minimum allowed size
    int minimumAllowedWidth = self.textView.font.pointSize * 0.5f;
    int minimumAllowedHeight = self.textView.font.pointSize * 2.f;
    
    CGRect frame = self.textView.frame;
    
    // Adjust width value
    int newWidth = size.x - CGRectGetMinX(self.textView.frame);
    
    if (newWidth > minimumAllowedWidth) {
        
        frame.size.width = newWidth;
    }
    
    // Adjust height value
    int newHeight = size.y - CGRectGetMinY(self.textView.frame);
    
    if (newHeight > minimumAllowedHeight) {
        
        frame.size.height = newHeight;
    }
    
    frame = [self adjustFrameWithinDrawingBounds: frame];
    
    self.textView.frame = frame;
}

- (CGRect) adjustFrameWithinDrawingBounds:(CGRect)frame {
    
    // Check if current frame does not beyond
    // bounds of parent view
    if ( (CGRectGetMinX(frame) + CGRectGetWidth(frame)) > CGRectGetWidth(self.frame)) {
        
        frame.size.width = CGRectGetWidth(self.frame) - CGRectGetMinX(frame);
    }
    
    if ( (CGRectGetMinY(frame) + CGRectGetHeight(frame)) > CGRectGetHeight(self.frame)) {
        
        frame.size.height = CGRectGetHeight(self.frame) - CGRectGetMinY(frame);
    }
    
    return frame;
}

- (void) commitAndHideTextEntry {
    
    [self.textView resignFirstResponder];
    
    // If text inputted in current text view
    if ([self.textView.text length]) {
        
        UIEdgeInsets textInset = self.textView.textContainerInset;
        
        // Setup padding;
        CGFloat xPadding = 5.f;
        
        CGRect frame = self.textView.frame;
        
        // Setup start and end position
        CGPoint startPosition = CGPointMake(CGRectGetMinX(frame) + textInset.left + xPadding,
                                            CGRectGetMinY(frame) + textInset.top);
        
        CGPoint endPosition = CGPointMake(CGRectGetMinX(frame) + CGRectGetWidth(frame) - xPadding,
                                          CGRectGetMinY(frame) + CGRectGetHeight(frame));
        
        // Setup text for text view
        ((DrawingTextTool *) self.currentTool).attributedText = [self.textView.attributedText copy];
        
        // Setup new tool for path array
        [self.pathArray addObject: self.currentTool];
        
        // Setup new position
        [self.currentTool setInitialPosition: startPosition];
        [self.currentTool moveFromPoint: startPosition toPoint: endPosition];
        
        [self setNeedsDisplay];
        
        // Drawing current text
        [self finishDrawing];
    }
    
    self.currentTool = nil;
    self.textView.hidden = YES;
    self.textView = nil;
}


#pragma mark - Keyboard events

- (void) keyboardDidShow:(NSNotification *)notification {
    
    // If current orientation is landscape
    if (UIInterfaceOrientationIsLandscape((UIInterfaceOrientation)[[UIDevice currentDevice] orientation])) {
        
        [self landscapeChanges: notification];
    }
    
    // If current orientation is portrait
    else {
        
        [self portraintChanges: notification];
    }
}

- (void) landscapeChanges:(NSNotification *)notification {
    
    CGPoint bottomPoint = [self convertPoint: self.textView.frame.origin toView: self];
    CGFloat originY = bottomPoint.y;
    CGFloat bottomY = originY + CGRectGetHeight(self.textView.frame);
    
    // Setup keyboard size
    CGSize keyboardSize = [[[notification userInfo] objectForKey: UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // Setup offset for current frame
    CGFloat frameOffset = CGRectGetHeight(self.frame) - keyboardSize.width - bottomY;
    
    if (frameOffset < 0) {
     
        CGFloat yPosition = CGRectGetMinY(self.frame);
        
        // Setup new y position
        self.frame = CGRectMake(CGRectGetMinX(self.frame), yPosition, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    }
    
}

- (void) portraintChanges:(NSNotification *)notification {
    
    CGPoint bottomPoint = [self convertPoint: self.textView.frame.origin toView: nil];
    bottomPoint.y += CGRectGetHeight(self.textView.frame);
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    // Setup keyboard size
    CGSize keyboardSize = [[[notification userInfo] objectForKey: UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // Setup offset for current frame
    CGFloat frameOffset = CGRectGetHeight(screenRect) - keyboardSize.height - bottomPoint.y;
    
    if (frameOffset < 0) {
        
        CGFloat yPosition = CGRectGetMinY(self.frame) + frameOffset;
        
        // Setup new y position
        self.frame = CGRectMake(CGRectGetMinX(self.frame), yPosition, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    }
    
}

- (void) keyboardDidHide:(NSNotification *)notification {
    
    // Setup new y position
    self.frame = CGRectMake(CGRectGetMinX(self.frame), self.originalFrameYPosition, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}


#pragma mark - Load Image methods

- (void) loadImage:(UIImage *)image {
    
    self.image = image;
    
    // Setup loaded image to previous image
    // using when user setup button (undo steps)
    self.previousImage = [image copy];
    
    // Clean all pathes and undo buffer,
    // when loading external image
    [self.bufferArray removeAllObjects];
    [self.pathArray removeAllObjects];
    [self updateCacheImage: YES];
    [self setNeedsDisplay];
}

- (void) loadImageData:(NSData *)imageData {
    
    // Setup image scale
    CGFloat imageScale = ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) ? [[UIScreen mainScreen] scale] : 1.f;

    // Setup new image
    UIImage* image = [UIImage imageWithData: imageData scale: imageScale];
    
    // Load new image
    [self loadImage: image];
}

- (void) resetTool {
    
    // Using for text tool only
    if ([self.currentTool isKindOfClass: [DrawingTextTool class]]) {
        
        self.textView.text = @"";
        [self commitAndHideTextEntry];
    }
    
    self.currentTool = nil;
}


#pragma mark - Another actions

- (NSUInteger) undoSteps {

    return self.bufferArray.count;
}

- (BOOL) canUndo {
    
    return self.pathArray.count > 0;
}

- (void) undoLatestStep {
    
    // Using for undo all latest steps
    if ([self canUndo]) {
        
        [self resetTool];
        
        id <DrawingTool> tool = [self.pathArray lastObject];
        
        // Add current tool to buffer
        // Using if user want to redo latest undo steps :)
        [self.bufferArray addObject: tool];
        
        // Remove current tool from array
        [self.pathArray removeLastObject];
        
        // Remove all modification by this tool from user screen
        [self updateCacheImage: YES];
        [self setNeedsDisplay];
    }
}

- (BOOL) canRedo {

    return self.bufferArray.count > 0;
}

- (void) redoLatestStep {
    
    // Using for redo all latest steps
    if ([self canRedo]) {
        
        [self resetTool];
        
        id <DrawingTool> tool = [self.bufferArray lastObject];
        
        // Add current tool to path array
        [self.pathArray addObject: tool];
        
        // Remove current tool from array
        [self.bufferArray removeLastObject];
        
        // Add new modification to user screen
        [self updateCacheImage: YES];
        [self setNeedsDisplay];
    }
}

- (void) clear {
    
    [self resetTool];
    
    // Remove all objects from arrays
    [self.bufferArray removeAllObjects];
    [self.pathArray removeAllObjects];
    
    self.previousImage = nil;
    [self updateCacheImage: YES];

    [self setNeedsDisplay];
}

- (void) dealloc {
    
    self.pathArray = nil;
    self.bufferArray = nil;
    self.currentTool = nil;
    self.image = nil;
    self.previousImage = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

@end
