//
//  STSTActivityIndicatorView.m
//  STST
//
//  Created by Jeong YunWon on 13. 5. 26..
//  Copyright (c) 2013년 vanillabreeze. All rights reserved.
//

#import "STSTActivityIndicatorView.h"

@implementation STSTActivityIndicatorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)pushAnimated:(BOOL)animated {
    if (self->_pushedCount == 0) {
        [self setHidden:NO animated:animated];
    }
    self->_pushedCount += 1;
}

- (void)popAnimated:(BOOL)animated {
    if (self->_pushedCount == 0) {
        @throw [NSException exceptionWithName:@"error" reason:@"----" userInfo:nil];
    }
    self->_pushedCount -= 1;
    if (self->_pushedCount == 0) {
        [self setHidden:YES animated:animated];
    }

}

@end
