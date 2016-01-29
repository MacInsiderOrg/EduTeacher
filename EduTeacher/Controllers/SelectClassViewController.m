//
//  SelectClassViewController.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 29.01.16.
//  Copyright © 2016 Andrew Kochulab. All rights reserved.
//

#import "SelectClassViewController.h"

@interface ClassNumberViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel* classNumber;

@end

@implementation ClassNumberViewCell

@end


@implementation SelectClassViewController

#pragma mark - UIViewController methods

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    self.classNumbers = [NSMutableArray array];

    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 4; j++) {
            
            UIColor* backgroundColor = ((i + j) % 2 == 0) ? [UIColor whiteColor] : [UIColor colorWithRed: .843f green: .843f blue: .863f alpha: 1.f];
            
            [self.classNumbers addObject: backgroundColor];
        }
    }
}

- (void) didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [self.collectionViewLayout invalidateLayout];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //
}

#pragma mark - UICollectionViewDelegate methods

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return [self.classNumbers count];
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ClassNumberViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SelectClassCollectionViewCell" forIndexPath: indexPath];
    
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

@end
