//
//  SubjectUICollectionViewController.m
//  EduTeacher
//
//  Created by Bohdan Savych on 1/30/16.
//  Copyright © 2016 Andrew Kochulab. All rights reserved.
//

#import "SubjectUICollectionViewController.h"
#import "SubjectUICollectionViewCell.h"
@implementation SubjectUICollectionViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareColectionView];
   }
#pragma mark-UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"select at %ld",(long)indexPath.row);
}
#pragma mark-UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.subjectImagesArray count];
}
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SubjectUICollectionViewCell* subjectCell=[collectionView dequeueReusableCellWithReuseIdentifier:@"SubjectIdentifier" forIndexPath:indexPath];
    subjectCell.subjectImageView.image=[self.subjectImagesArray objectAtIndex:indexPath.row];
    subjectCell.subjectImageView.contentMode = UIViewContentModeCenter;

    subjectCell.tag=indexPath.row;
    return  subjectCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = CGRectGetWidth(collectionView.bounds)/3;
    CGFloat height = (CGRectGetHeight(collectionView.bounds)- [UIApplication sharedApplication].statusBarFrame.size.height - self.navigationController.navigationBar.bounds.size.height)/3;
    return CGSizeMake(width, height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0,0,0,0);
}
- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self.collectionViewLayout invalidateLayout];
}
#pragma mark-private method
- (void) prepareColectionView
{
    self.subjectImagesArray =[[NSArray alloc]initWithObjects:
                              [UIImage imageNamed:@"biology"],
                              [UIImage imageNamed:@"chemistry"],
                              [UIImage imageNamed:@"drawing"],
                              [UIImage imageNamed:@"geography"],
                              [UIImage imageNamed:@"geometry"],
                              [UIImage imageNamed:@"history"],
                              [UIImage imageNamed:@"informatics"],
                              [UIImage imageNamed:@"music"],
                              [UIImage imageNamed:@"Phisycs"], nil];
    
    self.collectionView.delegate=self;
    self.collectionView.dataSource=self;
    
    self.collectionView.scrollEnabled = NO;

}
@end
