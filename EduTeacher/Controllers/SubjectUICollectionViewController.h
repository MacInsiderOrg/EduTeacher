//
//  SubjectUICollectionViewController.h
//  EduTeacher
//
//  Created by Bohdan Savych on 1/30/16.
//  Copyright © 2016 Andrew Kochulab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubjectUICollectionViewController : UICollectionViewController<UICollectionViewDelegate,UICollectionViewDataSource>
@property(strong,nonatomic)NSArray* subjectImagesArray;
@end
