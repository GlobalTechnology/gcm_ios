//
//  EkkoLoginViewController.m
//  Ekko
//
//  Created by Brian Zoetewey on 11/15/13.
//  Copyright (c) 2013 Ekko Project. All rights reserved.
//

#import "GMALoginViewController.h"



@interface GMALoginViewController ()

@end

@implementation GMALoginViewController

+(NSString *)authNibName {
    return @"GMALoginViewController";
}

-(void)viewWillAppear:(BOOL)animated {
    self.webView.backgroundColor = [UIColor lightGrayColor];
    [super viewWillAppear:animated];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
   }

@end
