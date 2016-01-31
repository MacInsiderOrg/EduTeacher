//
//  ContentTile.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 21.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import "ContentTile.h"

@implementation ContentTile {
 
    NSInteger levelsOfDetail;
}

#pragma mark - Initialization

- (instancetype) init {
    
    self = [super init];
    
    if (self) {
        
        levelsOfDetail = 16;
        
        // Setup zooming levels
        self.levelsOfDetail = levelsOfDetail;
        
        // Setup bias levels
        self.levelsOfDetailBias = levelsOfDetail - 1;
        
        // Main screen
        UIScreen* mainScreen = [UIScreen mainScreen];
        
        // Main screen scale and bounds
        CGFloat screenScale = [mainScreen scale];
        CGRect screenBounds = [mainScreen bounds];
        
        // Make new pixels by width and height count by scaling
        CGFloat pixelsByWidth = CGRectGetWidth(screenBounds) * screenScale;
        CGFloat pixelsByHeight = CGRectGetHeight(screenBounds) * screenScale;
        
        // Get max value from width and height count of pixels
        CGFloat maxPixels = MAX(pixelsByWidth, pixelsByHeight);
        
        // Make count of tiles in board
        CGFloat sizeOfTiles = (maxPixels < 512.f) ? 512.f : 1024.f;
        
        // Setup tileSize for instance
        self.tileSize = CGSizeMake(sizeOfTiles, sizeOfTiles);
    }
    
    return self;
}

#pragma mark - ContentTile static methods

+ (CFTimeInterval) fadeDuration {
    
    // Flickering tiles
    return 0.001;
}

@end
