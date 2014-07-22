//
//  STSTAppDelegate.h
//  STST
//
//  Created by 이 춘원 on 13. 5. 20..
//  Copyright (c) 2013년 vanillabreeze. All rights reserved.
//

#import <UIKitExtension/UIKitExtension.h>

@class STSTViewController;
@class STSTNavigationViewController;
@class STSTActivityIndicatorView;
@interface STSTAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, readonly) STSTNavigationViewController *navigationController;
@property (strong, readonly) STSTViewController *viewController;
@property (retain, nonatomic) NSDictionary *receivedData;
@property (retain, nonatomic) STSTActivityIndicatorView *activityIndicatorView;

- (void)sendUserInfo;
- (void)updateLobby;
- (void)updateGame:(NSString *)gameId;

@end