//
//  Document.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 19.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import "PDFDocument.h"
#import <UIKit/UIKit.h>
#import "Functions.h"

@implementation PDFDocument

#pragma mark - Initialization

- (instancetype) initWithFilePath:(NSString *)filePath password:(NSString *)password {
    
    self = [super init];
    
    if (self) {
        
        if ([PDFDocument isPDFDocument: filePath] == YES) {

            _guid = [PDFDocument GUID];
            _filePath = [filePath copy];
            _filePassword = [password copy];
            _pageNumber = [NSNumber numberWithInteger: 1];
            
            // Get reference for PDF document if it exist by current filePath
            
            CGPDFDocumentRef pdfDocReference = CGPDFDocumentCreateUsingUrl((__bridge CFURLRef)[self fileURL], _filePassword);
            
            if (pdfDocReference != nil) {
                _pageCount = [NSNumber numberWithInteger: CGPDFDocumentGetNumberOfPages(pdfDocReference)];
                
                CGPDFDocumentRelease(pdfDocReference);
            }
            else {
                NSLog(@"Error, pdfDocReference is nil");
            }
            
            // Get information about date and size
            _lastOpenDate = [NSDate dateWithTimeIntervalSinceReferenceDate: 0.0];
            
            NSFileManager* fileManager = [NSFileManager defaultManager];
            NSDictionary* fileAttributes = [fileManager attributesOfItemAtPath: _filePath error: nil];
            
            _fileDate = [fileAttributes objectForKey: NSFileModificationDate];
            _fileSize = [fileAttributes objectForKey: NSFileSize];
            
            [self archiveDocumentProperties];
        }
    }
    
    return self;
}

#pragma mark - Instance Properties

- (NSString *) fileName {
    
    if (_fileName == nil) {
        _fileName = [_filePath lastPathComponent];
    }
    
    return _fileName;
}

- (NSURL *) fileURL {
    
    if (_fileURL == nil) {
        _fileURL = [[NSURL alloc] initFileURLWithPath: _filePath isDirectory: NO];
    }
    
    return _fileURL;
}

#pragma mark - Instance Methods

- (BOOL) archiveDocumentProperties {
    
    NSString* archiveFilePath = [PDFDocument archiveFilePath: [self fileName]];

    return [NSKeyedArchiver archiveRootObject: self toFile:archiveFilePath];
}

- (void) updateDocumentProperties {
    
    // Update information about document properties
    
    CFURLRef urlReference = (__bridge CFURLRef) [self fileURL];
    
    CGPDFDocumentRef documentReference = CGPDFDocumentCreateUsingUrl(urlReference, self.filePassword);
    
    if (documentReference != NULL) {
        
        self.pageCount = [NSNumber numberWithInteger: CGPDFDocumentGetNumberOfPages(documentReference)];
        
        CGPDFDocumentRelease(documentReference);
    }
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSDictionary* fileAttributes = [fileManager attributesOfItemAtPath: _filePath error: NULL];

    _fileDate = [fileAttributes objectForKey: NSFileModificationDate];
    _fileSize = [fileAttributes objectForKey: NSFileSize];
}


#pragma mark - PDFDocument Static methods

+ (PDFDocument *) unarchiveFromFileName:(NSString *)filePath password:(NSString *)password {
    
    PDFDocument* document = nil;
    
    NSString* fileName = [filePath lastPathComponent];
    
    NSString* archiveFilePath = [PDFDocument archiveFilePath: fileName];
    
    @try {
        document = [NSKeyedUnarchiver unarchiveObjectWithFile: archiveFilePath];
        
        if (document != nil) {
            document.filePath = [filePath copy];
            document.filePassword = [password copy];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Error");
    }
    
    return document;
}

+ (PDFDocument *) withDocumentFilePath:(NSString *)filePath password:(NSString *)password {
    
    // Init document by file path

    PDFDocument* document = nil;
    
    document = [PDFDocument unarchiveFromFileName: filePath password: password];
    
    if (document == nil) {
        document = [[PDFDocument alloc] initWithFilePath: filePath password: password];
        NSLog(@"Document with filePath: %@ initialized.", filePath);
    }
    
    return document;
}

+ (PDFDocument *) unarchiveFromFilePath:(NSString *)filePath password:(NSString *)password {

    // Unarchive document by file path
    PDFDocument* document = nil;
    
    // Having only file name
    NSString* fileName = [filePath lastPathComponent];
    
    // Make archive file path
    NSString* archiveFilePath = [PDFDocument archiveFilePath: fileName];
    
    // Unarchive an archived PDFDocument object
    @try {
        document = [NSKeyedUnarchiver unarchiveObjectWithFile: archiveFilePath];
        
        if (document != nil) {
            document.filePath = filePath;
            document.filePassword = password;
        }
    }
    @catch (NSException *exception) { // Sometimes we can receive error (testing)
        NSLog(@"Error in PDFDocument.withDocumentFilePath");
    }
    
    return document;
}

+ (NSString *) archiveFilePath:(NSString *)fileName {
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    // Get application support path
    NSURL* pathUrl = [fileManager URLForDirectory: NSApplicationSupportDirectory
                                         inDomain: NSUserDomainMask
                                appropriateForURL: nil
                                           create: YES
                                            error: NULL];
    
    NSString* appSupportPath = [pathUrl path];
    
    NSString* archivePath = [appSupportPath stringByAppendingPathComponent: @"PDFDocs_Metadata"];
    
    [fileManager createDirectoryAtPath: archivePath
           withIntermediateDirectories: NO
                            attributes: nil
                                 error: NULL];
    
    NSString* archiveName = [[fileName stringByDeletingPathExtension] stringByAppendingPathExtension: @"plist"];
    
    // Make new plist -> {archiveName}/<fileName>.plist
    return [archivePath stringByAppendingPathComponent: archiveName];
}


+ (BOOL) isPDFDocument:(NSString *)filePath {
    return YES;
}


+ (NSString *) GUID {
    
    CFUUIDRef currentUUID = CFUUIDCreate(NULL);
    CFStringRef stringReference = CFUUIDCreateString(NULL, currentUUID);
    
    NSString* uniqueGUID = [NSString stringWithString: (__bridge id) stringReference];
    
    CFRelease(stringReference);
    CFRelease(currentUUID);
    
    return uniqueGUID;
}


#pragma mark - NSCoding protocol methods

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super init];
    
    if (self) {
        _guid = [aDecoder decodeObjectForKey: @"FileGUID"];
        _fileDate = [aDecoder decodeObjectForKey: @"FileDate"];
        _pageNumber = [aDecoder decodeObjectForKey: @"PageNumber"];
        _pageCount = [aDecoder decodeObjectForKey: @"PageCount"];
        _fileSize = [aDecoder decodeObjectForKey: @"FileSize"];
        _lastOpenDate = [aDecoder decodeObjectForKey: @"LastOpen"];
    }
    
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {

    [aCoder encodeObject: _guid forKey: @"FileGUID"];
    [aCoder encodeObject: _fileDate forKey: @"FileDate"];
    [aCoder encodeObject: _pageNumber forKey: @"PageNumber"];
    [aCoder encodeObject: _pageCount forKey: @"PageCount"];
    [aCoder encodeObject: _fileSize forKey: @"FileSize"];
    [aCoder encodeObject: _lastOpenDate forKey: @"LastOpen"];
}

@end