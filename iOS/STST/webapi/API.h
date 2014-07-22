//
//  API.h
//  STST
//
//  Created by wonhee jang on 13. 5. 23..
//  Copyright (c) 2013년 vanillabreeze. All rights reserved.
//

#import <UIKitExtension/UIKitExtension.h>

@class API;
@class APIUser;


@class APIGame;
@protocol APIGameDelegate <NSObject>

- (void)API:(API*)api didReceivedGame:(APIGame *)game;
- (void)API:(API*)api gameTag:(NSString *)tag didReceivedWord:(NSString *)word round:(NSInteger)round user:(APIUser*)fromUser;
- (void)API:(API *)api didSendedMessage:(NSString*)game_id;
- (void)API:(API*)api didReceivedNextGame:(APIGame *)game;

@end

@protocol APILobbyDelegate <APIGameDelegate>

- (void)API:(API*)api didReceivedGames:(NSArray *)games;
- (void)API:(API*)api didReceivedGameHistory:(NSArray *)games;
- (void)API:(API*)api didReceivedRandomUser:(APIUser*)user;
- (void)APIDidFailedToReceiveRandom:(API*)api;
- (void)API:(API*)api didReceivedEnergy:(NSInteger)count remainedTime:(NSTimeInterval)remained;
- (void)API:(API*)api didReceivedRequest:(NSString*)_random_id nickname:(NSString*)_nickname picture:(NSString*)_picture;

@end

typedef struct HTTP {
	NSURLConnection* connection;
	NSMutableData* data;
	NSString* tag;
	float start_time;
	float end_time;
	float interval;
} HTTP;

@interface API : NSObject<NSURLConnectionDataDelegate> {
	HTTP http;
	HTTP http_queue;
    BOOL running_queue;
}

@property(nonatomic, assign) id<APILobbyDelegate> lobbyDelegate;
@property(nonatomic, assign) id<APIGameDelegate> gameDelegate;
@property(nonatomic, retain) NSTimer *timer;

+ (API*)share;

- (id)init;

- (void)getCurrentGames;

- (void)requestRandomGame;
- (void)sendWord:(NSString *)_word toUser:(NSString *)userID;

- (void)getGameForGameID:(NSString*)_game_id;
- (void)successForGameID:(NSString*)_game_id;

- (void)start_message_queue;
- (void)stop_message_queue;

@end

@interface APIObject: NSObject

@property(nonatomic, retain) NSDictionary *obj;

- (id)initWithDictionary:(id)object;
+ (id)objectWithDictionary:(id)object;

@end

@interface APIUser: APIObject

@property(nonatomic, readonly) NSString *ID, *nickname;
@property(nonatomic, readonly) NSURL *pictureURL;
@property(nonatomic, readonly) UIImage *pictureImage;

@end

@interface KakaoUser: APIUser

@end

@interface APIWordPair: APIObject

@property(nonatomic, readonly) NSString *me, *friend;
@property(nonatomic, readonly) NSString *meUI, *friendUI;

@end

@interface APIGame: APIObject

@property(nonatomic, readonly) NSString *ID;
@property(nonatomic, readonly) NSUInteger round;
@property(nonatomic, readonly) KakaoUser *user;
@property(nonatomic, readonly) APIWordPair *lastWordpair;
@property(nonatomic, readonly) APIWordPair *recentWordpair;
@property(nonatomic, readonly) NSArray *wordpairs;
@property(nonatomic, readonly) BOOL isMyturn;
@property(nonatomic, readonly) BOOL isMatch;

@end

@class WordPair;
@interface Game : APIGame

@property(nonatomic, retain) NSString *ID;
@property(nonatomic, assign) NSUInteger round;
@property(nonatomic, retain) KakaoUser *user;
@property(nonatomic, retain) WordPair *lastWordpair;
@property(nonatomic, retain) NSMutableArray *wordpairs;

- (id)init;
- (id)initWithAPIGame:(APIGame *)game;

@end

@interface WordPair: NSAMutableTuple

@property(nonatomic, retain) NSString *me, *friend;

- (id)initWithAPIWordPair:(APIWordPair *)pair;

@end
