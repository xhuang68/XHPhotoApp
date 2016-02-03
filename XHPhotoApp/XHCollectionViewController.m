//
//  XHCollectionViewController.m
//  XHPhotoApp
//
//  Created by Henry Huang on 1/31/16.
//  Copyright © 2016 XiaoHuang. All rights reserved.
//

#import "XHCollectionViewController.h"
#import "XHCollectionViewCell.h"
#import "XHPhotoLibrary.h"
#import "UICollectionView+Convenience.h"
#import "XHDetailViewController.h"

@interface XHCollectionViewController ()

@property (nonatomic, strong) XHPhotoLibrary *photoLibrary;
@property (nonatomic, strong) UIImage *detailImage;
@property CGRect previousPreheatRect;
@end

@implementation XHCollectionViewController

static CGSize thumbSize;

- (void)viewDidLoad {
    self.photoLibrary = [[XHPhotoLibrary alloc] init];
    
    [self.photoLibrary loadCameraRollWithSuccess:^{
        NSLog(@"Successgully load camera roll.");
        [self.collectionView reloadData];
    } Unauthorized:^{
        NSLog(@"Unauthorized: please change privacy settings.");
    }];
    
    [self updateCachedAssets];
    
    CGFloat width = CGRectGetWidth(self.collectionView.frame) / 3;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.collectionViewLayout;
    layout.itemSize = CGSizeMake(width, width);
    thumbSize = layout.itemSize;
    
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"Camera Roll";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshHandler)];
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.photoLibrary imageCount];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XHCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    [self.photoLibrary thumbAtIndex:indexPath.item thumbSize:thumbSize completionHandler:^(UIImage *thumb) {
        cell.cellImageView.image = thumb;
        // NSLog(@"%d, %f, %f",(int)indexPath.item, cell.cellImageView.image.size.height, cell.cellImageView.image.size.width);
    }];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.photoLibrary imageAtIndex:indexPath.item completionHandler:^(UIImage *image) {
        self.detailImage = image;
        // NSLog(@"%@", image.description);
        [self performSegueWithIdentifier:@"detailSegue" sender:self];
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[XHDetailViewController class]]) {
        XHDetailViewController *detailViewController = segue.destinationViewController;
        detailViewController.image = self.detailImage;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Update cached assets for the new visible area.
    [self updateCachedAssets];
}

#pragma mark - Asset Caching

- (void)resetCachedAssets {
    [self.photoLibrary resetCache];
    self.previousPreheatRect = CGRectZero;
}

- (void)updateCachedAssets {
    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
    if (!isViewVisible) {
        return;
    }
    
    // The preheat window is twice the height of the visible rect.
    CGRect preheatRect = self.collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    // Check if the collection view is showing an area that is significantly
    // different to the last preheated area.
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta > CGRectGetHeight(self.collectionView.bounds) / 3.0f) {
        
        // Compute the assets to start caching and to stop caching.
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [self.collectionView xh_indexPathsForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        } addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [self.collectionView xh_indexPathsForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        [self.photoLibrary updateCacheStartWith:addedIndexPaths stopWith:removedIndexPaths inSize:thumbSize];
        
        // Store the preheat rect to compare against in the future.
        self.previousPreheatRect = preheatRect;
    }
}

#pragma mark - Handler

-(void) refreshHandler {
    [self updateCachedAssets];
    [self.collectionView reloadData];
}

#pragma mark - Helper

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler {
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

@end
