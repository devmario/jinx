//
//  STSTIntroViewController.h
//  STST
//
//  Created by 이 춘원 on 13. 5. 20..
//  Copyright (c) 2013년 vanillabreeze. All rights reserved.
//

#import <UIKitExtension/UIKitExtension.h>
#import "STSTViewController.h"

@protocol STSTIntroViewControllerDelegate;

@interface STSTIntroViewController : STSTViewController {
@private
    id<STSTIntroViewControllerDelegate> __unsafe_unretained _delegate;
    BOOL bProgressLogin;
}
@property (nonatomic, assign) __unsafe_unretained id<STSTIntroViewControllerDelegate> delegate;

@end

@protocol STSTIntroViewControllerDelegate <NSObject>
@required
- (void)authLoginViewControllerdidFinishLogin:(STSTIntroViewController *)authLoginViewController;
@end