//
//  GoogleTalk.m
//  sound_google
//
//  Created by Mac on 13. 5. 23..
//  Copyright (c) 2013년 com.vanillabreeze. All rights reserved.
//

#import "GoogleTalk.h"

id share_talk = nil;

@implementation GoogleTalk

+ (void)initialize {
    if (self == [GoogleTalk class]) {
        share_talk = [[GoogleTalk alloc] init];
    }
}

- (id)init {
    self = [super init];
    arr_con = [[NSMutableArray alloc] init];
    return self;
}

+ (id)talk {
    return share_talk;
}

- (NSMutableData*)checkFile:(NSString*)_str {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:_str];
    
    FILE* f = fopen(filePath.UTF8String, "rb");
    if(f == NULL)
        return nil;
    fseek(f, 0, SEEK_END);
    size_t size = ftell(f);
    fseek(f, 0, SEEK_SET);
    void* mem = malloc(size);
    fread(mem, size, 1, f);
    fclose(f);
    
    NSMutableData* data = [[NSMutableData alloc] init];
    [data appendBytes:mem length:size];
    
    free(mem);
    
    return data;
}

- (void)writeFile:(NSMutableData*)data str:(NSString*)_str {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:_str];
    
    FILE* f = fopen(filePath.UTF8String, "wb");
    fwrite([data bytes], 1, [data length], f);
    fclose(f);
}

- (void)play:(NSMutableData*)_data {
    NSError* error = nil;
    AVAudioPlayer* player = [[AVAudioPlayer alloc] initWithData:_data error:&error];
    player.delegate = self;
    [player play];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [player release];
}

- (void)addConnection:(NSURLConnection*)_connection str:(NSString*)str {
    NSMutableData* _data = [[NSMutableData alloc] init];
    NSMutableDictionary* _dict = [[NSMutableDictionary alloc] init];
    [_dict setObject:str forKey:@"str"];
    [_dict setObject:_connection forKey:@"connection"];
    [_dict setObject:_data forKey:@"data"];
    [arr_con addObject:_dict];
    [_dict release];
    [_data release];
}

- (NSMutableDictionary*)getDict:(NSURLConnection*)_connection {
    for(int i = 0; i < [arr_con count]; i++) {
        return [arr_con objectAtIndex:i];
    }
    return nil;
}

- (void)endConnection:(NSURLConnection*)_connection fail:(BOOL)_fail {
    NSMutableDictionary* dict = [self getDict:_connection];
    NSMutableData* data = [dict objectForKey:@"data"];
    //play sound
    if(_fail == NO) {
        [self writeFile:data str:[dict objectForKey:@"str"]];
        [self play:data];
    }
    [arr_con removeObject:dict];
}

- (void)play:(NSString*)_str contry:(NSString*)code {
    CFStringRef urlString = CFURLCreateStringByAddingPercentEscapes(
                                                                    NULL,
                                                                    (CFStringRef)_str,
                                                                    NULL,
                                                                    (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                    kCFStringEncodingUTF8 );
    _str = [(NSString *)urlString autorelease];
    NSMutableData* _data = [self checkFile:_str];
    if(_data == nil) {
        NSURLConnection* connecton = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://translate.google.com/translate_tts?ie=UTF-8&q=%@&tl=%@&total=1&idx=0&textlen=%d&prev=input", _str, code, _str.length]]] delegate:self startImmediately:NO];
        [self addConnection:connecton str:_str];
        [connecton start];
        [connecton release];
    } else {
        [self play:_data];
        [_data release];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [[[self getDict:connection] objectForKey:@"data"] appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self endConnection:connection fail:NO];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self endConnection:connection fail:YES];
}

@end