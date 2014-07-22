//
//  STSTHeader.m
//  STST
//
//  Created by Jeong YunWon on 13. 5. 23..
//  Copyright (c) 2013 vanillabreeze. All rights reserved.
//

#import "STSTHeader.h"
#import "STSTViewController.h"

@interface STSTHeader ()

@end

@implementation STSTHeader

+ (id)header {
    return [[[self alloc] initWithPlatformSuffixedNibName:@"STSTHeader" bundle:nil] autorelease];
}

- (STSTViewController *)viewController {
    return (id)self.navigationController.topViewController;
}

- (void)popViewController:(id)sender {
    [self.viewController popViewControllerAnimated:YES];
}

- (void)bounce {
    if (self.bounceFlag) return;

    self.bounceFlag = YES;
    self.bounceCount += 1;
    CGRect titleFrame = self.titleView.frame;
    [UIView animateWithDuration:UIAViewAnimationDefaultDuraton * 0.5 delay:.0 options:UIViewAnimationOptionCurveEaseIn animations:^(void) {
        CGFloat scale = self.bounceCount % 4 == 0 ? 0.18 : 0.09;
        CGRect frame = titleFrame;
        frame.origin.x -= titleFrame.size.width * scale;
        frame.origin.y -= titleFrame.size.height * scale;
        frame.size.width += titleFrame.size.width * scale * 2;
        frame.size.height += titleFrame.size.height * scale * 2;
        self.titleView.frame = frame;

        frame = self.bounds;
        frame.size.height += scale * 90;
        self.backgroundImage.frame = frame;
    } completion:^(BOOL finished) {
        if (self.bouncing) {
            [UIView animateWithDuration:UIAViewAnimationDefaultDuraton * 0.9 delay:.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
                self.titleView.frame = self.titleGuide.frame;
                self.backgroundImage.frame = self.bounds;
            } completion:^(BOOL finished) {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(UIAViewAnimationDefaultDuraton * 0.5 * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    self.bounceFlag = NO;
                    if (self.bouncing) {
                        [self bounce];
                    }
                }); 
            }];
        } else {
            self.titleView.frame = self.titleGuide.frame;
            self.bounceFlag = NO;
        }
    }];

    if (self.viewController.animated) {
        [self.viewController bounce];
    }
}

- (void)setBouncing:(BOOL)bouncing {
    self->_bouncing = bouncing;

    if (bouncing) {
        if (self.bouncing) {
            [self bounce];
        }
    }
}

- (void)toggleBouncing:(id)sender {
    self.bouncing = !self.bouncing;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:self.bouncing] forKey:@"STSTHeaderBounce"];
    [defaults synchronize];
}

@end
