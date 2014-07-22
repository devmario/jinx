//
//  STSTLoadUserInfoViewController.m
//  STST
//
//  Created by 이 춘원 on 13. 5. 21..
//  Copyright (c) 2013년 vanillabreeze. All rights reserved.
//

#import "STSTLoadUserInfoViewController.h"
#import "STSTAppDelegate.h"

@interface STSTLoadUserInfoViewController ()

@end

@implementation STSTLoadUserInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        STSTAppDelegate *appDelegate = (STSTAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate sendUserInfo];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self markLoaded];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)backButtonHidden {
	return YES;
}

@end
