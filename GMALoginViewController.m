//
//  EkkoLoginViewController.m
//  Ekko
//
//  Created by Brian Zoetewey on 11/15/13.
//  Copyright (c) 2013 Ekko Project. All rights reserved.
//

#import "GMALoginViewController.h"
#import <GAI.h>
#import <GAITrackedViewController.h>
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface GMALoginViewController ()

@end

@implementation GMALoginViewController

+(NSString *)authNibName {
    return @"GMALoginViewController";
}

-(void)viewWillAppear:(BOOL)animated {
    self.webView.backgroundColor = [UIColor lightGrayColor];
    [super viewWillAppear:animated];
    
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:   kGAIScreenName value:@"login"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
   }

@end
