//
//  XHPhotoLibrary.m
//  XHPhotoApp
//
//  Created by Henry Huang on 1/31/16.
//  Copyright © 2016 XiaoHuang. All rights reserved.
//

#import "XHPhotoLibrary.h"

@import Photos;

@interface XHPhotoLibrary()
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) PHFetchResult *allPhotosFetchResult;
@end

@implementation XHPhotoLibrary

- (id)init
{
    self = [super init];
    if (self) {
        self.imageManager = [[PHCachingImageManager alloc] init];
    }
    return self;
}

- (NSInteger)imageCount
{
    return [self.allPhotosFetchResult count];
}


- (void)loadCameraRollWithSuccess:(void(^)(void))successBlock
                     Unauthorized:(void(^)(void))unauthorizedBlock {
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied ||
        [PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusRestricted) {
        unauthorizedBlock();
    } else {
        PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
        allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        self.allPhotosFetchResult = [PHAsset fetchAssetsWithOptions:allPhotosOptions];
        successBlock();
    }
}

- (void)thumbAtIndex:(NSInteger)index thumbSize:(CGSize)thumbSize completionHandler:(void(^)(UIImage *thumb))completionHandler {
    PHAsset *asset = self.allPhotosFetchResult[index];
    [self.imageManager requestImageForAsset:asset targetSize:thumbSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage *result, NSDictionary *info) {
        completionHandler(result);
    }];
}

- (void)imageAtIndex:(NSInteger)index completionHandler:(void(^)(UIImage *image))completionHandler {
    PHAsset *asset = self.allPhotosFetchResult[index];
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.networkAccessAllowed = YES;
    [self.imageManager requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        completionHandler(result);
    }];
}

- (void) resetCache {
    [self.imageManager stopCachingImagesForAllAssets];
}

- (void) updateCacheStartWith:(NSMutableArray *)addedIndexPaths stopWith:(NSMutableArray *)removedIndexPaths inSize:(CGSize)size {
    
    NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
    NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
    
    [self.imageManager startCachingImagesForAssets:assetsToStartCaching
                                        targetSize:size
                                       contentMode:PHImageContentModeAspectFill
                                           options:nil];
    [self.imageManager stopCachingImagesForAssets:assetsToStopCaching
                                       targetSize:size
                                      contentMode:PHImageContentModeAspectFill
                                          options:nil];
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths {
    if (indexPaths.count == 0) { return nil; }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        PHAsset *asset = self.allPhotosFetchResult[indexPath.item];
        [assets addObject:asset];
    }
    
    return assets;
}

@end
