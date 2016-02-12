//
//  TheKeyOAuth2Client.h
//  TheKeyGTM
//
//  Created by Brian Zoetewey on 11/14/13.
//  Copyright (c) 2013 Ekko Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TheKeyOAuth2LoginViewController.h"

@protocol TheKeyOAuth2ClientLoginDelegate;

/* TheKey Notifications */
FOUNDATION_EXPORT NSString *const TheKeyOAuth2ClientDidChangeGuidNotification;
FOUNDATION_EXPORT NSString *const TheKeyOAuth2ClientGuidKey;

/* TheKey Guest GUID */
FOUNDATION_EXPORT NSString *const TheKeyOAuth2GuestGUID;

@interface TheKeyOAuth2Client : NSObject

+(TheKeyOAuth2Client *)sharedOAuth2Client;

-(id)init;
-(void)setServerURL:(NSURL *)serverURL clientId:(NSString *)clientId;

-(NSString *)guid;

-(BOOL)isAuthenticated;

-(void)logout;

-(TheKeyOAuth2LoginViewController *)loginViewControllerWithLoginDelegate:(id<TheKeyOAuth2ClientLoginDelegate>)delegate;
-(TheKeyOAuth2LoginViewController *)loginViewController:(Class)loginViewControllerClass loginDelegate:(id<TheKeyOAuth2ClientLoginDelegate>)delegate;

-(void)presentLoginViewControllerFromViewController:(UIViewController *)viewController loginDelegate:(id<TheKeyOAuth2ClientLoginDelegate>)delegate;
-(void)presentLoginViewController:(Class)loginViewControllerClass fromViewController:(UIViewController *)viewController loginDelegate:(id<TheKeyOAuth2ClientLoginDelegate>)delegate;

-(void)ticketForServiceURL:(NSURL *)service complete:(void (^)(NSString *ticket))complete;

@end

@protocol TheKeyOAuth2ClientLoginDelegate <NSObject>
@optional
-(void)loginViewController:(TheKeyOAuth2LoginViewController *)loginViewController loginSuccess:(NSString *)guid;
-(void)loginViewController:(TheKeyOAuth2LoginViewController *)loginViewController loginError:(NSError *)error;
@end