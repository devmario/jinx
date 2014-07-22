//
//  STSTActivityIndicatorView.h
//  STST
//
//  Created by Jeong YunWon on 13. 5. 26..
//  Copyright (c) 2013년 vanillabreeze. All rights reserved.
//

#import <UIKitExtension/UIKitExtension.h>

@interface STSTActivityIndicatorView : UIAView

@property(nonatomic, readonly) NSUInteger pushedCount;

- (void)pushAnimated:(BOOL)animated;
- (void)popAnimated:(BOOL)animated;

@end
