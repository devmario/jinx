//
//  STSTFriendViewController.m
//  STST
//
//  Created by Jeong YunWon on 13. 5. 24..
//  Copyright (c) 2013년 vanillabreeze. All rights reserved.
//

#import "STSTUser.h"
#import "STSTFriendViewController.h"
#import "STSTGameViewController.h"

@interface STSTFriendViewController ()

@property(nonatomic, retain) IBOutlet UITableView *friendTableView;
@property(nonatomic, retain) NSArray *sectionHeaders;
@property(nonatomic, retain) UIView *footer;

@end

@implementation STSTFriendViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.sectionHeaders = [@[@4, @5] arrayByMappingOperator:^id(id obj) {
            UIImage *image = [UIImage imageNamed:[@"cell_%@_0" format:obj]];
            return [[[UIImageView alloc] initWithImage:image] autorelease];
        }];
        self.footer = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        self.footer.backgroundColor = [UIColor clearColor];

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.headerView.backButton.hidden = NO;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self markLoaded];
}

- (void)viewPrepareAppear:(BOOL)animated {
    if (animated) {
        self.friendTableView.contentOffset = CGPointZero;
        CGRect tableFrame = self.friendTableView.frame;

        CGRect frame = tableFrame;
        frame.origin.y = self.view.frame.size.height;
        self.friendTableView.frame = frame;
        self.friendTableView.hidden = NO;

        [UIView animateWithDuration:UIAViewAnimationDefaultDuraton * 1.4 delay:UIAViewAnimationDefaultDuraton options:0 animations:^(void) {
            CGRect frame;

            frame = tableFrame;
            frame.origin.y -= 34.0;
            self.friendTableView.frame = frame;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:UIAViewAnimationDefaultDuraton * 0.6 animations:^(void) {
                self.friendTableView.frame = tableFrame;
            }];
        }];
    }
}

- (void)viewPrepareDisappear:(BOOL)animated {
    [super viewPrepareDisappear:animated];
    
    CGRect tableFrame = self.friendTableView.frame;
    [UIView animateWithDuration:UIAViewAnimationDefaultDuraton delay:.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
        CGRect frame;

        frame = tableFrame;
        frame.origin.y = self.view.frame.size.height;
        self.friendTableView.frame = frame;
    } completion:^(BOOL finished) {
        self.friendTableView.hidden = YES;
        self.friendTableView.frame = tableFrame;
    }];
}

#pragma mark

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    STSTKakaoUser *user = [STSTKakaoUser user];
    NSInteger count = 0;
    switch (section) {
        case 0: {
            count = user.playableFriends.count;
        }   break;
        case 1: {
            count = user.friends.count;
        }   break;
        default:
            break;
    }
    return count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self.sectionHeaders :section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self tableView:tableView numberOfRowsInSection:section] == 0) return .0;

    UIImageView *view = [self.sectionHeaders :section];
    CGFloat height = tableView.frame.size.width * view.image.size.height / view.image.size.width;
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return self.footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([self tableView:tableView numberOfRowsInSection:section] == 0) return .0;
    
    return 8.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STSTKakaoUser *user = [STSTKakaoUser user];
    
    BOOL last = indexPath.row + 1 == [tableView numberOfRowsInSection:indexPath.section];
    NSString *cellIdentifier = [@"%d%@" format0:nil, indexPath.section, last ? @"last" : @""];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == nil) {
        cell = [UITableViewCell cellWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        UIImage *backgroundImage = [UIImage imageNamed:[@"cell_%d_%d" format0:nil, indexPath.section + 4, last ? 2 : 1]];
        UIImage *selectedBackgroundImage = [UIImage imageNamed:[@"cell_%d_%d_on" format0:nil, indexPath.section + 4, last ? 2 : 1]];

        NSString *title = nil;
        switch (indexPath.section) {
            case 0:
                title = @"게임하기";
                break;
            case 1:
                title = @"초대하기";
                break;
            default:
                break;
        }

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(.0, .0, 65.0, 20.0);
        [button setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:12.0];
        cell.accessoryView = button;

        cell.backgroundView = [[[UIImageView alloc] initWithImage:backgroundImage] autorelease];
        cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:selectedBackgroundImage] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:18];
        cell.textLabel.textColor = [UIColor colorWithHTMLExpression:@"#f28700"];
        cell.textLabel.highlightedTextColor = [UIColor colorWithHTMLExpression:@"#e04000"];
    }

    KakaoUser *data = nil;
    switch (indexPath.section) {
        case 0: {
            data = [user.playableFriends objectAtIndex:indexPath.row];
        }   break;
        case 1: {
            data = [user.friends objectAtIndex:indexPath.row];
        }   break;
        default:
            break;
    }

    NSURL *pictureURL = data.pictureURL;
    UIImage *profileImage = nil;
    if (pictureURL != nil) {
        profileImage = [UIImage imageWithContentsOfURL:pictureURL cachePolicy:NSURLRequestReturnCacheDataElseLoad];
    } else {
        profileImage = [UIImage imageNamed:@"dummy.jpg"];
    }

    cell.imageView.image = STSTCellImage(profileImage, NO);
    cell.imageView.highlightedImage = STSTCellImage(profileImage, YES);
    cell.textLabel.text = data.nickname;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    STSTKakaoUser *user = [STSTKakaoUser user];
    APIUser *data = nil;
    switch (indexPath.section) {
        case 0: {
            data = [user.playableFriends objectAtIndex:indexPath.row];
        }   break;
        case 1: {
            data = [user.friends objectAtIndex:indexPath.row];
        }   break;
        default:
            break;
    }
    STSTGameViewController *vc = [[[STSTGameViewController alloc] initWithPlatformSuffixedNibName:@"STSTGameViewController" bundle:nil] autorelease];
	[vc importUser:data];
    [API share].gameDelegate = vc;

    if (vc) {
        [self viewPrepareDisappear:YES];

        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(UIAViewAnimationDefaultDuraton * 0.3 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.navigationController pushViewController:vc animated:YES];
        });
    }
}


@end
