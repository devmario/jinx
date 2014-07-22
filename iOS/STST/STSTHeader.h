//
//  STSTHeader.h
//  STST
//
//  Created by Jeong YunWon on 13. 5. 23..
//  Copyright (c) 2013 vanillabreeze. All rights reserved.
//

#import <UIKitExtension/UIKitExtension.h>

@class STSTNavigationViewController;
@class STSTViewController;

@interface STSTHeader : UIAView

+ (id)header;

@property(nonatomic, assign) STSTNavigationViewController *navigationController;
@property(nonatomic, readonly) STSTViewController *viewController;
@property(nonatomic, retain) IBOutlet UIImageView *backgroundImage;
@property(nonatomic, retain) IBOutlet UIButton *backButton;
@property(nonatomic, retain) IBOutlet UIImageView *titleView;
@property(nonatomic, retain) IBOutlet UIView *titleGuide;


@property(nonatomic, assign) BOOL bouncing;
@property(nonatomic, assign) NSInteger bounceCount;
@property(nonatomic, assign) BOOL bounceFlag;

- (IBAction)popViewController:(id)sender;
- (IBAction)toggleBouncing:(id)sender;

@end
