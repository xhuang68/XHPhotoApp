//
//  XHDetailViewController.m
//  XHPhotoApp
//
//  Created by Henry Huang on 1/31/16.
//  Copyright © 2016 XiaoHuang. All rights reserved.
//

#import "XHDetailViewController.h"
#import "XHImageScrollView.h"

@interface XHDetailViewController ()

@property (nonatomic, strong) XHImageScrollView *scrollView;

@end

@implementation XHDetailViewController

static BOOL tapped = false;

- (void)viewDidLoad {
    self.scrollView = [[XHImageScrollView alloc] initWithFrame:self.view.bounds];
    
    [self.scrollView setupSubviewsWithImage:self.image];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.scrollView];
    
    NSDictionary *viewsDictionary = @{@"scrollView": self.scrollView};
    
    NSArray *horzConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[scrollView]|" options:0 metrics:nil views:viewsDictionary];
    [self.view addConstraints:horzConstraints];
    
    NSArray *vertConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|" options:0 metrics:nil views:viewsDictionary];
    [self.view addConstraints:vertConstraints];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    [self.scrollView addGestureRecognizer:gesture];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareTapped)];
}

#pragma mark - Handler

-(void) handleTap {
    if (!tapped) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.scrollView.backgroundColor = [UIColor blackColor];
        } completion:nil];
        tapped = true;
    } else {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.scrollView.backgroundColor = [UIColor whiteColor];
        } completion:nil];
        tapped = false;
    }
}

-(void) shareTapped {
    NSArray *myshare = @[self.image];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:myshare applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:nil];
    
    // NSLog(@"share tapped.");
}

@end
