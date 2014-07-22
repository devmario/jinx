//
//  STSTGameLobbyViewController.m
//  STST
//
//  Created by 이 춘원 on 13. 5. 21..
//  Copyright (c) 2013년 vanillabreeze. All rights reserved.
//

#import "STSTGameLobbyViewController.h"
#import "STSTGameViewController.h"
#import "STSTFriendViewController.h"
#import "STSTShopViewController.h"
#import "STSTPrevGameViewController.h"
#import "STSTAppDelegate.h"
#import "STSTHeader.h"
#import "STSTUser.h"

@interface STSTGameLobbyViewController () <UITableViewDataSource, UITableViewDelegate> {
    NSInteger animatedSection;
}

@property (retain, nonatomic) NSArray *sectionHeaders;
@property (retain, nonatomic) IBOutlet UITableView *lobbyTableView;
@property (retain, nonatomic) IBOutlet UIImageView *playerPic;
@property (retain, nonatomic) IBOutlet UILabel *playerName;
@property (nonatomic, copy) NSArray *currentGameIDs;
@property (nonatomic, copy) NSArray *currentGameList;

@end

@implementation STSTGameLobbyViewController

- (BOOL)backButtonHidden {
    return YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initializatione
        [[API share] setGameDelegate:self];
        [[API share] setLobbyDelegate:self];

//        STSTKakaoUser *user = [STSTKakaoUser user];

        self.sectionHeaders = [@[@0, @1, @2, @-1] arrayByMappingOperator:^id(id obj) {
            if ([obj integerValue] < 0) {
                UIView *view = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
                return view;
            }
            const CGFloat margin = 8.0;
            UIImage *image = [UIImage imageNamed:[@"cell_%@_0" format:obj]];
            UIImageView *imageView = [[[UIImageView alloc] initWithImage:image] autorelease];
            CGRect frame = imageView.frame;
            frame.origin.y = margin;
            imageView.frame = frame;
            UIView *header = [[[UIView alloc] initWithFrame:CGRectMake(.0, .0, self.view.frame.size.width, imageView.frame.size.height + margin)] autorelease];
            [header addSubview:imageView];
            return header;
        }];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    //
}

//ERRORFIX
- (void)animateSection {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(UIAViewAnimationDefaultDuraton * 0.3 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        animatedSection += 1;

		NSLog(@"%d", animatedSection - 1);
        [self.lobbyTableView insertSections:[NSIndexSet indexSetWithIndex:animatedSection - 1] withRowAnimation:UITableViewRowAnimationRight];

        if (animatedSection == 2 && [self tableView:self.lobbyTableView numberOfRowsInSection:2] == 0) {
            animatedSection += 1;
        }

        if (animatedSection < 3) {
            [self animateSection];
        } else {
            self->_animated = NO;
        }
    });
}

//ERRORFIX
- (void)viewPrepareAppear:(BOOL)animated {
    [super viewPrepareAppear:animated];
    
    if (animated) {
        animatedSection = 0;
        if ([self tableView:self.lobbyTableView numberOfRowsInSection:0] == 0) {
            animatedSection += 1;
        }
        
        [self.lobbyTableView reloadData];
        self.lobbyTableView.contentOffset = CGPointZero;
        
        CGRect tableFrame = self.lobbyTableView.frame;

        CGRect frame = tableFrame;
        frame.origin.y = self.view.frame.size.height;
        self.lobbyTableView.frame = frame;
        self.lobbyTableView.hidden = NO;

        [UIView animateWithDuration:UIAViewAnimationDefaultDuraton * 1.4 delay:UIAViewAnimationDefaultDuraton options:0 animations:^(void) {
            CGRect frame;

            frame = tableFrame;
            frame.origin.y -= 34.0;
            self.lobbyTableView.frame = frame;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:UIAViewAnimationDefaultDuraton * 0.6 animations:^(void) {
                self.lobbyTableView.frame = tableFrame;
                [self animateSection];
            }];
        }];
    }
}

- (void)viewPrepareDisappear:(BOOL)animated {
    [super viewPrepareDisappear:animated];
    
    CGRect tableFrame = self.lobbyTableView.frame;
    [UIView animateWithDuration:UIAViewAnimationDefaultDuraton delay:.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
        CGRect frame;

        frame = tableFrame;
        frame.origin.y = self.view.frame.size.height;
        self.lobbyTableView.frame = frame;
    } completion:^(BOOL finished) {
        self.lobbyTableView.hidden = YES;
        self.lobbyTableView.frame = tableFrame;
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.lobbyTableView.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [API share].gameDelegate = nil;
    [[API share] getCurrentGames];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - reload lobby
- (void)reloadLobby
{
    STSTKakaoUser *user = [STSTKakaoUser user];
    
    self.playerName.text = user.nickname;
    if (user.profileImageURL.length > 0) {
        NSURL *url = user.profileImageURL.URL;
        NSData *data = [NSData dataWithContentsOfURL:url];
        if ( data ) {
            NSLog(@"display image");
            UIImage *image = [UIImage imageWithData:data];
            self.playerPic.image = image;
        }
    }
    NSLog(@"total friends : %d", user.friends.count);
    [self.lobbyTableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return animatedSection < 4 ? animatedSection : 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    STSTKakaoUser *user = [STSTKakaoUser user];

    switch (section) {
        case 0:
            return user.myTurnGames.count;
        case 1:
            return 3;
        case 2:
            return user.yourTurnGames.count;
        case 3:
            return 0; // TODO: 3 and buttons here
    }

    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self.sectionHeaders :section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self tableView:tableView numberOfRowsInSection:section] == 0) return .0;

    UIImageView *view = [self.sectionHeaders :section];
    return view.frame.size.height;
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
        if (indexPath.section != 1) {
            backgroundImage = [UIImage imageNamed:[@"cell_%d_%d" format0:nil, indexPath.section, last ? 2 : 1]];
            selectedBackgroundImage = [UIImage imageNamed:[@"cell_%d_%d_on" format0:nil, indexPath.section, last ? 2 : 1]];
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
        } else {
            backgroundImage = [UIImage imageNamed:[@"cell_%d_%d" format0:nil, indexPath.section, indexPath.row + 1]];
            selectedBackgroundImage = [UIImage imageNamed:[@"cell_%d_%d_on" format0:nil, indexPath.section, indexPath.row + 1]];
        }
        cell.backgroundView = [[[UIImageView alloc] initWithImage:backgroundImage] autorelease];
        cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:selectedBackgroundImage] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:18];
    }

    if (indexPath.section == 1) {
         return cell;
    }

    APIGame *game = nil;
    switch (indexPath.section) {
        case 0:
            game = [user.myTurnGames objectAtIndex:indexPath.row];
            break;
        case 2:
            game = [user.yourTurnGames objectAtIndex:indexPath.row];
            break;
        default:
            dassert(NO);
            break;
    }

    cell.textLabel.text = game.user.nickname;

    UIImage *picture = game.user.pictureImage;
    cell.imageView.image = STSTCellImage(picture, NO);
    cell.imageView.highlightedImage = STSTCellImage(picture, YES);

    UILabel *gameLabel = (UILabel *)cell.accessoryView;
	if(game.recentWordpair.me != nil && game.recentWordpair.friend != nil) {
		if([game.recentWordpair.me isEqualToString:game.recentWordpair.friend]) {
			//only lobby
			//이게 있음 무조건 화면 전환해주는게 좋음...(success떨어지게...gameview로,...)
			//ERRORFIX
			gameLabel.text = [@"%@ 　\n%@ 　" format:game.recentWordpair.meUI, @"-"];
		} else {
			gameLabel.text = [@"%@ 　\n%@ 　" format:game.recentWordpair.meUI, game.recentWordpair.friendUI];
		}
	} else {
		gameLabel.text = [@"%@ 　\n%@ 　" format:game.recentWordpair.meUI, game.recentWordpair.friendUI];
	}
    return cell;
}

- (void)gameViewNeedShowGame:(APIGame *)game withUser:(APIUser*)user {
    STSTGameViewController *gameViewController = [[[STSTGameViewController alloc] initWithPlatformSuffixedNibName:@"STSTGameViewController" bundle:nil] autorelease];
    [API share].gameDelegate = gameViewController;
    [gameViewController importGame:game];
	[gameViewController importUser:user];
    
    [self pushViewController:gameViewController];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    STSTKakaoUser *user = [STSTKakaoUser user];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    APIGame *game = nil;
    switch (indexPath.section) {
        case 0:
            game = [user.myTurnGames objectAtIndex:indexPath.row];
            break;
        case 1: {
            switch (indexPath.row) {
                case 0: {
                    STSTFriendViewController *friendViewController = [[[STSTFriendViewController alloc] initWithNibName:@"STSTFriendViewController" bundle:nil] autorelease];
                    [self pushViewController:friendViewController];
                }   break;
                case 1: {
                    if(indexPath.row == 1) {
                        NSLog(@"need random");
                        [[API share] requestRandomGame];
                    }
                }   break;
                case 2: {
                    STSTShopViewController *shopViewController = [[[STSTShopViewController alloc] initWithNibName:@"STSTShopViewController" bundle:nil] autorelease];
                    [self pushViewController:shopViewController];
                }   break;
            }
        }   break;
        case 2:
            game = [user.yourTurnGames objectAtIndex:indexPath.row];
            break;
        default:
            break;
    }

    if (game) {
        [self gameViewNeedShowGame:game withUser:game.user];
    }
}

#pragma mark - APIGameDelegate

//ERRORFIX
//에니메이션 부분 주석처리...
//데이터 수정
- (void)API:(API*)api gameTag:(NSString *)tag didReceivedWord:(NSString *)word round:(NSInteger)round user:(APIUser *)fromUser {
    STSTKakaoUser *user = [STSTKakaoUser user];

    NSAMutableOrderedDictionary *users = nil;

    if ([user.myTurnGames indexOfKey:tag] != NSNotFound) {
        // 게임이 업데이트된 경우
        users = user.myTurnGames;

        id obj = [users objectForKey:tag];
        Game *game = [[[Game alloc] initWithAPIGame:obj] autorelease];
        game.lastWordpair.friend = word;
        [users setObject:obj forKey:tag];

//        return;
    } else if ([user.yourTurnGames indexOfKey:tag] != NSNotFound) {
        // 상대방이 자기 턴을 진행한 경우
//        NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
//        [self.lobbyTableView scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
//
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(UIAViewAnimationDefaultDuraton * NSEC_PER_SEC));
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

            id obj = [user.yourTurnGames objectForKey:tag];
            Game *game = [[[Game alloc] initWithAPIGame:obj] autorelease];
//            game.lastWordpair.friend = word;
//            [game.wordpairs addObject:game.lastWordpair];
//			game.lastWordpair = [WordPair tuple];
			[user.yourTurnGames removeObjectForKey:tag];
			[user.myTurnGames setObject:game forKey:tag];
//
//            if (user.yourTurnGames.count == 0) {
//                [self.lobbyTableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationTop];
//            } else {
//                NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:index inSection:2];
//                [self.lobbyTableView deleteRowsAtIndexPaths:@[oldIndexPath] withRowAnimation:UITableViewRowAnimationTop];
//            }
//
//            [user.myTurnGames setObject:game forKey:tag];
//
//            if (user.myTurnGames.count == 1) {
//                [self.lobbyTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
//            } else {
//                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:user.myTurnGames.count - 1 inSection:0];
//                [self.lobbyTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationTop];
//            }
//        });
//        return;
    } else {
		//제일먼저해야할__ERRORFIX
		//새게임 이지만 보이지 말아야 할경우(상대방이 나의 현재 게임을 success호출하고 새게임만들어 메세지 보냈을때 를 체크함:이부분으로 들왔을때 보낸 유저가 내턴과 상대턴에 이미 존재하면...)
		//for문 들어가면서 뻗음...
		BOOL findedAlreadyGame = NO;
		for(NSString* k in user.myTurnGames) {
			APIGame* g = [user.myTurnGames :k];
			//ERRORFIX
			if([g.user.ID isEqualToString:fromUser.ID]) {
				findedAlreadyGame = YES;
				break;
			}
		}
		if(findedAlreadyGame == NO) {
			for(APIGame* g in user.yourTurnGames) {
				if([g.user.ID isEqualToString:fromUser.ID]) {
					findedAlreadyGame = YES;
					break;
				}
			}
		}
		if(findedAlreadyGame) {
			//새게임 이지만 보이지 말아야 할경우(상대방이 success가 오고 새로 새게임 보냈을때)....무시....
		} else {
			// 새게임을 시작한 경우
			Game *game = [[[Game alloc] init] autorelease];
			game.user = (KakaoUser*)fromUser;
			game.ID = tag;
			game.lastWordpair.friend = word;
			
			//        NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
			//        [self.lobbyTableView scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
			//
			//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:user.myTurnGames.count inSection:0];
			[user.myTurnGames setObject:game forKey:tag];
			/*
			 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(UIAViewAnimationDefaultDuraton * NSEC_PER_SEC));
			 dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			 if (user.myTurnGames.count == 1) {
			 [self.lobbyTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
			 } else {
			 [self.lobbyTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
			 }
			 });
			 */
			
		}
    }
	[self.lobbyTableView reloadData];
}

#pragma mark - APILobbyDelegate

- (void)API:(API*)api didReceivedGame:(NSDictionary *)game {
    NSLog(@"bbb");
}

- (void)API:(API*)api didReceivedGames:(NSArray *)games {
    STSTKakaoUser *user = [STSTKakaoUser user];
    NSAMutableOrderedDictionary *myturns = [NSAMutableOrderedDictionary dictionary];
    NSAMutableOrderedDictionary *yourturns = [NSAMutableOrderedDictionary dictionary];

    NSAMutableOrderedDictionary *playable = [NSAMutableOrderedDictionary dictionary];
    NSAMutableOrderedDictionary *playing = [NSAMutableOrderedDictionary dictionary];

    for(APIGame *game in games) {
		if (game.isMyturn) {
			[myturns setObject:game forKey:game.ID];
		} else {
			[yourturns setObject:game forKey:game.ID];
		}
        [playing setObject:game.user forKey:game.user.ID];
    }
    
    //turn, wordpair
    user.myTurnGames = myturns;
    user.yourTurnGames = yourturns;
    
        
    for (KakaoUser *friend in user.appFriends.objectEnumerator) {
        if (![playing containsKey:friend.ID]) {
            [playable setObject:friend forKey:friend.ID];
        }
    }
    
    //플레이 시작 가능유저(게임을 한번이라도 한유저는 안뜸):카톡 dictionary
    user.playableFriends = playable;
    user.playingFriends = playing;

    [self reloadLobby];
    if (!self.loaded) {
        [self markLoaded];
    }
}

- (void)API:(API*)api didReceivedGameHistory:(NSArray *)games {
    STSTKakaoUser *user = [STSTKakaoUser user];
	NSMutableArray* arr = [NSMutableArray arrayWithArray:games];
	for(APIGame* g in arr) {
		if(g.isMatch == NO) {
			[arr removeObject:g];
		}
	}
	user.prevGames = arr;
}

- (void)API:(API*)api didReceivedRandomUser:(APIUser*)user {
    [self gameViewNeedShowGame:nil withUser:user];
}

- (void)APIDidFailedToReceiveRandom:(API*)api {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"랜덤유저 가져오기 실패~!"
                                                      message:@"가져온 랜덤유저랑 이미 게임을 하고 있어요~다시 시도해주세요~"
                                                     delegate:nil
                                            cancelButtonTitle:@"닫기"
                                            otherButtonTitles:nil];
    [message show];
}
- (void)API:(API *)api didSendedMessage:(NSString*)game_id {
	
}

- (void)API:(API*)api didReceivedEnergy:(NSInteger)count remainedTime:(NSTimeInterval)remained {
    NSLog(@"eee");
}

- (void)API:(API*)api didReceivedRequest:(NSString*)_random_id nickname:(NSString*)_nickname picture:(NSString*)_picture {
    NSLog(@"fff");
}

- (IBAction)clickPrev:(id)sender {
	STSTPrevGameViewController* prevGameViewController = [[[STSTPrevGameViewController alloc] initWithNibName:@"STSTPrevGameViewController" bundle:nil] autorelease];
    [self pushViewController:prevGameViewController];
}

@end
