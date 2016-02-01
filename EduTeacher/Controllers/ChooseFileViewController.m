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

@property (strong, nonatomic) NSArray* documentsNames;

@end


@implementation ChooseFileViewController

#pragma mark - UIViewController methods

- (NSArray *) getDocumentsNames {
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex: 0];
    NSError* error = nil;
    
    NSArray* extensionList = [NSArray arrayWithObjects: @"pdf", @"ppt", @"pptx", nil];
    
    NSArray* fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: documentsDirectory error: &error];
    
    NSMutableArray* documentsNames = [NSMutableArray array];
    
    for(NSString* filepath in fileList) {
        
        if ([extensionList containsObject: [filepath pathExtension]]) {
            
            // Found Document with format from extensionList
            [documentsNames addObject: filepath];
        }
    }

    return documentsNames;
}

- (void) viewDidLoad {
    [super viewDidLoad];
   
    // Get documents names
    self.documentsNames = [self getDocumentsNames];
    
    NSLog(@"Lisf of Documents: %@", self.documentsNames);

    if (self.documentsNames != nil) {
        
        // This is test
        // In future, we used tableview and select file by user clicked
        NSString* filePath = [[NSHomeDirectory() stringByAppendingPathComponent: @"Documents"] stringByAppendingPathComponent: [self.documentsNames lastObject]];
        
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