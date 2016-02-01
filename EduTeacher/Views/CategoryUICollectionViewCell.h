//
//  CategoryUICollectionViewCell.h
//  EduTeacher
//
//  Created by Bohdan Savych on 2/1/16.
//  Copyright © 2016 Andrew Kochulab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryUICollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
