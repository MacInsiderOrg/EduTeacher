//
//  SubjectUICollectionViewController.h
//  EduTeacher
//
//  Created by Bohdan Savych on 1/30/16.
//  Copyright © 2016 Andrew Kochulab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubjectCollectionViewController : UICollectionViewController<UICollectionViewDelegate,UICollectionViewDataSource>
@property(strong,nonatomic)NSArray* subjectImagesArray;
@property(strong,nonatomic)NSArray* subjectNamesArray;
@end
