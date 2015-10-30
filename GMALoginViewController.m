//
//  EkkoLoginViewController.m
//  Ekko
//
//  Created by Brian Zoetewey on 11/15/13.
//  Copyright (c) 2013 Ekko Project. All rights reserved.
//

#import "GMALoginViewController.h"

@interface GMALoginViewController (){
    
}
@end

@implementation GMALoginViewController

+(NSString *)authNibName {
    return @"GMALoginViewController";
}

-(void)viewWillAppear:(BOOL)animated {
    
    self.webView.backgroundColor = [UIColor lightGrayColor];
    [super viewWillAppear:animated];
    
    UIView *statusBarView =  [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 20)];
    statusBarView.backgroundColor  =  [UIColor colorWithRed:91.0/255.0 green:183.0/255.0 blue:56.0/255.0 alpha:1.0];
    [self.view addSubview:statusBarView];
    
        //set the constraints to auto-resize
    statusBarView.translatesAutoresizingMaskIntoConstraints = NO;
    [statusBarView.superview addConstraint:[NSLayoutConstraint constraintWithItem:statusBarView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:statusBarView.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [statusBarView.superview addConstraint:[NSLayoutConstraint constraintWithItem:statusBarView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:statusBarView.superview attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    [statusBarView.superview addConstraint:[NSLayoutConstraint constraintWithItem:statusBarView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:statusBarView.superview attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    [statusBarView.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[statusBarView(==20)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(statusBarView)]];
    [statusBarView.superview setNeedsUpdateConstraints];
    
    
        // UIApplication.sharedApplication().statusBarStyle = .LightContent
   
        // [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    
    self.webView.delegate = self;
    
//    id tracker = [[GAI sharedInstance] defaultTracker];
//    [tracker set:  kGAIScreenName value:@"login"];
//    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}



#pragma mark - web view delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
        // [loadingView setHidden:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            // Do something...
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    //[loadingView setHidden:NO];
    
    MBProgressHUD *loader = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    loader.mode = MBProgressHUDModeIndeterminate;
    loader.color = [UIColor colorWithRed:13.0/255.0 green:25.0/255.0 blue:49.0/255.0 alpha:1.0];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            // Do something...
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

@end
