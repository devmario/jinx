//
//  STSTPrevGameViewController.m
//  STST
//
//  Created by wonhee jang on 13. 5. 27..
//  Copyright (c) 2013년 vanillabreeze. All rights reserved.
//

#import "STSTPrevGameViewController.h"
#import "STSTUser.h"
#import "API.h"
#import "STSTGameViewController.h"

@interface STSTPrevGameViewController ()

@property(nonatomic, retain) IBOutlet UITableView *prevGameTableView;
@property(nonatomic, retain) NSArray *sectionHeaders;
@property(nonatomic, retain) UIView *footer;

@end

@implementation STSTPrevGameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.sectionHeaders = [@[@8] arrayByMappingOperator:^id(id obj) {
            UIImage *image = [UIImage imageNamed:[@"cell_%@_0" format:obj]];
            return [[[UIImageView alloc] initWithImage:image] autorelease];
        }];
        self.footer = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        self.footer.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

- (void)viewDidLoad
{
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
        CGRect tableFrame = self.prevGameTableView.frame;
        self.prevGameTableView.contentOffset = CGPointZero;

        CGRect frame = tableFrame;
        frame.origin.y = self.view.frame.size.height;
        self.prevGameTableView.frame = frame;
        self.prevGameTableView.hidden = NO;
        
        [UIView animateWithDuration:UIAViewAnimationDefaultDuraton * 1.4 delay:UIAViewAnimationDefaultDuraton options:0 animations:^(void) {
            CGRect frame;
            
            frame = tableFrame;
            frame.origin.y -= 34.0;
            self.prevGameTableView.frame = frame;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:UIAViewAnimationDefaultDuraton * 0.6 animations:^(void) {
                self.prevGameTableView.frame = tableFrame;
            }];
        }];
    }
}

- (void)viewPrepareDisappear:(BOOL)animated {
    [super viewPrepareDisappear:animated];
    
    CGRect tableFrame = self.prevGameTableView.frame;
    [UIView animateWithDuration:UIAViewAnimationDefaultDuraton delay:.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
        CGRect frame;
        
        frame = tableFrame;
        frame.origin.y = self.view.frame.size.height;
        self.prevGameTableView.frame = frame;
    } completion:^(BOOL finished) {
        self.prevGameTableView.hidden = YES;
        self.prevGameTableView.frame = tableFrame;
    }];
}

#pragma mark

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    STSTKakaoUser *user = [STSTKakaoUser user];
    return user.prevGames.count;
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
    if (indexPath.section == 1) {
        cellIdentifier = [@"%d%d" format0:nil, indexPath.section, indexPath.row];
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [UITableViewCell cellWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        UIImage *backgroundImage = nil, *selectedBackgroundImage = nil;
        
		backgroundImage = [UIImage imageNamed:[@"cell_%d_%d" format0:nil, indexPath.section + 8, last ? 2 : 1]];
		selectedBackgroundImage = [UIImage imageNamed:[@"cell_%d_%d_on" format0:nil, indexPath.section + 8, last ? 2 : 1]];
		UILabel *gameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(.0, .0, 100.0, 44.0)] autorelease];
		gameLabel.numberOfLines = 2;
		gameLabel.font = [UIFont systemFontOfSize:12.0];
		gameLabel.backgroundColor = [UIColor clearColor];
		gameLabel.textAlignment = NSTextAlignmentRight;
		cell.accessoryView = gameLabel;
		
		switch (indexPath.section) {
			case 0:
				cell.textLabel.textColor = gameLabel.textColor = [UIColor colorWithHTMLExpression:@"#1cb634"];
				break;
			case 2:
				cell.textLabel.textColor = gameLabel.textColor = [UIColor colorWithHTMLExpression:@"#fd5f00"];
				break;
			default:
				break;
		}
		
        cell.backgroundView = [[[UIImageView alloc] initWithImage:backgroundImage] autorelease];
        cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:selectedBackgroundImage] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:18];
    }
	
    if (indexPath.section == 1) {
		return cell;
    }
	
    APIGame *game = [user.prevGames objectAtIndex:indexPath.row];
    cell.textLabel.text = game.user.nickname;
	
    UIImage *picture = game.user.pictureImage;
    cell.imageView.image = STSTCellImage(picture, NO);
    cell.imageView.highlightedImage = STSTCellImage(picture, YES);
	
    UILabel *gameLabel = (UILabel *)cell.accessoryView;
    gameLabel.text = [@"%@ 　\n%@ 　" format:game.recentWordpair.meUI, game.recentWordpair.friendUI];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	STSTKakaoUser *user = [STSTKakaoUser user];
    APIGame *game = [user.prevGames objectAtIndex:indexPath.row];
    STSTGameViewController *gameViewController = [[[STSTGameViewController alloc] initWithPlatformSuffixedNibName:@"STSTGameViewController" bundle:nil] autorelease];
    [API share].gameDelegate = gameViewController;
    [gameViewController importGame:game];
    gameViewController.done = YES;
    
    [self pushViewController:gameViewController];
}


@end
