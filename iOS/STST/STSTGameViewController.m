//
//  STSTGameViewController.m
//  STST
//
//  Created by 이 춘원 on 13. 5. 22..
//  Copyright (c) 2013년 vanillabreeze. All rights reserved.
//

#import <UIKitExtension/UIKitExtension.h>
#import "STSTHeader.h"
#import "STSTGameViewController.h"
#import "STSTAppDelegate.h"
#import "STSTUser.h"
#import "GoogleTalk.h"

@interface STSTGameViewController () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, retain) UIImageView *header;
@property(nonatomic, retain) UIView *footer;
@property (retain, nonatomic) IBOutlet UITableView *historyTableView;
@property (retain, nonatomic) IBOutlet UIView *gameBox, *playerBox, *friendBox, *inputBox;
@property (retain, nonatomic) IBOutlet UIImageView *playerPic, *friendPic;
@property (retain, nonatomic) IBOutlet UIImageView *playerAnchor, *friendAnchor;
@property (retain, nonatomic) IBOutlet UIImageView *inputPic;
@property (retain, nonatomic) IBOutlet UILabel *playerName, *friendName;
@property (retain, nonatomic) IBOutlet UIView *friendReadyView;
@property(nonatomic, retain) IBOutlet UIView *lastWordView;
@property(nonatomic, retain) IBOutlet UILabel *lastPlayerWord, *lastFriendWord, *lastRound;
@property (retain, nonatomic) IBOutlet UIButton *sendButton, *dismissButton;
@property (retain, nonatomic) IBOutlet UIAPlaceholderTextView *inputTextView;
@property(nonatomic, retain) IBOutlet UIView *firstTutorialView;

@end


@implementation STSTGameViewController


- (void)importGame:(APIGame *)game {
    self.game = game;

    self.friend = game.user;
    self.wordPairs = [NSMutableArray arrayWithArray:[game.wordpairs arrayByMappingOperator:^id(id obj) {
        return [[[WordPair alloc] initWithAPIWordPair:obj] autorelease];
    }]];
    self.lastWordPair = [[[WordPair alloc] initWithAPIWordPair:game.lastWordpair] autorelease];
}

- (void)importUser:(APIUser *)user {
    self.friend = (KakaoUser*)user;
    self.wordPairs = [NSMutableArray array];
    self.lastWordPair = [WordPair tuple];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.header = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_8_0"]] autorelease];
    self.footer = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    self.footer.backgroundColor = [UIColor clearColor];
    self.headerView.backButton.hidden = NO;

	self.playerPic.image = [UIImage imageWithContentsOfURL:[NSURL URLWithString:[STSTKakaoUser user].profileImageURL] cachePolicy:NSURLRequestReturnCacheDataElseLoad];
	
    self.friendName.text = self.friend.nickname;
    if (self.friend.pictureURL) {
        UIImage *image = self.friend.pictureImage;
        if (image != nil) {
            self.friendPic.image = image;
        }
    }

    // API 호출 테스트
//    self.gameID = @"88695329749732113-88832016605651216:1369382155.22";
    if ( self.game.ID ) {
        [[API share] getGameForGameID:self.game.ID];
    }
    // 아래 한 줄 에러나서 주석 처리
    //self.inputTextView.font = self.inputTextView.placeholderTextView.font = [UIFont fontWithName:@"UnGungseo" size:24.0];
    self.inputTextView.placeholderTextView.font = [UIFont boldSystemFontOfSize:14.0];
    self.inputTextView.placeholderTextView.textColor = [UIColor colorWithHTMLExpression:@"#f8f8f8"];

//    self.sendButton.titleLabel.font = [UIFont fontWithName:@"UnGungseo" size:18.0];

    // Do any additional setup after loading the view from its nib.
    
    if(self.friend) {
        if([[STSTKakaoUser user] hasFriend:self.friend.ID]) {
            [self.kakaoButton setUserInteractionEnabled:YES];
            [self.kakaoButton setEnabled:YES];
        } else {
            [self.kakaoButton setUserInteractionEnabled:NO];
            [self.kakaoButton setEnabled:NO];
        }
    } else {
        [self.kakaoButton setUserInteractionEnabled:NO];
        [self.kakaoButton setEnabled:NO];
    }

    if (self.done) {
        self.inputTextView.editable = NO;
    }
}

- (CGFloat)headerViewHeight {
    return 57.0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (animated) {
        CGRect gameFrame = self.gameBox.frame;
        CGRect playerFrame = self.playerBox.frame;
        CGRect friendFrame = self.friendBox.frame;
        CGRect playerPicFrame = self.playerPic.frame;
        CGRect friendPicFrame = self.friendPic.frame;
        CGRect inputFrame = self.inputBox.frame;
        CGRect inputPicFrame = self.inputPic.frame;
        CGRect firstTutorialFrame = self.firstTutorialView.frame;

        CGRect frame;

        frame = gameFrame;
        frame.origin.y = -gameFrame.size.height;
        self.gameBox.frame = frame;
        self.gameBox.hidden = NO;

        frame = playerFrame;
        frame.origin.x = -playerFrame.size.width;
        self.playerBox.frame = frame;

        frame = friendFrame;
        frame.origin.x = self.view.frame.size.width;
        self.friendBox.frame = frame;
        self.friendName.hidden = YES;

        frame = inputFrame;
        frame.origin.x = -inputFrame.size.width;
        //        frame.origin.y = self.view.frame.size.height;
        self.inputBox.frame = frame;
        self.inputBox.hidden = NO;

        if (self.round == 0 && self.recentWordPair.me == nil) {
            frame = firstTutorialFrame;
            frame.origin.x = self.view.frame.size.width;
            self.firstTutorialView.frame = frame;
            self.firstTutorialView.hidden = NO;
        }

        [UIView animateWithDuration:UIAViewAnimationDefaultDuraton * 1.4 delay:UIAViewAnimationDefaultDuraton options:0 animations:^(void) {
            CGRect frame;

            frame = gameFrame;
            frame.origin.y += 8.0;
            self.gameBox.frame = frame;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:UIAViewAnimationDefaultDuraton * 0.6 animations:^(void) {
                self.gameBox.frame = gameFrame;
            }];
        }];

        [UIView animateWithDuration:UIAViewAnimationDefaultDuraton * 1.4 delay:UIAViewAnimationDefaultDuraton * 2.4 options:0 animations:^(void) {
            CGRect frame;

            frame = playerFrame;
            frame.origin.x += 12.0;
            self.playerBox.frame = frame;

            frame = friendFrame;
            frame.origin.x -= 12.0;
            self.friendBox.frame = frame;

            frame = inputFrame;
            frame.origin.x += 16.0;
            self.inputBox.frame = frame;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:UIAViewAnimationDefaultDuraton * 0.3 animations:^(void) {
                self.playerBox.frame = playerFrame;
                self.friendBox.frame = friendFrame;
                self.inputBox.frame = inputFrame;
            }];
            [UIView animateWithDuration:UIAViewAnimationDefaultDuraton * 0.6 delay:UIAViewAnimationDefaultDuraton * 0.3 options:0 animations:^(void) {
                CGRect frame;

                frame = friendPicFrame;
                frame.origin.x -= 8.0;
                frame.origin.y -= 8.0;
                frame.size.width += 16.0;
                frame.size.height += 16.0;
                self.friendPic.frame = frame;
                self.friendAnchor.frame = frame;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:UIAViewAnimationDefaultDuraton * 0.6 animations:^(void) {
                    self.friendPic.frame = friendPicFrame;
                    self.friendAnchor.frame = friendPicFrame;
                }];
            }];
            [UIView animateWithDuration:UIAViewAnimationDefaultDuraton * 0.6 delay:UIAViewAnimationDefaultDuraton * 0.6 options:0 animations:^(void) {
                CGRect frame;

                frame = playerPicFrame;
                frame.origin.x -= 8.0;
                frame.origin.y -= 8.0;
                frame.size.width += 16.0;
                frame.size.height += 16.0;
                self.playerPic.frame = frame;
                self.playerAnchor.frame = frame;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:UIAViewAnimationDefaultDuraton * 0.6 animations:^(void) {
                    self.playerPic.frame = playerPicFrame;
                    self.playerAnchor.frame = playerPicFrame;
                }];
            }];

            [UIView animateWithDuration:UIAViewAnimationDefaultDuraton * 0.6 delay:UIAViewAnimationDefaultDuraton * 0.9 options:0 animations:^(void) {
                CGRect frame;

                frame = inputPicFrame;
                frame.origin.x -= 12.0;
                frame.size.width += 24.0;
                frame.size.height += 12.0;
                self.inputPic.frame = frame;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:UIAViewAnimationDefaultDuraton * 0.6 animations:^(void) {
                    self.inputPic.frame = inputPicFrame;
                } completion:^(BOOL finished) {
                    if (self.lastWordPair.me) {
                        self.inputTextView.text = self.lastWordPair.me;
                    }
                    self.inputTextView.placeholderString = @"　　　　말해봐!";
                    [self.friendName setHidden:NO animated:YES];
                    if (self.round == 0 && self.lastWordPair.me == nil) {
                        [UIView animateWithDuration:UIAViewAnimationDefaultDuraton animations:^(void) {
                            self.firstTutorialView.frame = firstTutorialFrame;
                        } completion:^(BOOL finished) {
                            
                        }];
                    }
                    self->_animated = YES;
                    [self reloadData];
                }];
            }];
        }];
    }
    [self markLoaded];
}

- (void)viewPrepareAppear:(BOOL)animated {
    if (animated) {
        CGRect historyFrame = self.historyTableView.frame;
        CGRect frame;

        frame = historyFrame;
        frame.origin.y = self.view.frame.size.height - self.inputBox.frame.size.height;
        self.historyTableView.frame = frame;
        self.historyTableView.hidden = NO;

        [UIView animateWithDuration:UIAViewAnimationDefaultDuraton * 1.4 delay:UIAViewAnimationDefaultDuraton options:0 animations:^(void) {
            CGRect frame;

            frame = historyFrame;
            frame.origin.y -= 34.0;
            self.historyTableView.frame = frame;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:UIAViewAnimationDefaultDuraton * 0.6 animations:^(void) {
                self.historyTableView.frame = historyFrame;
            }];
        }];
    }
}

- (void)reloadData {
    if (self.lastWordPair.me) {
        self.inputTextView.userInteractionEnabled = NO;
    }

    if (!self.animated) return;

    [self.friendReadyView setHidden:!self.friendIsReady animated:YES];
    if (self.recentWordPair) {
        [self.lastWordView setHidden:NO animated:YES];
        self.lastPlayerWord.text = self.recentWordPair.me;
        self.lastFriendWord.text = self.recentWordPair.friend;
        self.lastRound.text = [@"%d" format0:nil, self.wordPairs.count];
    }

    [self.historyTableView reloadData];
}

- (void)viewPrepareDisappear:(BOOL)animated {
    self.firstTutorialView.hidden = YES;
    if (animated) {
        CGRect gameFrame = self.gameBox.frame;
        CGRect historyFrame = self.historyTableView.frame;
        CGRect inputFrame = self.inputBox.frame;

        [UIView animateWithDuration:UIAViewAnimationDefaultDuraton delay:.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
            CGRect frame;

            frame = gameFrame;
            frame.origin.y = -gameFrame.size.height;
            self.gameBox.frame = frame;

            frame = historyFrame;
            frame.origin.y = self.view.frame.size.height;
            self.historyTableView.frame = frame;

            frame = inputFrame;
            frame.origin.y -= gameFrame.size.height;
            self.inputBox.frame = frame;
        } completion:^(BOOL finished) {
            self.gameBox.frame = gameFrame;
            self.gameBox.hidden = YES;
            self.historyTableView.frame = historyFrame;
            self.historyTableView.hidden = YES;
            self.inputBox.frame = inputFrame;
            self.inputBox.hidden = YES;
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)friendIsReady {
    return self.lastWordPair.friend != nil;
}

- (NSInteger)round {
    return self.wordPairs.count;
}

- (void)popViewControllerAnimated:(BOOL)animated {
    [API share].gameDelegate = nil;
    [super popViewControllerAnimated:animated];
}

#pragma mark

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.dismissButton.hidden = NO;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.dismissButton.hidden = YES;
    textView.text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)textViewDidChange:(UITextView *)textView {
    self.sendButtonHidden = textView.text.length == 0;
}

- (void)sendWord:(id)sender {
    [self endEditing:sender];
    if (self.inputTextView.text.length == 0) {
        return;
    }

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(UIAViewAnimationDefaultDuraton * 0.3 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self _sendWord:sender];
    });

}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self sendWord:textView];
        return NO;
    }
    
    return YES;
}

- (void)endEditing:(id)sender {
    [self.inputTextView endEditing:YES];
}

- (BOOL)sendButtonHidden {
    return self.sendButton.hidden;
}

- (void)setSendButtonHidden:(BOOL)sendButtonHidden {
    if (self.sendButtonHidden == sendButtonHidden) {
        return;
    }

    if (sendButtonHidden) {
        CGRect sendFrame = self.sendButton.frame;
        [UIView animateWithDuration:UIAViewAnimationDefaultDuraton animations:^(void) {
            CGRect frame = sendFrame;
            frame.origin.x += frame.size.width;
            frame.size.width = .0;
            self.sendButton.frame = frame;
            self.sendButton.alpha = .0;
        } completion:^(BOOL finished) {
            self.sendButton.frame = sendFrame;
            self.sendButton.hidden = YES;
            self.sendButton.alpha = 1.0;
        }];
    } else {
        CGRect sendFrame = self.sendButton.frame;
        CGRect frame = sendFrame;
        frame.origin.x += frame.size.width;
        frame.size.width = .0;
        self.sendButton.alpha = .0;
        self.sendButton.frame = frame;
        self.sendButton.hidden = NO;

        [UIView animateWithDuration:UIAViewAnimationDefaultDuraton animations:^(void) {
            self.sendButton.frame = sendFrame;
            self.sendButton.alpha = 1.0;
        } completion:^(BOOL finished) {

        }];
    }
}

- (void)successCheck {
	NSString* w_me = nil;
	NSString* w_friend = nil;
    BOOL isMatch = [self.lastWordPair.me isEqualToString:self.lastWordPair.friend];
	if(self.lastWordPair.me == nil && self.lastWordPair.first == nil) {
		isMatch = NO;
		WordPair* pair_prev = [self.wordPairs lastObject];
		if(pair_prev) {
			if(pair_prev.me == nil)
				return;
			if(pair_prev.friend == nil)
				return;
			if([pair_prev.me isEqualToString:pair_prev.friend]) {
				isMatch = YES;
			}
			w_me = pair_prev.me;
			w_friend = pair_prev.friend;
		} else {
			return;
		}
	} else {
		if(self.lastWordPair.me == nil)
			return;
		if(self.lastWordPair.friend == nil)
			return;
		w_me = self.lastWordPair.me;
		w_friend = self.lastWordPair.friend;
	}
    NSLog(@"%@, %@", self.lastWordPair.me, self.lastWordPair.friend);
	if(isMatch) {
		[[GoogleTalk talk] play:[NSString stringWithFormat:@"%@. %@. 찌찌뽕 이에요.", w_me, w_friend] contry:@"ko"];
	} else {
		[[GoogleTalk talk] play:[NSString stringWithFormat:@"%@. %@. 찌찌뽕 아니에요.", w_me, w_friend] contry:@"ko"];
	}
	
    if(isMatch && !self.done) {
        [[API share] successForGameID:self.game.ID];
    }
}

- (void)completeRound {
	
    [self.wordPairs addObject:self.lastWordPair];
    self.lastWordPair = [WordPair tuple];
    [self.friendReadyView setHidden:YES animated:YES];
    self.inputTextView.text = @"";
    self.inputTextView.userInteractionEnabled = YES;
    self.sendButtonHidden = YES;

    if (self.wordPairs.count > 2) {
        NSIndexPath *firstPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.historyTableView insertRowsAtIndexPaths:@[firstPath] withRowAnimation:UITableViewRowAnimationBottom];
    } else if (self.wordPairs.count == 2) {
        [self.historyTableView reloadData];
        [self viewPrepareAppear:YES];
    }

    CGRect lastFrame = self.lastWordView.frame;
    [UIView animateWithDuration:UIAViewAnimationDefaultDuraton animations:^(void) {
        CGRect frame = lastFrame;
        frame.origin.y += lastFrame.size.height + 10.0;
        self.lastWordView.frame = frame;
        self.lastWordView.alpha = .0;
    } completion:^(BOOL finished) {
        self.lastWordView.frame = lastFrame;
        self.lastRound.text = [@"%d" format0:nil, self.round];
        self.lastPlayerWord.text = self.recentWordPair.me;
        self.lastFriendWord.text = self.recentWordPair.friend;
        self.lastWordView.hidden = YES;
        self.lastWordView.alpha = 1.0;
        [self.lastWordView setHidden:NO animated:YES];
    }];
    
}

- (void)_sendWord:(id)sender {
//    self.game.
    NSString *word = self.inputTextView.text;
    if (self.inputTextView.text.length == 0) {

        return;
    }
    
    
    BOOL findedMAtchWord = NO;
    for(WordPair* wordpair in self.wordPairs) {
        if([word isEqualToString:wordpair.me]) {
            findedMAtchWord = YES;
            break;
        }
        if([word isEqualToString:wordpair.friend]) {
            findedMAtchWord = YES;
            break;
        }
    }
    
    if(findedMAtchWord) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"실패"
                                                          message:@"이전에 썼던 단어는 쓰지 못해요~"
                                                         delegate:nil
                                                cancelButtonTitle:@"닫기"
                                                otherButtonTitles:nil];
        [message show];
        
        return;
    }

    self.lastWordPair.me = self.inputTextView.text;
    if (self.friendIsReady) {
        [self completeRound];
    } else {
        self.inputTextView.userInteractionEnabled = NO;
        self.sendButtonHidden = YES;
    }
    if (self.firstTutorialView.hidden == NO) {
        CGRect firstTutorialFrame = self.firstTutorialView.frame;
        [UIView animateWithDuration:UIAViewAnimationDefaultDuraton animations:^(void) {
            CGRect frame = firstTutorialFrame;
            frame.origin.x = self.view.frame.size.width;
        } completion:^(BOOL finished) {
            self.firstTutorialView.hidden = YES;
            self.firstTutorialView.frame = firstTutorialFrame;
        }];
    }
    NSLog(@"%@ %@", [STSTKakaoUser user].userID, self.friend.ID);
    [[API share] sendWord:word toUser:self.friend.ID];
}

#pragma mark - APIGameDelegate

- (void)API:(API*)api gameTag:(NSString *)tag didReceivedWord:(NSString *)word round:(NSInteger)round user:(APIUser *)fromUser {
	if(![tag isEqualToString:self.game.ID])
		return;
	
    if (self.lastWordPair.friend != nil) {
        dassert(NO);
        return; // BUG!
    }
    
    self.lastWordPair.friend = word;
    if (self.lastWordPair.me == nil) {
        [self.friendReadyView setHidden:NO animated:YES];
    } else {
        [self completeRound];
    }
	[self performSelector:@selector(successCheck) withObject:self afterDelay:0.05];
}

#pragma mark - APILobbyDelegate

- (WordPair *)recentWordPair {
    return self.wordPairs.lastObject;
}

- (void)API:(API*)api didReceivedNextGame:(APIGame *)game {
	[self popViewControllerAnimated:YES];
//    [self importGame:game];
//    [self reloadData];
}

- (void)API:(API *)api didSendedMessage:(NSString*)game_id {
	Game *game = [[[Game alloc] initWithAPIGame:self.game] autorelease];
	game.ID = game_id;
	self.game = game;
	[self performSelector:@selector(successCheck) withObject:self afterDelay:0.05];
}

- (void)API:(API*)api didReceivedGame:(APIGame *)game {
    [self importGame:game];
	[self performSelector:@selector(successCheck) withObject:self afterDelay:0.05];

	NSLog(@"%@", game);

//	NSMutableArray* friends = [NSMutableArray arrayWithArray:[[STSTKakaoUser user] appFriends]];
//	for (NSDictionary* friend in friends) {
//		if ([[friend objectForKey:@"user_id"] isEqualToString:self.friend.ID]) {
//            self.friendNickname = [friend objectForKey:@"nickname"];
//            self.friendPicutreURL = [friend objectForKey:@"profile_image_url"];
//			break;
//		}
//	}
//
//    friends = [NSMutableArray arrayWithArray:[[STSTKakaoUser user] friends]];
//	for(NSDictionary* friend in friends) {
//		if([[friend objectForKey:@"user_id"] isEqualToString:self.friendID]) {
//            self.friendNickname = [friend objectForKey:@"nickname"];
//            self.friendPicutreURL = [friend objectForKey:@"profile_image_url"];
//			break;
//		}
//	}
//
//    if(self.friendNickname == nil) {
//        self.friendNickname = [[game objectForKey:@"user"] objectForKey:@"nickname"];
//    }
//
//    if(self.friendPicutreURL == nil) {
//        self.friendNickname = [[game objectForKey:@"user"] objectForKey:@"picture"];
//    }
}



#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section != 0) return 0;
    if (self.wordPairs.count <= 1) {
        return 0;
    }
    return self.wordPairs.count - 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL last = indexPath.row + 1 == [tableView numberOfRowsInSection:indexPath.section];
    NSString *cellIdentifier = [@"%d%@" format0:nil, indexPath.section, last ? @"last" : @""];

    STSTGameHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[STSTGameHistoryCell alloc] initWithNibName:[@"STSTGameHistoryCell%@" format:last ? @"last" : @""] bundle:nil] autorelease];
        cell.textLabel.backgroundColor = cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = cell.detailTextLabel.textColor = [UIColor blackColor];

        UIImage *backgroundImage = [UIImage imageNamed:[@"cell_8_%d" format0:nil, last ? 2 : 1]];
        UIImage *selectedBackgroundImage = [UIImage imageNamed:[@"cell_8_%d_on" format0:nil, last ? 2 : 1]];
        
        cell.backgroundView = [[[UIImageView alloc] initWithImage:backgroundImage] autorelease];
        cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:selectedBackgroundImage] autorelease];
        
        [cell.contentView addSubview:[[[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 50)] autorelease]];
    }

    NSInteger wordCount = self.wordPairs.count;
    if (indexPath.row < wordCount - 1) {
        NSInteger index = self.wordPairs.count - indexPath.row - 2;
        APIWordPair *wordpair = [self.wordPairs :index];
        cell.roundLabel.text = [@"%d" format0:nil, index + 1];
        cell.playerLabel.text = wordpair.me;
        cell.friendLabel.text = wordpair.friend;

    } else {
        cell.roundLabel.text = @"";
        cell.playerLabel.text = @"";
        cell.friendLabel.text = @"";
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return self.header;
        case 1:
            return self.footer;
    }
    dassert(NO);
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        if ([self tableView:tableView numberOfRowsInSection:section] == 0) return .0;

        UIImageView *view = self.header;
        CGFloat height = tableView.frame.size.width * view.image.size.height / view.image.size.width;
        return height;
    } else {
        CGFloat diff = tableView.frame.size.height - tableView.tableHeaderView.frame.size.height - self.header.frame.size.height - [self tableView:tableView numberOfRowsInSection:0] * 40.0;
        if (diff > .0) {
            return diff;
        }
        return .0;
    }
}

/* NOTE: footer view may cause crashes
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat diff = tableView.frame.size.height - tableView.tableHeaderView.frame.size.height - self.header.frame.size.height - [self tableView:tableView numberOfRowsInSection:0] * 40.0;
    if (diff > .0) {
        return diff;
    }
    return .0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return self.footer;
}
*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)kakaoLink:(id)sender {
    if(self.friend)
        [[STSTKakaoUser user] sendKakaoLink:self.friend.ID];
}

- (void)bounce {
    CGRect playerFrame = self.playerPic.frame;
    CGRect friendFrame = self.friendPic.frame;
    
    [UIView animateWithDuration:UIAViewAnimationDefaultDuraton * 0.5 delay:.0 options:UIViewAnimationOptionCurveEaseIn animations:^(void) {
        CGFloat scale = self.headerView.bounceCount % 4 == 0 ? 12.0 : 6.0;
        CGRect frame;
        
        frame = playerFrame;
        frame.origin.x -= scale;
        frame.origin.y -= scale;
        frame.size.width += scale * 2;
        frame.size.height += scale * 2;
        self.playerPic.frame = frame;
        self.playerAnchor.frame = frame;

        frame = friendFrame;
        frame.origin.x -= scale;
        frame.origin.y -= scale;
        frame.size.width += scale * 2;
        frame.size.height += scale * 2;
        self.friendPic.frame = frame;
        self.friendAnchor.frame = frame;

    } completion:^(BOOL finished) {
        if (self.headerView.bouncing) {
            [UIView animateWithDuration:UIAViewAnimationDefaultDuraton * 0.9 delay:.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
                self.playerPic.frame = playerFrame;
                self.playerAnchor.frame = playerFrame;
                self.friendPic.frame = friendFrame;
                self.friendAnchor.frame = friendFrame;
            } completion:^(BOOL finished) {

            }];
        } else {
            self.playerPic.frame = playerFrame;
            self.playerAnchor.frame = playerFrame;
            self.friendPic.frame = friendFrame;
            self.friendAnchor.frame = friendFrame;
        }
    }];
    
}

@end

@implementation STSTGameHistoryCell


@end
