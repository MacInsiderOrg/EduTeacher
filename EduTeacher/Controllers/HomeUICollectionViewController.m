//
//  HomeUICollectionViewController.m
//  EduTeacher
//
//  Created by Bohdan Savych on 1/29/16.
//  Copyright © 2016 Andrew Kochulab. All rights reserved.
//

#import "HomeUICollectionViewController.h"



@implementation HomeUICollectionViewController


-(void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareColectionView];
    
}

-(void)viewWillAppear:(BOOL)animated
{
   //[[self navigationController] setNavigationBarHidden:YES animated:YES];
}
-(void)viewDidDisappear:(BOOL)animated
{
    //[[self navigationController] setNavigationBarHidden:NO animated:YES];
}
- (void) prepareColectionView {
    self.collectionView.delegate=self;
    self.collectionView.dataSource=self;
    self.collectionView.scrollEnabled = NO;

    self.topicsNamesArray=@[@"Create class",@"Notes",@"Library",@"Additional"];
    self.backGroundsColorsArray=@[[UIColor colorWithRed:1.f
                                                  green:0.858f
                                                   blue:0.251f
                                                  alpha:1.f],
                                  [UIColor colorWithRed:0.380f
                                                  green:0.941f
                                                   blue:0.380f
                                                  alpha:1.f],
                                  [UIColor colorWithRed:0.368f
                                                  green:0.937f
                                                   blue:1.f
                                                  alpha:1.f],
                                  [UIColor colorWithRed:1.f
                                                  green:0.482f
                                                   blue:0.478f
                                                  alpha:1.f],
                                  ];
    
    self.backgroundImageArray = [NSArray arrayWithObjects:
                                 [UIImage imageNamed: @"createClass"],
                                 [UIImage imageNamed: @"notes"],
                                 [UIImage imageNamed: @"library"],
                                 [UIImage imageNamed: @"additional"],
                                 nil];
}

#pragma mark-UICollectionViewDataSource

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.topicsNamesArray count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HomeCollectionViewCell* homeColectionCell=[collectionView dequeueReusableCellWithReuseIdentifier:@"homeCellIdentifier" forIndexPath:indexPath];
    homeColectionCell.topicName.text = [self.topicsNamesArray objectAtIndex:indexPath.row];
    homeColectionCell.topicImage.image = [self.backgroundImageArray objectAtIndex:indexPath.row];
    homeColectionCell.topicImage.contentMode = UIViewContentModeCenter;
    homeColectionCell.backgroundColor=[self.backGroundsColorsArray objectAtIndex:indexPath.row];
    homeColectionCell.tag = indexPath.row;
    return homeColectionCell;
}

#pragma mark -UICollectionViewDelegateFlowLayout

- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self.collectionViewLayout invalidateLayout];
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = CGRectGetWidth(collectionView.frame)/2;
    CGFloat height = (CGRectGetHeight(collectionView.frame)- [UIApplication sharedApplication].statusBarFrame.size.height - self.navigationController.navigationBar.frame.size.height)/2;
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

#pragma mark - Colection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *segueIdentifiers = @[@"createClassSegueIdentifier",
                                  @"chooseSubjectSegueIdentifier",
                                  @"chooseSubjectSegueIdentifier",
                                  @"chooseSubjectSegueIdentifier"];
    [self performSegueWithIdentifier:[segueIdentifiers objectAtIndex:indexPath.row] sender:indexPath];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"Current tag: %ld",(long)[sender row]);
    }
@end


