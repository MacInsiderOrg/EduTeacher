//
//  ThumbRequest.h
//  EduTeacher
//
//  Created by Andrew Kochulab on 20.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ThumbView;

@interface ThumbRequest : NSObject <NSObject>

@property (strong, nonatomic) ThumbView* thumbView;

@property (strong, nonatomic, readonly) NSURL* fileURL;
@property (strong, nonatomic, readonly) NSString* guid;
@property (strong, nonatomic, readonly) NSString* filePassword;

@property (strong, nonatomic, readonly) NSString* thumbName;
@property (assign, nonatomic, readonly) NSInteger thumbPage;
@property (assign, nonatomic, readonly) CGSize thumbSize;

@property (strong, nonatomic, readonly) NSString* cacheKey;
@property (assign, nonatomic, readonly) NSUInteger targetTag;
@property (assign, nonatomic, readonly) CGFloat scale;

+ (instancetype) newForView:(ThumbView *)view
                    fileURL:(NSURL *)url
                   password:(NSString *)password
                       guid:(NSString *)guid
                       page:(NSInteger)page
                       size:(CGSize)size;

@end
