//
//  File.h
//  EduTeacher
//
//  Created by Andrew Kochulab on 01.02.16.
//  Copyright © 2016 Andrew Kochulab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Annotation;

NS_ASSUME_NONNULL_BEGIN

@interface File : NSManagedObject

@property (nullable, nonatomic, retain) NSDate *fileDate;
@property (nullable, nonatomic, retain) NSString *filePath;
@property (nullable, nonatomic, retain) NSNumber *fileSize;
@property (nullable, nonatomic, retain) NSNumber *pageCount;
@property (nullable, nonatomic, retain) NSSet<Annotation *> *annotation;

@end


@interface File (CoreDataGeneratedAccessors)

- (void) addAnnotationObject:(Annotation *)value;
- (void) removeAnnotationObject:(Annotation *)value;
- (void) addAnnotation:(NSSet<Annotation *> *)values;
- (void) removeAnnotation:(NSSet<Annotation *> *)values;

@end

NS_ASSUME_NONNULL_END