//
//  Annotation.h
//  EduTeacher
//
//  Created by Andrew Kochulab on 31.01.16.
//  Copyright © 2016 Andrew Kochulab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Annotation : NSManagedObject

@property (nullable, nonatomic, retain) NSNumber *page;
@property (nullable, nonatomic, retain) NSData *image;
@property (nullable, nonatomic, retain) NSManagedObject *file;

@end

NS_ASSUME_NONNULL_END