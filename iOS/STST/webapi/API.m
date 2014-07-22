//
//  API.m
//  STST
//
//  Created by wonhee jang on 13. 5. 23..
//  Copyright (c) 2013년 vanillabreeze. All rights reserved.
//

#include <sys/time.h>

#import "API.h"
#import "STSTUser.h"
#import "Kakao.h"

#define HOST "http://ec2-54-214-154-148.us-west-2.compute.amazonaws.com:8080"

API* __api = nil;

NSString *APINotNilString(NSString *str) {
    if (str) {
        return str;
    }
    return @"";
}

@implementation API

@synthesize lobbyDelegate;
@synthesize gameDelegate;

- (id)init {
    self = [super init];
    if (self != nil) {
        http.connection = nil;
        http.data = nil;
        
        http_queue.connection = nil;
        http_queue.data = nil;
    }
    return self;
}

+ (API*)share {
    if(__api == nil) {
        __api = [[API alloc] init];
    }
    return __api;
}

- (HTTP*)get_http:(NSURLConnection*)_connection {
    if(_connection == http.connection)
        return &http;
    if(_connection == http_queue.connection)
        return &http_queue;
    return NULL;
}

- (void)start_message_queue {
    if(!running_queue) {
        running_queue = YES;
        [self start_http:&http_queue withURL:[@HOST"/queue?uid=%@" format:[[STSTKakaoUser user] userID]] withTag:@"queue"];
    }
}

- (void)stop_message_queue {
    if(running_queue) {
        running_queue = NO;
        if (self.timer.isValid) {
            [self.timer invalidate];
            self.timer = nil;
        }
        if(http_queue.data) {
            [http_queue.data release];
            http_queue.data = nil;
        }
        [self end_http:http_queue.connection force:YES];
    }
}

- (void)queuetimer:(NSTimer *)aTimer {
    [self start_http:&http_queue withURL:[@HOST"/queue?uid=%@" format:[[STSTKakaoUser user] userID]] withTag:@"queue"];
    self.timer = nil;
}

- (void)end_http:(NSURLConnection*)_connection force:(BOOL)force {
    HTTP* _http = [self get_http:_connection];
	
    STSTKakaoUser *kakaoUser = [STSTKakaoUser user];

    if(_http->data && force == NO) {
        struct timeval cur_time;
        gettimeofday(&cur_time, NULL);
        _http->end_time = ((cur_time.tv_sec * 1000000.0) + cur_time.tv_usec) / 1000000.0;
        _http->interval = _http->end_time - _http->start_time;
        
        NSData *returnedData = [[NSData alloc] initWithBytes:[_http->data mutableBytes] length:[_http->data length]];
        NSError *error = nil;
        NSDictionary *object = [NSJSONSerialization JSONObjectWithData:returnedData options:0 error:&error];

//        NSLog(@"received data: %@", object);
        if(error == nil) {
            if([_http->tag isEqualToString:@"main"]){
//                if ( [object objectForKey:@"gamelist"] != nil) {
//                    [lobbyDelegate API:__api didReceivedGames:[[object objectForKey:@"gamelist"] objectForKey:@"current"]];
//                }
                NSDictionary *gamelist = [object :@"gamelist"];
//                NSDictionary *users = [object :@"users"];
//                NSDictionary *me = [object :@"me"];
                NSArray *games = [[gamelist :@"playings"] arrayByMappingOperator:^id(id obj) {
                    APIGame *game = [APIGame objectWithDictionary:obj];
                    return game;
                }];
                NSLog(@"games: %@", games);
				[lobbyDelegate API:__api didReceivedGames:games];
                games = [[gamelist :@"history"] arrayByMappingOperator:^id(id obj) {
                    APIGame *game = [APIGame objectWithDictionary:obj];
                    return game;
                }];
                NSLog(@"history: %@", games);
				[lobbyDelegate API:__api didReceivedGameHistory:games];
                NSLog(@"histories: %@", games);
				//todo energy~~~
				NSLog(@"data ---------------\n%@---------------", [object description]);
            } else if([_http->tag isEqualToString:@"random"]) {
                NSLog(@"random user:%@", object);
                if([object objectForKey:@"pick"] == nil) {
                    //서버 랜덤 발송 실패
                    [lobbyDelegate APIDidFailedToReceiveRandom:__api];
                } else {
                    APIUser *api_user = [APIUser objectWithDictionary:[object objectForKey:@"pick"]];
                    
                    BOOL need_client_random = NO;
                    if([api_user.ID isEqualToString:kakaoUser.userID])
                        need_client_random = YES;
                    need_client_random = [kakaoUser.playingFriends containsKey:api_user.ID];
                    if(need_client_random) {
                        if([STSTKakaoUser user].playableFriends.count == 0) {
                            //랜덤 못함
                            [lobbyDelegate APIDidFailedToReceiveRandom:__api];
                        } else {
                            KakaoUser* pick_user = [kakaoUser.playableFriends objectAtIndex:(rand() % kakaoUser.playableFriends.count)];
                            NSLog(@"%@", pick_user.nickname);
                            [lobbyDelegate API:__api didReceivedRandomUser:(APIUser*)pick_user];
                        }
                    } else {
                        [lobbyDelegate API:__api didReceivedRandomUser:api_user];
                    }
                }
                
            } else if([_http->tag isEqualToString:@"send"]) {
				[gameDelegate API:__api didSendedMessage:[[object objectForKey:@"game"] objectForKey:@"id"]];
//                [lobbyDelegate API:__api didReceivedGame:[APIGame objectWithDictionary:dict]];
				
            } else if([_http->tag isEqualToString:@"get"]) {
                [gameDelegate API:__api didReceivedGame:[APIGame objectWithDictionary:[object objectForKey:@"game"]]];
            } else if([_http->tag isEqualToString:@"success"]) {
                [gameDelegate API:__api didReceivedNextGame:[APIGame objectWithDictionary:[object objectForKey:@"game"]]];
			} else if([_http->tag isEqualToString:@"queue"]) {
//                NSLog(@"queue %@", object);
                NSArray* _arr = (NSArray*)object;
                for(int i = 0; i < _arr.count; i++) {
                    NSDictionary* _dict = [_arr objectAtIndex:i];
                    [gameDelegate API:__api gameTag:[_dict objectForKey:@"gid"] didReceivedWord:[_dict objectForKey:@"message"] round:[[_dict objectForKey:@"turn"] intValue] user:[APIUser objectWithDictionary:[_dict objectForKey:@"user"]]];
                    [lobbyDelegate API:__api gameTag:[_dict objectForKey:@"gid"] didReceivedWord:[_dict objectForKey:@"message"] round:[[_dict objectForKey:@"turn"] intValue] user:[APIUser objectWithDictionary:[_dict objectForKey:@"user"]]];
                }
            }
        } else {
            NSLog(@"%@", error);
        }
        
        if(returnedData)
            [returnedData release];
    }
    
	if([_http->tag isEqualToString:@"queue"] && force == NO) {
		if(running_queue) {
			float interval = 0.5 - _http->interval;
			if(interval < 0)
				interval = 0;
			self.timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(queuetimer:) userInfo:nil repeats:NO];
		}
	}
    
	BOOL need_start_queue = _http->tag != nil && ![_http->tag isEqualToString:@"queue"] && force == NO;
    
    if(_http->connection) {
        [_http->connection cancel];
        [_http->connection release];
    }
    _http->connection = nil;
    if(_http->data)
        [_http->data release];
    _http->data = nil;
    if(_http->tag)
        [_http->tag release];
    _http->tag = nil;
	
	if(need_start_queue)
        [self start_message_queue];
}

- (void)start_http:(HTTP*)_http withURL:(NSString*)_url withTag:(NSString*)tag {
    if([tag isEqualToString:@"queue"] == NO) {
        NSLog(@"url send: %@", [_url stringByAddingPercentEscapesUsingUTF8Encoding]);
    }
    [self end_http:_http->connection force:YES];
    _http->connection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] delegate:self startImmediately:YES];
    _http->data = [[NSMutableData alloc] init];
    _http->tag = [[NSString alloc] initWithString:tag];
    
    struct timeval cur_time;
    gettimeofday(&cur_time, NULL);
    _http->start_time = ((cur_time.tv_sec * 1000000.0) + cur_time.tv_usec) / 1000000.0;
    
    if(![_http->tag isEqualToString:@"queue"])
        [self stop_message_queue];
}

- (NSMutableData*)get_data:(NSURLConnection*)_connection {
    HTTP* _http = [self get_http:_connection];
    if(_http == NULL)
        return NULL;
    return _http->data;
}

- (void)getCurrentGames {
    [self stop_message_queue];
    STSTKakaoUser *user = [STSTKakaoUser user];
    NSString *URL = [@HOST"/?uid=%@&nickname=%@&picture=%@&token=" format:user.userID, user.nickname, user.profileImageURL, user.deviceToken] ;
	NSLog(@"%@", URL);
    [self start_http:&http withURL:URL withTag:@"main"];
}

- (void)requestRandomGame {
    STSTKakaoUser *user = [STSTKakaoUser user];
    [self start_http:&http withURL:[NSString stringWithFormat:@HOST"/random?uid=%@", user.userID] withTag:@"random"];
}

- (void)sendWord:(NSString *)_word toUser:(NSString *)userID {
    dassert(_word.length > 0);
    dassert(userID);
    STSTKakaoUser *user = [STSTKakaoUser user];
    NSString *URL = [@HOST"/send?uid=%@&toid=%@&message=%@" format:user.userID, userID, _word];
    [self start_http:&http withURL:URL withTag:@"send"];
}

- (void)getGameForGameID:(NSString*)_game_id {
    dassert(_game_id);
    [self stop_message_queue];
    STSTKakaoUser *user = [STSTKakaoUser user];
    NSString *URL = [@HOST"/get?gid=%@&uid=%@" format:_game_id, user.userID];
    [self start_http:&http withURL:URL withTag:@"get"];
}

- (void)successForGameID:(NSString *)_game_id {
    dassert(_game_id);
    [self stop_message_queue];
    STSTKakaoUser *user = [STSTKakaoUser user];
    NSString *URL = [@HOST"/success?gid=%@&uid=%@" format:_game_id, user.userID];
    [self start_http:&http withURL:URL withTag:@"success"];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [[self get_data:connection] setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [[self get_data:connection] appendData:data];
}

-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {
    // error
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self end_http:connection force:NO];
}

@end


@implementation APIObject

- (id)initWithDictionary:(id)object {
    dassert(object);
    self = [super init];
    if (self != nil) {
        self.obj = object;
    }
    return self;
}

+ (id)objectWithDictionary:(id)object {
    return [[[self alloc] initWithDictionary:object] autorelease];
}

- (void)dealloc {
    self.obj = nil;
    [super dealloc];
}

@end

@implementation APIUser

- (NSString *)ID {
	if([self.obj containsKey:@"user_id"]) {
		NSString *user_id = [self.obj :@"user_id"]; // ???
		if ([user_id hasPrefix:@"-"]) {
			user_id = [user_id substringFromIndex:1];
		}
		return user_id;
	} else {
		return [self.obj :@"id"];
	}
}

- (NSString *)nickname {
    return [self.obj :@"nickname"];
}

- (NSURL *)pictureURL {
    NSString *string = [self.obj :@"picture"];
    if (string.length == 0) {
		NSString *string2 = [self.obj :@"profile_image_url"];
		if (string2.length == 0) {
			return nil;
		}
        return string2.URL;
    }
    return string.URL;
}

- (UIImage *)pictureImage {
    return [UIImage imageWithContentsOfURL:self.pictureURL cachePolicy:NSURLRequestReturnCacheDataElseLoad];
}

@end

@implementation KakaoUser

- (NSString *)ID {
	if([self.obj containsKey:@"user_id"]) {
		NSString *user_id = [self.obj :@"user_id"]; // ???
		if ([user_id hasPrefix:@"-"]) {
			user_id = [user_id substringFromIndex:1];
		}
		return user_id;
	} else {
		return [self.obj :@"id"];
	}
}

- (NSString *)nickname {
    return [self.obj :@"nickname"];
}

- (NSURL *)pictureURL {
    NSString *string = [self.obj :@"profile_image_url"];
    if (string.length == 0) {
		NSString *string2 = [self.obj :@"picture"];
		if (string2.length == 0) {
			return nil;
		}
        return string2.URL;
    }
    return string.URL;
}

- (UIImage *)pictureImage {
    return [UIImage imageWithContentsOfURL:self.pictureURL cachePolicy:NSURLRequestReturnCacheDataElseLoad];
}


@end


@implementation APIGame

- (NSString *)ID {
    id ID = [self.obj :@"id"];
    assert(ID);
    return ID;
}

- (NSUInteger)round {
	if([self.obj containsKey:@"turn"])
    	return [[self.obj :@"turn"] integerValue];
	else
		return 1;
}

- (KakaoUser *)user {
	NSDictionary* dict = [self.obj :@"user"];
	STSTKakaoUser *kuser = [STSTKakaoUser user];
	id user_id = [dict :@"id"];
	id appFriend = [kuser.appFriends objectForKey:user_id];
	if (appFriend) {
		return appFriend;
	}
	id friend = [kuser.friends objectForKey:user_id];
	if (friend) {
		return friend;
	}
	return [KakaoUser objectWithDictionary:[self.obj :@"user"]];
}

- (APIWordPair *)lastWordpair {
    id obj = [self.obj :@"last_wordpair"];
    return [APIWordPair objectWithDictionary:obj];
}

- (APIWordPair *)recentWordpair {
    id obj = [self.wordpairs lastObject];
    if (obj == nil) {
        obj = [WordPair tuple];
    }
    return obj;
}

- (BOOL)isMyturn {
    return self.lastWordpair.me == nil;
}

- (BOOL)isMatch {
	WordPair* wp = self.wordpairs.lastObject;
	if(wp.me == nil || wp.friend == nil) {
		return NO;
	}
	if([wp.me isEqualToString:wp.friend]) {
		return YES;
	}
	return NO;
}

- (NSArray *)wordpairs {
    return [[self.obj :@"wordpairs"] arrayByMappingOperator:^id (id obj) {
        return [APIWordPair objectWithDictionary:obj];
    }];
}

@end


@interface Game () {
    NSUInteger _round;
}

@end

@implementation Game

@synthesize ID=_ID;
@synthesize user=_user;
@synthesize wordpairs=_wordpairs;
@synthesize lastWordpair=_lastWordpair;

- (id)init {
    self = [super init];
    if (self != nil) {
        self.wordpairs = [NSMutableArray array];
        self.lastWordpair = [WordPair tuple];
    }
    return self;
}

- (id)initWithAPIGame:(APIGame *)game {
    self = [super init];
    if (self != nil) {
        self.ID = game.ID;
        self.round = game.round;
        self.user = game.user;
        self.lastWordpair = [[[WordPair alloc] initWithAPIWordPair:game.lastWordpair] autorelease];
        self.wordpairs = [NSMutableArray arrayWithArray:game.wordpairs];
    }
    return self;
}

- (NSUInteger)round {
    return self->_round;
}

- (void)setRound:(NSUInteger)round {
    self->_round = round;
}

@end


@implementation APIWordPair

- (NSString *)me {
    for (id key in self.obj) {
        if ([key isEqualToString:[STSTKakaoUser user].userID]) {
            return [self.obj :key];
        }
    }
    return nil;
}

- (NSString *)friend {
    for (id key in self.obj) {
        if (![key isEqualToString:[STSTKakaoUser user].userID]) {
            return [self.obj :key];
        }
    }
    return nil;
}

- (NSString *)meUI {
    id obj = self.me;
    if (obj) {
        return obj;
    }
    return @"-";
}

- (NSString *)friendUI {
    id obj = self.friend;
    if (obj) {
        return obj;
    }
    return @"-";
}

@end


@implementation WordPair

- (id)initWithAPIWordPair:(APIWordPair *)pair {
    self = [super init];
    if (self != nil) {
        self.me = pair.me;
        self.friend = pair.friend;
    }
    return self;
}

- (NSString *)me {
    return self.first;
}

- (NSString *)friend {
    return self.second;
}

- (void)setMe:(NSString *)me {
    self.first = me;
}

- (void)setFriend:(NSString *)friend {
    self.second = friend;
}

- (NSString *)meUI {
    return self.me ? self.me : @"-";
}

- (NSString *)friendUI {
    return self.friend ? self.friend : @"-";
}

@end
