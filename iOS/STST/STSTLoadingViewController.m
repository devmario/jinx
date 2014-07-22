//
//  STSTLoadingViewController.m
//  STST
//
//  Created by 이 춘원 on 13. 5. 21..
//  Copyright (c) 2013년 vanillabreeze. All rights reserved.
//

#import "STSTLoadingViewController.h"

@interface STSTLoadingViewController ()

@end

@implementation STSTLoadingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(viewDidWaited) userInfo:nil repeats:NO];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidWaited {
    self.timer = nil;
    [self markLoaded];
}

- (void)viewPrepareAppear:(BOOL)animated {
    [super viewPrepareAppear:animated];

    id appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate runAction];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if (self.timer.isValid) {
        [self.timer invalidate];
        [self.activityIndicatorView popAnimated:YES];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)headerViewHeight {
    return 400.0;
}

- (BOOL)titleHidden {
    return NO;
}

- (BOOL)backButtonHidden {
	return YES;
}

@end
