//
//  XHPhotoLibrary.h
//  XHPhotoApp
//
//  Created by Henry Huang on 1/31/16.
//  Copyright © 2016 XiaoHuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@import Photos;

@interface XHPhotoLibrary : NSObject

// load camera roll photos using blokcs to handle successful or unauthorized situation
- (void)loadCameraRollWithSuccess:(void(^)(void))successBlock
                     Unauthorized:(void(^)(void))unauthorizedBlock;

// load thunbnail at one collectionview index
- (void)thumbAtIndex:(NSInteger)index thumbSize:(CGSize)thumbSize completionHandler:(void(^)(UIImage *thumb))completionHandler;

// load full resolution image at one collectionview index
- (void)imageAtIndex:(NSInteger)index completionHandler:(void(^)(UIImage *image))completionHandler;

// reset image cache manager
- (void) resetCache;

// update image cache image with a new range
- (void) updateCacheStartWith:(NSMutableArray *)addedIndexPaths stopWith:(NSMutableArray *)removedIndexPaths inSize:(CGSize)size;

// return the number of images in the library
- (NSInteger)imageCount;

@end
