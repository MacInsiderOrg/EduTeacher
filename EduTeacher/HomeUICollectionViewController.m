//
//  HomeUICollectionViewController.m
//  EduTeacher
//
//  Created by Bohdan Savych on 1/29/16.
//  Copyright © 2016 Andrew Kochulab. All rights reserved.
//

#import "HomeUICollectionViewController.h"
#import "HomeTopicCollectionCell.h"
  static NSString* identifier=@"cellIdentifier";
@implementation HomeUICollectionViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.delegate=self;
    self.collectionView.dataSource=self;
    
    self.topicsNamesArray=@[@"Create class",@"Notes",@"Library",@"Additional"];
    self.backGroundsColorsArray=@[[UIColor colorWithRed:1.f       green:0.858f    blue:0.251f     alpha:1.f],
                                  [UIColor colorWithRed:0.380f    green:0.941f    blue:0.380f     alpha:1.f],
                                  [UIColor colorWithRed:0.368f    green:0.937f    blue:1.f        alpha:1.f],
                                  [UIColor colorWithRed:1.f       green:0.482f    blue:0.478f     alpha:1.f],
                                  ];
    self.collectionView.scrollEnabled=NO;
    
}

#pragma mark-UICollectionViewDataSource

//default=1
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.topicsNamesArray count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  
    HomeTopicCollectionCell* cell=[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
 
    [cell.imageView setImage:[UIImage imageNamed:[self.topicsNamesArray objectAtIndex:indexPath.row]]];
    
    //label
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init] ;
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    NSAttributedString* topicName=[[NSAttributedString alloc]initWithString:[self.topicsNamesArray objectAtIndex:indexPath.row] attributes:@{NSParagraphStyleAttributeName:paragraphStyle,
                          NSFontAttributeName:[UIFont fontWithName:@"Palatino-Roman" size:24.0]}];//set parametrs for att sting
    [cell.topicNameLabel setAttributedText:topicName];
    cell.backgroundColor=[self.backGroundsColorsArray objectAtIndex:indexPath.row];
    return cell;
}
#pragma mark-UICollectionViewDelegateFlowLayout
// Layout: Set cell size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    double height = self.view.bounds.size.height/2;
    double width = self.view.bounds.size.width/2;
    CGSize mElementSize = CGSizeMake(width,height);
    return mElementSize;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(0,0,0,0);  // top, left, bottom, right
}
/*
#pragma mark-private method
-(CGRect)findFrameForImageWithCell:(UICollectionViewCell*)cell
{
    CGFloat imageViewHeight=cell.bounds.size.height/2;
    CGFloat imageViewWidth=cell.bounds.size.width/2;
    return CGRectMake(imageViewWidth/2, imageViewHeight/2, imageViewWidth, imageViewHeight);
    
}
-(CGRect)findFrameForLabelWithCell:(UICollectionViewCell*)cell
{
    CGFloat labelHeight=cell.bounds.size.height/4;
    CGFloat labelWidth=cell.bounds.size.width/2;
    return  CGRectMake(labelWidth/2, labelHeight*3, labelWidth, labelHeight);
}*/

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {

    [self.collectionViewLayout invalidateLayout];
    
}
@end


