//
//  KALocalUser.h
//  kakao-ios-sdk
//
//  Created by Insoo Kim on 4/22/12.
//  Copyright (c) 2012 KAKAO Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KALinkMessageRequest;

typedef void(^KACompletionResponseBlock)(NSDictionary *response, NSError *error);
typedef void(^KACompletionSuccessBlock)(BOOL success, NSError *error);

@interface KALocalUser : NSObject 
+ (KALocalUser*)localUser;

- (void)loadLocalUserWithCompletionHandler:(KACompletionResponseBlock)completionHandler;

- (void)loadFriendsWithCompletionHandler:(KACompletionResponseBlock)completionHandler;
 
- (void)sendLinkMessageWithRequest:(KALinkMessageRequest *)request completionHandler:(KACompletionSuccessBlock)completionHandler;

- (void)unregisterWithCompletionHandler:(KACompletionSuccessBlock)completionHandler;

- (void)logoutWithCompletionHandler:(KACompletionSuccessBlock)completionHandler;

@end

@interface KALocalUser(Push)

- (BOOL)hasValidDeviceToken;

- (void)registerDeviceTokenWithCompletionHandler:(KACompletionResponseBlock) completionHandler;

- (void)getPushInfoWithCompletionHandler:(KACompletionResponseBlock)completionHandler;

- (void)setPushAlert:(BOOL)pushAlert withCompletionHandler:(KACompletionResponseBlock)completionHandler;

- (void)sendPushToReceiverId:(NSString *)receiverId
                     message:(NSString *)message
                 customField:(NSDictionary *)customField
       withCompletionHandler:(KACompletionResponseBlock)completionHandler;

@end

extern NSString* const PlatformKey;
extern NSString* const PriceKey;
extern NSString* const CurrencyKey;

@interface KALocalUser(Payment)
- (void)sendPaymentInfo:(NSDictionary*)paymentInfo withCompletionHandler:(KACompletionResponseBlock)completionHandler;
@end