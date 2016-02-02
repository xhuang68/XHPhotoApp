//
//  XHInstCollectionViewCell.m
//  XHPhotoApp
//
//  Created by Henry Huang on 2/1/16.
//  Copyright © 2016 XiaoHuang. All rights reserved.
//

#import "XHInstCollectionViewCell.h"

@implementation XHInstCollectionViewCell

- (void)setPhoto:(NSDictionary *)photo {
    _photo = photo;
    
    NSURL *url = [[NSURL alloc] initWithString:_photo[@"images"][@"thumbnail"][@"url"]];
    [self downloadPhotoWithURL:url];
}

- (void)downloadPhotoWithURL:(NSURL *)url {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        NSData *data = [[NSData alloc] initWithContentsOfURL:location];
        UIImage *image = [[UIImage alloc] initWithData:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = image;
        });
    }];
    [task resume];
}

@end
