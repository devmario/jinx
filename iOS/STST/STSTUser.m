//
//  STSTUser.m
//  STST
//
//  Created by Jeong YunWon on 13. 5. 22..
//  Copyright (c) 2013 vanillabreeze. All rights reserved.
//

#import "STSTUser.h"
#import "API.h"
#import "Kakao.h"

static NSString *const kAccessTokenKey = @"accessToken";
static NSString *const kRefreshTokenKey = @"refreshToken";
static NSString *const kUserId = @"user_id";
static NSString *const kNickname = @"nickname";
static NSString *const kProfileImageUrl = @"profile_image_url";
static NSString *const kDeviceToken = @"deviceToken";
static NSString *const kChatIDKey = @"chatID";
static NSString *const kChatTitleKey = @"chatTitle";
static NSString *const kChatUserNamesKey = @"chatUserNames";

@implementation STSTKakaoUser

id STSTKakaoUserSharedUser = nil;

+ (void)initialize {
    if (self == [STSTKakaoUser class]) {
        STSTKakaoUserSharedUser = [[self alloc] init];
    }
}

- (id)init {
    self = [super init];
    if (self != nil) {
        self.AutoSynced = YES;
    }
    return self;
}

+ (STSTKakaoUser *)user {
    return STSTKakaoUserSharedUser;
}

#pragma mark - properties

- (NSString *)accessToken
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kAccessTokenKey];
}

- (void)setAccessToken:(NSString *)accessToken
{
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:kAccessTokenKey];
}

- (NSString *)refreshToken
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kRefreshTokenKey];
}

- (void)setRefreshToken:(NSString *)refreshToken
{
    [[NSUserDefaults standardUserDefaults] setObject:refreshToken forKey:kRefreshTokenKey];
}

- (NSString *)chatTitle
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kChatTitleKey];
}

- (void)setChatTitle:(NSString *)chatTitle
{
    [[NSUserDefaults standardUserDefaults] setObject:chatTitle forKey:kChatTitleKey];
}

- (NSString *)chatID
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kChatIDKey];
}

- (void)setChatID:(NSString *)chatID
{
    [[NSUserDefaults standardUserDefaults] setObject:chatID forKey:kChatIDKey];
}

- (NSString *)chatUserNames
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kChatUserNamesKey];
}

- (void)setChatUserNames:(NSString *)chatUserNames
{
    [[NSUserDefaults standardUserDefaults] setObject:chatUserNames forKey:kChatUserNamesKey];
}

#pragma mark - kakao user info

- (NSString *)userID
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kUserId];
}

- (void)setUserID:(NSString *)userId
{
    [[NSUserDefaults standardUserDefaults] setObject:userId forKey:kUserId];
}

- (NSString *)nickname
{
    if ( [[NSUserDefaults standardUserDefaults] stringForKey:kNickname] == nil )
        return @"";
    return [[NSUserDefaults standardUserDefaults] stringForKey:kNickname];
}

- (void)setNickname:(NSString *)nickname
{
    [[NSUserDefaults standardUserDefaults] setObject:nickname forKey:kNickname];
}

- (NSString *)profileImageURL
{
    if ( [[NSUserDefaults standardUserDefaults] stringForKey:kProfileImageUrl] == nil )
        return @"";
    return [[NSUserDefaults standardUserDefaults] stringForKey:kProfileImageUrl];
}

- (void)setProfileImageURL:(NSString *)profileImageUrl
{
    [[NSUserDefaults standardUserDefaults] setObject:profileImageUrl forKey:kProfileImageUrl];
}

- (NSString *)deviceToken
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kDeviceToken];
}

- (void)setDeviceToken:(NSString *)deviceToken
{
    [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:kDeviceToken];
}

- (NSString *)percentEscapedNickname {
    return [self.nickname stringByAddingPercentEscapesUsingUTF8Encoding];
}

- (BOOL)hasFriend:(NSString*)user_id {
    if(user_id == nil)
        return NO;
    if([self.appFriends containsKey:user_id])
        return YES;
    return [self.friends containsKey:user_id];
}

- (void)sendKakaoLink:(NSString*)user_id {
    if(user_id == nil) {
        return;
    }
    KALinkMessageRequest* request = [KALinkMessageRequest requestWithReceiverID:user_id
                                                                        message:@"친구가 찌찌뽕을 시도합니다."
                                                               executeURLString:@"http://google.com"];
    
    [[KALocalUser localUser] sendLinkMessageWithRequest:request completionHandler:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(success) {
                //카톡앱 전환 링크 todo
                [[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"http://google.com"]];
            } else {
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"상대랑 채팅을 할수 없습니다."
                                                                  message:@"카톡링크 보내기 실패!"
                                                                 delegate:nil
                                                        cancelButtonTitle:@"닫기"
                                                        otherButtonTitles:nil];
                [message show];
            }
        });
    }];
}

@end
