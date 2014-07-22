//
//  STSTViewController.h
//  STST
//
//  Created by Jeong YunWon on 13. 5. 24..
//  Copyright (c) 2013년 vanillabreeze. All rights reserved.
//

#import <UIKitExtension/UIKitExtension.h>

#import "STSTHeader.h"
#import "STSTActivityIndicatorView.h"

@protocol STSTNavigationViewControllerDelegate

@property (nonatomic, readonly) CGFloat headerViewHeight;
@property (nonatomic, readonly) BOOL titleHidden;
@property (nonatomic, readonly) BOOL backButtonHidden;

@end

@class STSTViewController;
@interface STSTNavigationViewController : UINavigationController

@property (nonatomic, assign) STSTHeader *headerView;
@property (nonatomic, readonly) UIView *headerOverlayView;
- (void)redrawHeader:(STSTViewController *)viewController animation:(BOOL)animation;

@end


@class STSTActivityIndicatorView;
@interface STSTViewController : UIAViewController<STSTNavigationViewControllerDelegate> {
    @protected
    BOOL _animated;
}

@property(nonatomic, readonly) STSTNavigationViewController *gameNavigationController;
@property (nonatomic, readonly) STSTHeader *headerView;
@property (nonatomic, readonly) STSTActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) IBOutlet UIView *headerOverlayView;
@property(nonatomic, readonly) BOOL loaded, animated;

- (void)pushViewController:(STSTViewController*)viewController;

- (void)markLoaded;
- (void)bounce;

- (void)viewPrepareAppear:(BOOL)animated;
- (void)viewPrepareDisappear:(BOOL)animated;
- (void)popViewControllerAnimated:(BOOL)animated;

@end

UIImage *STSTCellImage(UIImage *image, BOOL highlight);
