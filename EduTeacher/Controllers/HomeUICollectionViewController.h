//
//  HomeUICollectionViewController.h
//  EduTeacher
//
//  Created by Bohdan Savych on 1/29/16.
//  Copyright © 2016 Andrew Kochulab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeCollectionViewCell.h"

@interface HomeUICollectionViewController : UICollectionViewController
@property(strong,nonatomic)NSArray* topicsNamesArray;
@property(strong,nonatomic)NSArray *backgroundImageArray;
@property(strong,nonatomic)NSArray* backGroundsColorsArray;
@end
