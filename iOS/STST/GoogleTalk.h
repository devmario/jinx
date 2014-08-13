//
//  GoogleTalk.h
//  sound_google
//
//  Created by Mac on 13. 5. 23..
//  Copyright (c) 2013년 com.vanillabreeze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface GoogleTalk : NSObject<AVAudioPlayerDelegate> {
    NSMutableArray* arr_con;
}

+ (id)talk;

//http://translate.google.com/#en/ko/
//guide contry code
- (void)play:(NSString*)_str contry:(NSString*)code;

@end