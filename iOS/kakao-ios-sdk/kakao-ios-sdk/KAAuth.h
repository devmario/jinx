//
//  KAAuth.h
//  kakao-ios-sdk
//
//  Created by Arthur Kim on 4/19/12.
//  Copyright (c) 2012 KAKAO Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *const kGuestLoginID;

@class KALocalUser;
@class KAAuthWebLoginController;

@interface KAAuth : NSObject {
@private
    NSString *_clientID;
    NSString *_clientSecret;
    NSString *_redirectURL;
    NSString *_accessToken;
    NSString *_refreshToken;

    void(^_authenticationCompletionHandler)(NSError*);
    void(^_guestLoginCompletionHandler)(NSError*);
    
    struct {
        unsigned int isExtendingAccessToken:1;
    } _authFlags;
    
    NSMutableArray *_pendingRequests;
    
    dispatch_queue_t _queue;
    
    KAAuthWebLoginController *_webLoginController;
    BOOL _guestLoggedOn;
}

@property (nonatomic, readonly) NSString *clientID;
@property (nonatomic, readonly) NSString *clientSecret;
@property (nonatomic, readonly) NSString *redirectURL;
@property (nonatomic, readonly, copy) NSString *accessToken;
@property (nonatomic, readonly, copy) NSString *refreshToken;

/* Designated initializer */
- (id)initWithClientID:(NSString *)clientID 
          clientSecret:(NSString *)clientSecret
           redirectURL:(NSString *)redirectURL
           accessToken:(NSString *)accessToken
          refreshToken:(NSString *)refreshToken;

+ (KAAuth *)sharedAuth;

// Your application must assign the sharedKakao before using any Kakao features.
+ (void)setSharedAuth:(KAAuth *)auth;

- (BOOL)handleOpenURL:(NSURL *)url;

- (void)registerWithCompletionHandler:(void(^)(NSError *error))completionHandler;

- (void)cancelRegistration;
- (void)clearRegistration;

- (void)sendAPIRequestWithMethod:(NSString *)method
                      parameters:(NSDictionary *)parameters
                            post:(BOOL )post
               completionHandler:(void(^)(NSDictionary *response, NSError *error))completionHandler;

- (void)sendUploadAPIRequestWithUIImage:(UIImage *)image
                      completionHandler:(void(^)(NSDictionary *response, NSError *error))completionHandler;


@property (nonatomic, readonly, getter = isAuthenticated) BOOL authenticated;
@property (nonatomic, strong) NSString *deviceToken;

//Guest Login
- (NSString*)oldUser;
- (void)guestLogout;
- (void)unregisterGuestUserID;
- (void)guestLoginWithCompletionHandler:(void(^)(NSError* error))completionHandler;
@property (nonatomic, readonly, getter = isGuestLoggedOn) BOOL guestLoggedOn;

@end

// notifications
extern NSString *const KAAuthenticationDidChangeNotification;
