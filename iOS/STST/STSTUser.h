//
//  STSTUser.h
//  STST
//
//  Created by Jeong YunWon on 13. 5. 22..
//  Copyright (c) 2013 vanillabreeze. All rights reserved.
//

#import <UIKitExtension/UIKitExtension.h>

@interface STSTKakaoUser : NSObject

+ (STSTKakaoUser *)user;

@property(nonatomic, assign, getter = isAutoSynced) BOOL AutoSynced;

@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, readonly) NSString *percentEscapedNickname;
@property (nonatomic, copy) NSString *profileImageURL;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *chatID;
@property (nonatomic, copy) NSString *chatTitle;
@property (nonatomic, copy) NSString *chatUserNames;
@property (nonatomic, copy) NSString *deviceToken;
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *refreshToken;
@property (nonatomic, retain) NSAMutableOrderedDictionary *friends;
@property (nonatomic, retain) NSAMutableOrderedDictionary *appFriends;

@property (nonatomic, retain) NSAMutableOrderedDictionary *myTurnGames;
@property (nonatomic, retain) NSAMutableOrderedDictionary *yourTurnGames;
@property (nonatomic, retain) NSAMutableOrderedDictionary *playableFriends;
@property (nonatomic, retain) NSAMutableOrderedDictionary *playingFriends;
@property (nonatomic, retain) NSArray *prevGames;

- (BOOL)hasFriend:(NSString*)user_id;
- (void)sendKakaoLink:(NSString*)user_id;

@end
