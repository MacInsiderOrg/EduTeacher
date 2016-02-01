//
//  ChooseFileViewController.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 31.01.16.
//  Copyright © 2016 Andrew Kochulab. All rights reserved.
//

#import "ChooseFileViewController.h"
#import "PDFDocumentViewController.h"
#import "PDFDocument.h"
#import "CategoryUICollectionViewCell.h"
@interface ChooseFileViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) NSArray* documentsNames;
@property (weak, nonatomic) IBOutlet UICollectionView *categoryCollectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *documentSearchBar;
@property (weak, nonatomic) IBOutlet UITableView *documentsTableView;
@property(strong,nonatomic)NSArray* namesArray;
@property(assign,nonatomic)NSInteger categoryIdent;
@end


@implementation ChooseFileViewController

#pragma mark - UIViewController methods


- (void) viewDidLoad {
    [super viewDidLoad];
    [self prepareView];
}

#pragma mark - Open Document

- (void) openDocument:(NSString *)filePath {
    
    NSString* password = nil;
    
    // Init PDF document by file path
    PDFDocument* document = [PDFDocument withDocumentFilePath:filePath password:password];
    
    if (document != nil) {
        
        // Init PDFDocument VC with initial PDFDocument
        PDFDocumentViewController* pdfDocumentViewController = [[PDFDocumentViewController alloc] initWithPDFDocument: document];
        
        // Push to drawing VC
        [self.navigationController pushViewController: pdfDocumentViewController animated: YES];
        
    } else {
        NSLog(@"PDFDocument.withDocumentFilePath failed...");
    }
}
#pragma mark-private methods
- (NSArray *) getDocumentsNames {
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex: 0];
    NSError* error = nil;
    
    NSArray* extensionList = [NSArray arrayWithObjects: @"pdf", @"ppt", @"pptx", nil];
    
    NSArray* fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: documentsDirectory error: &error];
    
    NSMutableArray* documentsNames = [NSMutableArray array];
    
    for(NSString* filepath in fileList) {
        
        if ([extensionList containsObject: [filepath pathExtension]]) {
            
            // Found Document with format from extensionList
            [documentsNames addObject: filepath];
        }
    }
    
    return documentsNames;
}
-(void)prepareView
{
    self.categoryCollectionView.delegate=self;
    self.categoryCollectionView.dataSource=self;
    self.documentsTableView.dataSource=self;
    self.documentsTableView.delegate=self;
    
    self.documentsNames = [self getDocumentsNames];// Get documents names
    self.categoryCollectionView.scrollEnabled=NO;
    NSLog(@"Lisf of Documents: %@", self.documentsNames);
    self.namesArray=@[@"Documents",@"Notes"];

}

#pragma mark-UICollectioViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.namesArray count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryUICollectionViewCell* cell=[self.categoryCollectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    cell.nameLabel.text=[self.namesArray objectAtIndex:indexPath.row];
    if(indexPath.row%2==0)
    {
        cell.statusView.backgroundColor=[UIColor cyanColor];
    }
    else
    {
        cell.statusView.backgroundColor=cell.backgroundColor;
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* oldIndexPath;
    if(self.categoryIdent!=indexPath.row)
    {
        oldIndexPath=[NSIndexPath indexPathForRow:self.categoryIdent inSection:indexPath.section];
        CategoryUICollectionViewCell* oldCell=(CategoryUICollectionViewCell*)[collectionView cellForItemAtIndexPath:oldIndexPath];
        [[(CategoryUICollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath] statusView ] setBackgroundColor:oldCell.statusView.backgroundColor];
        oldCell.statusView.backgroundColor=oldCell.backgroundColor;
        self.categoryIdent=indexPath.row;
        [self.documentsTableView reloadData];
        
    }
    NSLog(@"%ld",(long)self.categoryIdent);
}
//update layout when it become ivnalied

- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self.categoryCollectionView reloadData];
}


// Layout: Set cell size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    double height = self.categoryCollectionView.bounds.size.height;
    double width = self.categoryCollectionView.bounds.size.width/2;
    CGSize mElementSize = CGSizeMake(width,height);
    return mElementSize;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

// Layout: Set Edges
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(0,0,0,0);  // top, left, bottom, right
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.documentsNames count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* ident=@"tableCellIdentifier";
 
    UITableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:ident];
    if(!cell)
    {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ident];
    }
    NSString* extension=[[self.documentsNames objectAtIndex:indexPath.row] pathExtension];
    if([extension isEqualToString:@"pdf"])
    {
         [cell.imageView setImage:[UIImage imageNamed:extension]];
    }
    else if ([extension isEqualToString:@"ppt"])
    {
        [cell.imageView setImage:[UIImage imageNamed:extension]];
    }
    else if([extension isEqualToString:@"pptx"])
    {
        [cell.imageView setImage:[UIImage imageNamed:extension]];
    }
    //we need this if-tree bc user can upload other format 
    cell.textLabel.text=[self.documentsNames objectAtIndex:indexPath.row];//need other array for notes
    return cell;
}
#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.documentsTableView.bounds.size.height/6;//6 documents on ecran??
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.documentsNames != nil)
    {
        NSString* filePath = [[NSHomeDirectory() stringByAppendingPathComponent: @"Documents"] stringByAppendingPathComponent: [self.documentsNames objectAtIndex:indexPath.row]];
        
        [self openDocument: filePath];
    }
    [self.documentsTableView deselectRowAtIndexPath:indexPath animated:YES];

}
@end