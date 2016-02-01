//
//  PDFDataManager.h
//  EduTeacher
//
//  Created by Andrew Kochulab on 31.01.16.
//  Copyright © 2016 Andrew Kochulab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Annotation.h"
#import "File.h"

@interface PDFDataManager : NSObject

@property (strong, nonatomic, readonly) NSManagedObjectContext* managedObjectContext;
@property (strong, nonatomic, readonly) NSManagedObjectModel* managedObjectModel;
@property (strong, nonatomic, readonly) NSPersistentStoreCoordinator* persistentStoreCoordinator;

+ (PDFDataManager *) sharedInstance;

- (void) saveContext;
- (NSURL *) applicationDocumentsDirectory;

- (File *) getFileByPath:(NSString *)filePath;
- (void) deleteFileByPath:(NSString *)filePath;

- (void) addAnnotation:(NSMutableDictionary *)annotationDict;
- (Annotation *) getAnnotationByPath:(NSString *)filePath withPage:(NSNumber *)page;
- (UIImage *) getAnnotationImage:(NSString *)filePath withPage:(NSNumber *)page;

@end