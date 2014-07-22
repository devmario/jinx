//
//  STSTAppDelegate.m
//  STST
//
//  Created by 이 춘원 on 13. 5. 20..
//  Copyright (c) 2013년 vanillabreeze. All rights reserved.
//

#import "STSTAppDelegate.h"

#import "STSTLoadingViewController.h"
#import "STSTLoadUserInfoViewController.h"
#import "STSTIntroViewController.h"
#import "STSTGameLobbyViewController.h"
#import "STSTGameViewController.h"
#import "STSTActivityIndicatorView.h"

#import "STSTUser.h"

#import "Kakao.h"
static NSString *const kClientSecret = @"P047ZZPJLbeKc7menDrCCsMjvCQqeCia3SdHuWd6v/dddJ/L9Gh+kisWqcZ7r5mrQlrLXLYjJdnXwvPLl42bzQ==";

static NSString *const kClientID = CLIENT_ID;
static NSString *const kRedirectURL = @"kakao" CLIENT_ID @"://exec";

@interface STSTAppDelegate () <STSTIntroViewControllerDelegate>

@property (nonatomic, retain) NSString *apiName;
@property (nonatomic, retain) NSMutableData *webData;
@property(nonatomic, assign) SEL action;

@property BOOL useNetwork;

- (void)runAction;

@end

@implementation STSTAppDelegate

- (void)runAction {
    if (self.action) {
        [self performSelector:self.action];
        self.action = nil;
    }
}

- (STSTNavigationViewController *)navigationController {
    return (id)self.window.rootViewController;
}

- (STSTViewController *)viewController {
    return (id)self.navigationController.topViewController;
}

- (void)setupKakao
{
    STSTKakaoUser *user = [STSTKakaoUser user];
    KAAuth *kakao = [[KAAuth alloc] initWithClientID:kClientID
                                        clientSecret:kClientSecret
                                         redirectURL:kRedirectURL
                                         accessToken:user.accessToken
                                        refreshToken:user.refreshToken];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kakaoAuthenticationDidChangeWithNotification:)
                                                 name:KAAuthenticationDidChangeNotification
                                               object:kakao];
    [KAAuth setSharedAuth:kakao];
}

- (void)showViewController {
    STSTKakaoUser *user = [STSTKakaoUser user];

    if ([KAAuth sharedAuth].authenticated) {
        [[KALocalUser localUser] loadLocalUserWithCompletionHandler:^(NSDictionary *userInfo, NSError *error) {
            if (userInfo) {
                user.userID = [userInfo :@"user_id"];
                user.nickname = [userInfo :@"nickname"];
                user.profileImageURL = [userInfo :@"profile_image_url"];
            } else {
                // 로그인 화면 표시
                self.action = @selector(showIntro);
                if (self.viewController.loaded) {
                    [self runAction];
                }
            }
        }];
        [[KALocalUser localUser] loadFriendsWithCompletionHandler:^(NSDictionary *friendsInfo, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{ // XXX:??
                if (!error) {
                    NSAMutableOrderedDictionary *dic = [NSAMutableOrderedDictionary dictionary];
                    [[friendsInfo objectForKey:@"friends_info"] applyProcedure:^(id obj) {
                        KakaoUser *user = [KakaoUser objectWithDictionary:obj];
                        [dic setObject:user forKey:user.ID];
                    }];
                    user.friends = dic;
                    
                    dic = [NSAMutableOrderedDictionary dictionary];
                    [[friendsInfo objectForKey:@"app_friends_info"] applyProcedure:^(id obj) {
                        KakaoUser *user = [KakaoUser objectWithDictionary:obj];
                        [dic setObject:user forKey:user.ID];
                    }];
                    user.appFriends = dic;
                    //[(STSTGameLobbyViewController *)self.window.rootViewController reloadLobby];
                    NSLog(@"appdelegate total friends : %d", [user.friends count]);
                    //
                    self.action = @selector(showGameLobby);
                    if (self.viewController.loaded) {
                        [self runAction];
                    }
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Progress" message:[NSString stringWithFormat:@"friends load failed with error : %@", error]
                                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    [alert release];
                }
            });
        }];
        NSLog(@"Login");
    } else {
        // 로그인 화면 표시
        self.action = @selector(showIntro);
        NSLog(@"Logout");
    }
}

- (void)showGameLobby
{
    NSLog(@"Scene : Game Lobby");
    UIViewController *viewController = [[[STSTGameLobbyViewController alloc] initWithPlatformSuffixedNibName:@"STSTGameLobbyViewController" bundle:nil] autorelease];
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)showLoadUserInfo
{
    NSLog(@"Scene : LoadUserInfo");
    UIViewController *viewController = [[[STSTLoadUserInfoViewController alloc] initWithPlatformSuffixedNibName:@"STSTLoadUserInfoViewController" bundle:nil] autorelease];
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)showIntro
{
    NSLog(@"Scene : Intro");
    UIViewController *viewController = [[[STSTIntroViewController alloc] initWithPlatformSuffixedNibName:@"STSTIntroViewController" bundle:nil] autorelease];
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    STSTKakaoUser *user = [STSTKakaoUser user];

    self.useNetwork = NO;
    [self setupKakao];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    STSTViewController *viewControllrer = [[[STSTLoadingViewController alloc] initWithPlatformSuffixedNibName:@"STSTLoadingViewController" bundle:nil] autorelease];
    STSTNavigationViewController *nvc = [[[STSTNavigationViewController alloc] initWithRootViewController:viewControllrer] autorelease];
    nvc.headerView = [STSTHeader header];
    nvc.headerView.navigationController = nvc;
    [nvc setNavigationBarHidden:YES];
    [nvc.view addSubview:nvc.headerView];
    nvc.headerView.bouncing = [[[NSUserDefaults standardUserDefaults] objectForKey:@"STSTHeaderBounce"] boolValue];

    // 카카오톡 정보 불러오기 전까지 로딩 표시
    self.window.rootViewController = nvc;
    [self.window makeKeyAndVisible];

    nvc.headerView.frame = CGRectMake(.0, -1.0, self.window.frame.size.width, 1.0);

    self.activityIndicatorView = [[[STSTActivityIndicatorView alloc] initWithNibName:@"STSTActivityIndicatorView" bundle:nil] autorelease];
    self.activityIndicatorView.center = self.window.center;
    [self.window addSubview:self.activityIndicatorView];
    [self.activityIndicatorView pushAnimated:YES];

    NSURL *launchURL = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
	if (launchOptions) {
		[[KAAuth sharedAuth] handleOpenURL:launchURL];
	}
    
    [self showViewController];
    
    if (user.deviceToken == nil) {
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSLog(@"application handleOpenURL:(%@)", url);
#ifdef DEBUG
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:[NSString stringWithFormat:@"%@", url]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
#endif
    
    [self checkURL:url];
    return [[KAAuth sharedAuth] handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"application openURL:(%@) sourceApplication:(%@) annotation:(%@)", url, sourceApplication, annotation);
#ifdef DEBUG
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:[NSString stringWithFormat:@"%@", url]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
#endif
    
    [self checkURL:url];
    return [[KAAuth sharedAuth] handleOpenURL:url];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    STSTKakaoUser *user = [STSTKakaoUser user];

    user.deviceToken = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""]
                           stringByReplacingOccurrencesOfString:@">" withString:@""]
                          stringByReplacingOccurrencesOfString: @" " withString: @""];
    [KAAuth sharedAuth].deviceToken = [deviceToken description];
    NSLog(@"push token %@", user.deviceToken);
    if ( [KAAuth sharedAuth].authenticated )
    {
        [[KALocalUser localUser] registerDeviceTokenWithCompletionHandler:^(NSDictionary *response, NSError *error) {
            
        }];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	NSLog(@"Fail to Register PushToken");
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"%@", [[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"body"]);
    /*
     aps={alert={body="Welcome!";};};}
	if ( [[userInfo objectForKey:@"body"] isEqualToString:@"ad"] ){
		// advertise
		// load recent app information
	}else if ( [[userInfo objectForKey:@"mode"] isEqualToString:@"fc"] ){
		// forecast
		// load current forecast data
	}
     */
}

#pragma mark - call update screen
- (void)updateLobby
{
    
}

- (void)updateGame:(NSString *)gameId
{
    
}

#pragma mark - call web api

- (void)sendUserInfo {
    STSTKakaoUser *user = [STSTKakaoUser user];
    
    NSLog(@"sendUserInfo");
    if ( !self.useNetwork ) {
        self.useNetwork = YES;
        self.apiName = @"sendUserInfo";
        NSURL *url = [@"http://ec2-54-214-154-148.us-west-2.compute.amazonaws.com/?uid=%@&nickname=%@&picture=%@&token=%@" format:user.userID, user.nickname, user.profileImageURL, user.deviceToken].URL;
        NSLog(@"%@", [NSString stringWithFormat:@"http://ec2-54-214-154-148.us-west-2.compute.amazonaws.com/?uid=%@&nickname=%@&picture=%@&token=%@", user.userID, user.nickname, user.profileImageURL, user.deviceToken]);
        NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
        [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [theRequest setHTTPMethod:@"GET"];
        
        NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        
        if( theConnection )
        {
            self.webData = [NSMutableData data];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection error" message:@"There was a problem connecting to Server. Please make sure that you have internet connectivity and try again later."
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Progress" message:@"Please Wait"
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (void)receiveGameList {
    STSTKakaoUser *user = [STSTKakaoUser user];

    NSLog(@"receiveGameList");
    if ( !self.useNetwork ) {
        self.useNetwork = YES;
        self.apiName = @"receiveGameList";
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ec2-54-214-154-148.us-west-2.compute.amazonaws.com/?uid=%@", user.userID]];
        NSLog(@"%@", [NSString stringWithFormat:@"http://ec2-54-214-154-148.us-west-2.compute.amazonaws.com/?uid=%@", user.userID]);
        NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
        [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [theRequest setHTTPMethod:@"GET"];
        
        NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        
        if( theConnection )
        {
            self.webData = [NSMutableData data];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection error" message:@"There was a problem connecting to Server. Please make sure that you have internet connectivity and try again later."
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Progress" message:@"Please Wait"
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (void)receiveGameInfo:(NSString *)gid
{
    NSLog(@"receiveGameInfo");
    if ( !self.useNetwork ) {
        self.useNetwork = YES;
        self.apiName = @"receiveGameInfo";
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ec2-54-214-154-148.us-west-2.compute.amazonaws.com/get?gid=%@", gid]];
        NSLog(@"%@", [NSString stringWithFormat:@"http://ec2-54-214-154-148.us-west-2.compute.amazonaws.com/get?gid=%@", gid]);
        NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
        [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [theRequest setHTTPMethod:@"GET"];
        
        NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        
        if( theConnection )
        {
            self.webData = [NSMutableData data];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection error" message:@"There was a problem connecting to Server. Please make sure that you have internet connectivity and try again later."
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Progress" message:@"Please Wait"
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (void)sendGameMessage:(NSString *)message toId:(NSString *)toId toNick:(NSString *)toNick toPicture:(NSString *)toPicture
{
    STSTKakaoUser *user = [STSTKakaoUser user];
    NSLog(@"sendGameMessage");
    if ( !self.useNetwork ) {
        self.useNetwork = YES;
        self.apiName = @"sendGameMessage";
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ec2-54-214-154-148.us-west-2.compute.amazonaws.com/send?uid=%@&toid=%@&message=%@&tonickname=%@&topicture=%@", user.userID, toId, message, toNick, toPicture]];
        NSLog(@"%@", [NSString stringWithFormat:@"http://ec2-54-214-154-148.us-west-2.compute.amazonaws.com/send?uid=%@&toid=%@&message=%@&tonickname=%@&topicture=%@", user.userID, toId, message, toNick, toPicture]);
        NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
        [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [theRequest setHTTPMethod:@"GET"];
        
        NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        
        if( theConnection )
        {
            self.webData = [NSMutableData data];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection error" message:@"There was a problem connecting to Server. Please make sure that you have internet connectivity and try again later."
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Progress" message:@"Please Wait"
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (void)sendPush
{
    STSTKakaoUser *user = [STSTKakaoUser user];
    
    NSLog(@"sendPush");
    if ( !self.useNetwork ) {
        self.useNetwork = YES;
        self.apiName = @"sendPush";
        NSURL *url = [NSURL URLWithString:@"http://23.21.176.223:8080/send"];
        NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
        NSString *encodedParameterPairs;
        NSString *message = @"{'aps':{'alert':{'body':'Welcome!'}}}";
        if (user.deviceToken != nil){
            // update
            encodedParameterPairs = [NSString stringWithFormat:@"id=stst&mode=sandbox&secret=100kpd&platform=ios&token=%@&message=%@", user.deviceToken, message];
        } else {
            // insert
            encodedParameterPairs = [NSString stringWithFormat:@"id=stst&mode=sandbox&secret=100kpd&platform=ios&token=%@&message=%@", user.deviceToken, message];
        }
        NSData *requestData = [encodedParameterPairs dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        
        [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [theRequest setHTTPMethod:@"POST"];
        [theRequest setHTTPBody:requestData];
        [theRequest setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
        [theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        
        if( theConnection ) {
            self.webData = [NSMutableData data];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection error" message:@"There was a problem connecting to Server. Please make sure that you have internet connectivity and try again later."
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Progress" message:@"Please Wait"
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"didReceiveResponse");
	[self.webData setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"didReceiveData");
	[self.webData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError : %@", error);
    self.useNetwork = NO;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection error" message:@"There was a problem connecting to Server. Please make sure that you have internet connectivity and try again later."
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
	[connection release];
	self.webData = nil;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"connectionDidFinishLoading");
    self.useNetwork = NO;
    NSData *returnedData = self.webData;
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:returnedData options:0 error:&error];
    self.receivedData = object;

    if ( [self.apiName isEqualToString:@"sendUserInfo"] ){
        //
        [self showGameLobby];
    }else if ( [self.apiName isEqualToString:@"receiveGameList"] ){
        //
    }else if ( [self.apiName isEqualToString:@"receiveGameInfo"] ){
        //
    }else if ( [self.apiName isEqualToString:@"sendGameMessage"] ){
        //
    }else if ( [self.apiName isEqualToString:@"sendPush"] ){
        //
    }
	[connection release];
	self.webData = nil;
}

#pragma mark - notifications

- (void)kakaoAuthenticationDidChangeWithNotification:(NSNotification *)notification
{
    STSTKakaoUser *user = [STSTKakaoUser user];
    
    user.accessToken = [KAAuth sharedAuth].accessToken;
    user.refreshToken = [KAAuth sharedAuth].refreshToken;
    
    [self showViewController];
}

#pragma mark - chattingplus purpose
- (void)checkURL:(NSURL*)url
{
    STSTKakaoUser *user = [STSTKakaoUser user];
    
    NSDictionary *params = [self deserializedDictionaryWithString:url.query];
    NSString *title = [params objectForKey:@"title"];
    NSString *chatRoomId = [params objectForKey:@"chatRoomId"];
    NSString *userNames = [params objectForKey:@"userNames"];
    
    if (title && chatRoomId)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:[NSString stringWithFormat:@"title:%@\nchatRoomId:%@\nuserNames:%@", title, chatRoomId, userNames]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        user.chatID = chatRoomId;
        user.chatTitle = title;
        user.chatUserNames = userNames;
    }
}

#pragma mark - KakaoAuthLoginViewControllerDelegate

- (void)authLoginViewControllerdidFinishLogin:(STSTIntroViewController *)authLoginViewController
{
    NSLog(@"login finish");//[self showAuthTestView];
}

#pragma mark - KakaoAuthMainViewControllerDelegate

- (void)authMainViewControllerDidLogout:(STSTIntroViewController *)authMainViewController
{
    NSLog(@"logout finish");//[self showLoginView];
}

#pragma mark - url parsing

- (NSDictionary *)deserializedDictionaryWithString:(NSString*)urlString
{
    NSMutableDictionary *resultDictionary = [NSMutableDictionary dictionary];
	for ( NSString *query in [urlString componentsSeparatedByString:@"&"] )
	{
		NSArray *pair = [query componentsSeparatedByString:@"="];
        if ( pair.count >= 2  )
            [resultDictionary setObject:[[pair objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]  forKey:[pair objectAtIndex:0]];
	}
	return resultDictionary;
}

@end
