//
//  ChooseFileViewController.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 31.01.16.
//  Copyright © 2016 Andrew Kochulab. All rights reserved.
//

#import "ChooseFileViewController.h"
#import "PDFDocumentViewController.h"
#import "PDFDocument.h"

@interface ChooseFileViewController ()

@property (strong, nonatomic) NSArray* pdfDocuments;

@end


@implementation ChooseFileViewController

#pragma mark - UIViewController methods

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Get all documents in current project
    self.pdfDocuments = [[NSBundle mainBundle] pathsForResourcesOfType: @"pdf" inDirectory: nil];
    
    if (self.pdfDocuments != nil) {
        
        // This is test
        // In future, we used tableview and select file by user clicked
        NSString* filePath = [self.pdfDocuments firstObject];
        
        [self openDocument: filePath];
    }
}

#pragma mark - Open Document

- (void) openDocument:(NSString *)filePath {
    
    NSString* password = nil;
    
    // Init PDF document by file path
    PDFDocument* document = [PDFDocument withDocumentFilePath: filePath password: password];
    
    if (document != nil) {
        
        // Init PDFDocument VC with initial PDFDocument
        PDFDocumentViewController* pdfDocumentViewController = [[PDFDocumentViewController alloc] initWithPDFDocument: document];
        
        // Push to drawing VC
        [self.navigationController pushViewController: pdfDocumentViewController animated: YES];
        
    } else {
        NSLog(@"PDFDocument.withDocumentFilePath failed...");
    }
}

#pragma mark - UITableViewController methods

@end