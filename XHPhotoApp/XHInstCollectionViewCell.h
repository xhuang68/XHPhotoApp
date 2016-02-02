//
//  XHInstCollectionViewCell.h
//  XHPhotoApp
//
//  Created by Henry Huang on 2/1/16.
//  Copyright © 2016 XiaoHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XHInstCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic) NSDictionary *photo;

@end
