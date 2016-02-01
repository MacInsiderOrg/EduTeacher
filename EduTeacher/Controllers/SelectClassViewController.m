//
//  SelectClassViewController.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 29.01.16.
//  Copyright © 2016 Andrew Kochulab. All rights reserved.
//

#import "SelectClassViewController.h"
#import "ChooseClassCollectionViewCell.h"

@implementation SelectClassViewController

#pragma mark - UIViewController methods

- (void) viewDidLoad {
    [super viewDidLoad];
    [self setBackgroundColor];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) setBackgroundColor {
    self.classNumbers = [NSMutableArray array];
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 4; j++) {
            UIColor* backgroundColor = ((i + j) % 2 == 0) ? [UIColor whiteColor] : [UIColor colorWithRed: .843f green: .843f blue: .863f alpha: 1.f];
            [self.classNumbers addObject: backgroundColor];
        }
    }
}

- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self.collectionViewLayout invalidateLayout];
}

#pragma mark - UICollectionViewDelegate methods

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.classNumbers count];
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ChooseClassCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"classCell" forIndexPath: indexPath];
    cell.backgroundColor = [self.classNumbers objectAtIndex: indexPath.row];
    cell.classNumber.text = [NSString stringWithFormat: @"%d", (indexPath.row + 1)];
    return cell;
}

#pragma mark - Layout Collection View

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CGFloat width = CGRectGetWidth(collectionView.frame) / 4;
    CGFloat height = CGRectGetHeight(collectionView.frame) / 3;
    return CGSizeMake(width, height);
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.f;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.f;
}

- (UIEdgeInsets) collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0.f, 0.f, 0.f, 0.f);
}

#pragma mark - Select Item in Collection View

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    [self performSegueWithIdentifier: @"ChooseFileIdentifier" sender: indexPath];
    
    /*if (indexPath.row == 3) {
        [self performSegueWithIdentifier: @"OpenQuizesIdentifier" sender: indexPath];
    } else {
        [self performSegueWithIdentifier: @"ChooseFileIdentifier" sender: indexPath];
    }*/
}

@end