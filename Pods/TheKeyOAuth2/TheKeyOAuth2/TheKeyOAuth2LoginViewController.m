//
//  TheKeyOAuth2LoginViewController.m
//  TheKeyOAuth2
//
//  Created by Brian Zoetewey on 11/19/13.
//  Copyright (c) 2013 TheKey. All rights reserved.
//

#import "TheKeyOAuth2LoginViewController.h"

@interface TheKeyOAuth2LoginViewController ()

@end

@implementation TheKeyOAuth2LoginViewController

-(IBAction)dismissLoginViewController:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
