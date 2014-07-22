//
//  STSTIntroViewController.m
//  STST
//
//  Created by 이 춘원 on 13. 5. 20..
//  Copyright (c) 2013년 vanillabreeze. All rights reserved.
//

#import "STSTIntroViewController.h"
#import "Kakao.h"

#import "STSTAppDelegate.h"

@interface STSTIntroViewController ()

@end

@implementation STSTIntroViewController
@synthesize delegate = _delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - actions

- (IBAction)invokeLoginWithTarget:(id)sender
{
    if( bProgressLogin==YES ) {
        [[KAAuth sharedAuth] cancelRegistration];
    }
    
    bProgressLogin = YES;
    [[KAAuth sharedAuth] registerWithCompletionHandler:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([KAAuth sharedAuth].authenticated) {
                bProgressLogin = NO;
                [_delegate authLoginViewControllerdidFinishLogin:self];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"에러"
                                                                    message:error.localizedDescription
                                                                   delegate:nil
                                                          cancelButtonTitle:@"확인"
                                                          otherButtonTitles:nil];
                [alertView show];
            }
        });
    }];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self markLoaded];
}

- (IBAction)invokeToggleStatusBar:(id)sender
{
    [[UIApplication sharedApplication] setStatusBarHidden:![UIApplication sharedApplication].statusBarHidden withAnimation:YES];
}

- (IBAction)invokeGuestLoginWithTarget:(id)sender
{
    [[KAAuth sharedAuth] guestLoginWithCompletionHandler:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([KAAuth sharedAuth].isGuestLoggedOn)
            {
                [_delegate authLoginViewControllerdidFinishLogin:self];
            }
            else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Guest Login Error"
                                                                    message:error.localizedDescription
                                                                   delegate:nil
                                                          cancelButtonTitle:@"확인"
                                                          otherButtonTitles:nil];
                [alertView show];
            }
        });
    }];
}

- (BOOL)backButtonHidden {
	return YES;
}

@end
