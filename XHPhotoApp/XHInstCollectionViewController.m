//
//  XHInstCollectionViewController.m
//  XHPhotoApp
//
//  Created by Henry Huang on 2/1/16.
//  Copyright © 2016 XiaoHuang. All rights reserved.
//

#import "XHInstCollectionViewController.h"
#import "XHInstCollectionViewCell.h"
#import "XHDetailViewController.h"

#import <SimpleAuth/SimpleAuth.h>

@interface XHInstCollectionViewController ()

@property (nonatomic) NSString *accessToken;
@property (nonatomic) NSArray *photos;
@property (nonatomic) UIImage *detailImage;

@end

@implementation XHInstCollectionViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    CGFloat width = CGRectGetWidth(self.collectionView.frame) / 3;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.collectionViewLayout;
    layout.itemSize = CGSizeMake(width, width);
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"Instagram";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshHandler)];
    
    SimpleAuth.configuration[@"instagram"] = @{
                                               @"client_id" : @"bb4bd9c36580497faddaf05947099f44",
                                               SimpleAuthRedirectURIKey : @"xhphotoapp://auth/instagram"
                                               };
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.accessToken = [userDefaults objectForKey:@"accessToken"];
    
    if (self.accessToken == nil) {
        [SimpleAuth authorize:@"instagram" completion:^(NSDictionary *responseObject, NSError *error) {
            // store access token (could be improved with keychain)
            NSString *accessToken = responseObject[@"credentials"][@"token"];
            [userDefaults setObject:accessToken forKey:@"accessToken"];
            [userDefaults synchronize];
        }];
    } else {
        [self refresh];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.photos count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XHInstCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"instCell" forIndexPath:indexPath];
    cell.photo = self.photos[indexPath.item];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSURL *url = [[NSURL alloc] initWithString:self.photos[indexPath.item][@"images"][@"standard_resolution"][@"url"]];
    [self downloadPhotoWithURL:url using:^{
        [self performSegueWithIdentifier:@"instDetailSegue" sender:self];
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[XHDetailViewController class]]) {
        XHDetailViewController *detailViewController = segue.destinationViewController;
        detailViewController.image = self.detailImage;
        
    }
}

#pragma mark - Helper

- (void)refresh {
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *urlString = [[NSString alloc] initWithFormat:@"https://api.instagram.com/v1/users/self/media/recent/?access_token=%@", self.accessToken];
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
        NSData *data = [[NSData alloc] initWithContentsOfURL:location];
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        self.photos = [responseDictionary valueForKeyPath:@"data"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }];
    
    [task resume];
}

- (void)downloadPhotoWithURL:(NSURL *)url using:(void(^)(void))completionHandler {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
   
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        NSData *data = [[NSData alloc] initWithContentsOfURL:location];
        UIImage *image = [[UIImage alloc] initWithData:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.detailImage = image;
            completionHandler();
        });
    }];
    
    [task resume];
}

#pragma mark - Handler

- (void)refreshHandler {
    [self refresh];
}

@end
