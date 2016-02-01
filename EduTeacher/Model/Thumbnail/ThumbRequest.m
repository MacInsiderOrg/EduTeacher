//
//  ThumbRequest.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 20.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import "ThumbRequest.h"
#import "ThumbView.h"

@implementation ThumbRequest

#pragma mark - Initialization

+ (instancetype) newForView:(ThumbView *)view
                    fileURL:(NSURL *)url
                   password:(NSString *)password
                       guid:(NSString *)guid
                       page:(NSInteger)page
                       size:(CGSize)size {
    
    return [[ThumbRequest alloc] initForView: view
                                     fileURL: url
                                    password: password
                                        guid: guid
                                        page: page
                                        size: size];
    
}

- (instancetype) initForView:(ThumbView *)view
                    fileURL:(NSURL *)url
                   password:(NSString *)password
                       guid:(NSString *)guid
                       page:(NSInteger)page
                       size:(CGSize)size {
    
    self = [super init];
    
    if (self) {
        
        NSInteger width = size.width;
        NSInteger height = size.height;
        
        _thumbView = view;
        _thumbPage = page;
        _thumbSize = size;
        
        _fileURL = [url copy];
        _filePassword = [password copy];
        _guid = [guid copy];

        _thumbName = [[NSString alloc] initWithFormat: @"%07i-%04ix%04i", (int)page, (int)width, (int)height];
        
        _cacheKey = [[NSString alloc] initWithFormat: @"%@+%@", _thumbName, _guid];
        
        _targetTag = [_cacheKey hash];
        _thumbView.targetTag = _targetTag;
        
        // Thumb screent scale (mainScreen scale)
        _scale = [[UIScreen mainScreen] scale];        
    }
    
    return self;
}

@end