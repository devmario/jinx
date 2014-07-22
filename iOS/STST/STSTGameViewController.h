//
//  STSTGameViewController.h
//  STST
//
//  Created by 이 춘원 on 13. 5. 22..
//  Copyright (c) 2013년 vanillabreeze. All rights reserved.
//

#import "API.h"
#import "STSTViewController.h"

@interface STSTGameHistoryCell : UITableViewCell

@property(nonatomic, retain) IBOutlet UILabel *roundLabel;
@property(nonatomic, retain) IBOutlet UILabel *playerLabel, *friendLabel;

@end

@interface STSTGameViewController : STSTViewController <APIGameDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property(nonatomic, retain) KakaoUser *friend;
@property(nonatomic, retain) APIGame *game;
@property(nonatomic, retain) NSMutableArray *wordPairs;
@property(nonatomic, retain) WordPair *lastWordPair;
@property(nonatomic, assign) BOOL sendButtonHidden;
@property(nonatomic, readonly) BOOL friendIsReady;
@property(nonatomic, readonly) WordPair *recentWordPair;
@property(nonatomic, retain) IBOutlet UIButton* kakaoButton;
@property(nonatomic, readonly) NSInteger round;
@property(nonatomic, assign) BOOL done;

- (void)importGame:(APIGame *)game;
- (void)importUser:(APIUser *)user;
- (IBAction)reloadData;

- (IBAction)endEditing:(id)sender;
- (IBAction)sendWord:(id)sender;

- (IBAction)kakaoLink:(id)sender;

@end
