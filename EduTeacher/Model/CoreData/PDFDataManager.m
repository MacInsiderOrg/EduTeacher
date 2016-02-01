//
//  PDFDataManager.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 31.01.16.
//  Copyright © 2016 Andrew Kochulab. All rights reserved.
//

#import "PDFDataManager.h"
#import <CoreData/CoreData.h>

@interface PDFDataManager ()

@property (strong, nonatomic) NSString* fileEntity;
@property (strong, nonatomic) NSString* annotationEntity;

@end


@implementation PDFDataManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

static PDFDataManager* instance = nil;

+ (PDFDataManager *) sharedInstance {
    
    @synchronized(self) {
        
        if (!instance || instance == NULL) {
            instance = [[PDFDataManager alloc] init];
        }
        
        return instance;
    }
}

- (id) init {
    
    self = [super init];

    if (self) {
        
        _fileEntity = @"File";
        _annotationEntity = @"Annotation";
    }
    
    return self;
}

- (void) saveContext {
    
    NSError* error = nil;
    
    NSManagedObjectContext* managedObjectContext = self.managedObjectContext;
    
    if (managedObjectContext != nil) {
        
        if ([managedObjectContext hasChanges] && ![managedObjectContext save: &error]) {
            
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *) managedObjectContext {
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator* persistentStoreCoordinator = [self persistentStoreCoordinator];
    
    if (persistentStoreCoordinator != nil) {
        
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator: persistentStoreCoordinator];
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *) managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL* url = [[NSBundle bundleForClass: [self class]] URLForResource: @"PDFModel" withExtension: @"momd"];
    
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL: url];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL* url = [[self applicationDocumentsDirectory] URLByAppendingPathComponent: @"PDFModel.sqlite"];
    
    NSError* error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    
    if (! [_persistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType configuration: nil URL: url options: nil error: &error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Documents directory

- (NSURL *) applicationDocumentsDirectory {
    
    return [[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory inDomains: NSUserDomainMask] lastObject];
}

#pragma mark - Operation with File model

- (File *) getFileByPath:(NSString *)filePath {
    
    File* file = nil;
    
    NSManagedObjectContext* objContext = [self managedObjectContext];
    
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName: self.fileEntity
                                                         inManagedObjectContext: objContext];
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity: entityDescription];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat: @"(filePath = %@)", filePath];
    [fetchRequest setPredicate: predicate];
    
    NSError* error;
    NSArray* objects = [objContext executeFetchRequest: fetchRequest
                                                 error: &error];
    
    if (! ([objects count] == 0)) {
        file = (File *) objects[0];
    }
    
    fetchRequest = nil;
    
    return file;
}

- (void) deleteFileByPath:(NSString *)filePath {
    
    File* file = [self getFileByPath: filePath];
    
    if (file != nil) {
        
        [self.managedObjectContext deleteObject: file];
        [self saveContext];
    }
}

#pragma mark - Operation with Annotation model

- (void) addAnnotation:(NSMutableDictionary *)annotationDict {
    
    NSData* image = [annotationDict objectForKey: @"image"];
    NSNumber* currentPage = [annotationDict objectForKey: @"page"];
    NSString* filePath = [annotationDict objectForKey: @"filePath"];
    
    File* file;
    Annotation* annotation = [self getAnnotationByPath: filePath withPage: currentPage];
    
    if (annotation == nil) {
        
        annotation = (Annotation *) [NSEntityDescription insertNewObjectForEntityForName: self.annotationEntity
                                                                  inManagedObjectContext: self.managedObjectContext];
        annotation.image = image;
        annotation.page = currentPage;
    }
    
    else {
        annotation.image = image;
    }
    
    file = [self getFileByPath: filePath];
    
    if (file == nil) {
     
        NSNumber* fileSize = [annotationDict objectForKey: @"fileSize"];
        NSNumber* pageCount = [annotationDict objectForKey: @"pageCount"];
        NSDate* fileDate = [annotationDict objectForKey: @"fileDate"];
        
        file = (File *) [NSEntityDescription insertNewObjectForEntityForName: self.fileEntity
                                                      inManagedObjectContext: self.managedObjectContext];
        
        file.filePath = filePath;
        file.fileSize = fileSize;
        file.pageCount = pageCount;
        file.fileDate = fileDate;
    }
    
    [file addAnnotationObject: annotation];
    
    [self saveContext];
}

- (Annotation *) getAnnotationByPath:(NSString *)filePath withPage:(NSNumber *)page {
    
    Annotation* annotation = nil;
    
    NSManagedObjectContext* objContext = [self managedObjectContext];
    
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName: self.annotationEntity
                                                         inManagedObjectContext: objContext];
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity: entityDescription];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat: @"(page=%@)", page];
    [fetchRequest setPredicate: predicate];
    
    NSError* error;
    NSArray* objects = [objContext executeFetchRequest: fetchRequest
                                                 error: &error];
    
    if (! ([objects count] == 0)) {
        annotation = (Annotation *) objects[0];
    }
    
    fetchRequest = nil;
    
    return annotation;
}

- (UIImage *) getAnnotationImage:(NSString *)filePath withPage:(NSNumber *)page {
    
    UIImage* image = nil;
    Annotation* annotation = [self getAnnotationByPath: filePath withPage: page];
    
    if (annotation.image != nil) {
        
        image = [UIImage imageWithData: annotation.image];
    }
    
    return image;
}

@end