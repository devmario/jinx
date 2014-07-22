//
//  STSTViewController.m
//  STST
//
//  Created by Jeong YunWon on 13. 5. 24..
//  Copyright (c) 2013년 vanillabreeze. All rights reserved.
//

#import "STSTViewController.h"
#import "STSTHeader.h"

@implementation STSTNavigationViewController

- (void)redrawHeader:(STSTViewController *)viewController animation:(BOOL)animation {
    CGFloat newHeight = viewController.headerViewHeight;
    BOOL needHeader = self.headerView.frame.size.height != newHeight;

    if (needHeader) {
        self.headerView.bouncing = NO;
    }

    CGRect headerFrame = self.headerView.frame;
    headerFrame.size.height = newHeight;

    CGFloat diff = newHeight - self.headerView.frame.size.height;

    BOOL needTitle = self.headerView.titleView.hidden != viewController.titleHidden;
    if (needTitle && !viewController.titleHidden) {
        CGRect frame = self.headerView.titleGuide.frame;
        frame.origin.y = -self.headerView.frame.size.height;
        self.headerView.titleView.frame = frame;
        self.headerView.titleView.hidden = NO;
    }

    CGRect backFrame = self.headerView.backButton.frame;
    if (viewController.backButtonHidden) {
        backFrame.origin.y = -50.0;
    } else {
        backFrame.origin.y = (newHeight - 57.0) / 3;
    }
    CGFloat backDiff = backFrame.origin.y - self.headerView.backButton.frame.origin.y;
    BOOL needBack = backDiff != .0;

    UIView *newOverlayView = viewController.headerOverlayView;
    if (newOverlayView) {
        CGRect frame = newOverlayView.frame;
        frame.origin.y = -frame.size.height;
        newOverlayView.frame = frame;
        [self.headerView insertSubview:newOverlayView belowSubview:self.headerView.backButton];
    }

    [UIView animateWithDuration:UIAViewAnimationDefaultDuraton * 0.5 delay:.0 options:0  animations:^(void) {
        CGRect frame = self.headerView.frame;
        if (needHeader) {
            frame.size.height -= diff * 0.2;
            self.headerView.frame = frame;
        }
        if (self->_headerOverlayView) {
            self->_headerOverlayView.frame = frame;
        }
        if (needTitle && viewController.titleHidden) {
            frame = self.headerView.titleGuide.frame;
            frame.origin.y *= 1.2;
            self.headerView.titleView.frame = frame;
        }
        if (newOverlayView) {
            newOverlayView.frame = frame;
        }
        if (needBack) {
            frame = self.headerView.backButton.frame;
            frame.origin.y -= backDiff * 0.2;
            self.headerView.backButton.frame = frame;
        }
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:UIAViewAnimationDefaultDuraton animations:^(void) {
            CGRect frame = headerFrame;
            if (needHeader) {
                frame.size.height += diff * 0.2;
                self.headerView.frame = frame;
            }
            if (newOverlayView) {
                newOverlayView.frame = frame;
            }
            if (needTitle) {
                frame = self.headerView.titleGuide.frame;
                if (viewController.titleHidden) {
                    frame.origin.y = -self.headerView.frame.size.height;
                } else {
                    frame.origin.y *= 1.2;
                }
                self.headerView.titleView.frame = frame;
            }
            if (self->_headerOverlayView) {
                frame = self->_headerOverlayView.frame;
                frame.origin.y = -frame.size.height;
                self->_headerOverlayView.frame = frame;
            }
            if (needBack) {
                frame = backFrame;
                frame.origin.y += backDiff * 0.2;
                self.headerView.backButton.frame = frame;
            }

        } completion:^(BOOL finished) {
            [UIView animateWithDuration:UIAViewAnimationDefaultDuraton * 0.5 animations:^(void) {
                if (needHeader) {
                    self.headerView.frame = headerFrame;
                }
                if (self->_headerOverlayView) {
                    [self->_headerOverlayView removeFromSuperview];
                    self->_headerOverlayView = nil;
                }
                if (newOverlayView) {
                    newOverlayView.frame = headerFrame;
                    self->_headerOverlayView = newOverlayView;
                }
                if (needTitle && !viewController.titleHidden) {
                    self.headerView.titleView.frame = self.headerView.titleGuide.frame;
                }
                if (needBack) {
                    self.headerView.backButton.frame = backFrame;
                }
            } completion:^(BOOL finished) {
                if (needTitle && viewController.titleHidden) {
                    self.headerView.titleView.hidden = YES;
                    self.headerView.titleView.frame = self.headerView.titleGuide.frame;
                }
                if (needHeader) {
                    self.headerView.bouncing = [[[NSUserDefaults standardUserDefaults] objectForKey:@"STSTHeaderBounce"] boolValue];
                }
            }];

        }];
    }];
}

@end


@implementation STSTViewController

- (void)pushViewController:(STSTViewController*)viewController {
    [self viewPrepareDisappear:YES];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(UIAViewAnimationDefaultDuraton * 0.3 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.navigationController pushViewController:viewController animated:YES];
    });
}

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

//    STSTHeader *header = [STSTHeader header];
//    header.viewController = self;
//    header.frame = self.headerContainer.bounds;
//    [self.headerContainer insertSubview:header atIndex:0];

	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [((STSTNavigationViewController *)self.navigationController) redrawHeader:self animation:animated];
}

- (STSTActivityIndicatorView *)activityIndicatorView {
    return [(id)[[UIApplication sharedApplication] delegate] activityIndicatorView];
}

- (STSTHeader *)headerView {
    return ((STSTNavigationViewController *)self.navigationController).headerView;
}

- (CGFloat)headerViewHeight {
    return 105.0;
}

- (BOOL)backButtonHidden {
    return [self.navigationController.viewControllers :0] == self;
}

- (BOOL)titleHidden {
    return [self.navigationController.viewControllers :0] == self;
}

- (STSTNavigationViewController *)gameNavigationController {
    return (id)self.navigationController;
}

- (void)markLoaded {
    self->_loaded = YES;
    [self viewPrepareAppear:YES];
    [self.activityIndicatorView popAnimated:YES];
}

- (void)viewPrepareAppear:(BOOL)animated {
    
}

- (void)viewPrepareDisappear:(BOOL)animated {
    
}

- (void)popViewControllerAnimated:(BOOL)animated {
    [self viewPrepareDisappear:animated];
    if (animated) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(UIAViewAnimationDefaultDuraton * 0.3 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
           [self.gameNavigationController popViewControllerAnimated:YES];
        });
    } else {
       [self.gameNavigationController popViewControllerAnimated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    self->_loaded = NO;
    [self.activityIndicatorView pushAnimated:YES];
}

- (void)bounce {
    
}

@end

#define margin 8.0
#define size 34.0

UIImage *STSTCellImage(UIImage *image, BOOL highlight) {
    UIImage *mask = [UIImage imageNamed:[@"picture_up%@" format:highlight ? @"_on" : @""]];
    
    UIGraphicsBeginImageContext(CGSizeMake(margin + size, size));
    [image drawInRect:CGRectMake(margin, .0, size, size)];
    [mask drawInRect:CGRectMake(margin, .0, size, size)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}
