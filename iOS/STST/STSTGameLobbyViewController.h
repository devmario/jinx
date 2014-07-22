//
//  STSTGameLobbyViewController.h
//  STST
//
//  Created by 이 춘원 on 13. 5. 21..
//  Copyright (c) 2013년 vanillabreeze. All rights reserved.
//

#import "API.h"
#import "STSTViewController.h"

@interface STSTGameLobbyViewController : STSTViewController <APIGameDelegate, APILobbyDelegate>

- (void)reloadLobby;

- (IBAction)clickPrev:(id)sender;

@end
