//
//  Document.h
//  EduTeacher
//
//  Created by Andrew Kochulab on 19.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDFDocument : NSObject <NSObject, NSCoding>

@property (strong, nonatomic) NSString* fileName;
@property (strong, nonatomic) NSString* filePath;
@property (strong, nonatomic) NSURL*    fileURL;
@property (strong, nonatomic) NSString* filePassword;

@property (strong, nonatomic) NSDate*   fileDate;
@property (strong, nonatomic) NSDate*   lastOpenDate;
@property (strong, nonatomic) NSNumber* fileSize;

@property (strong, nonatomic) NSNumber* pageCount;
@property (strong, nonatomic) NSNumber* pageNumber;

@property (strong, nonatomic) NSString* guid;

+ (PDFDocument *) withDocumentFilePath:(NSString *)filePath password:(NSString *)password;
+ (PDFDocument *) unarchiveFromFileName:(NSString *)filePath password:(NSString *)password;

- (instancetype) initWithFilePath:(NSString *)filePath password:(NSString *)password;
- (void) updateDocumentProperties;
- (BOOL) archiveDocumentProperties;

@end
