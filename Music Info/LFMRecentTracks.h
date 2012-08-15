//
//  LFMRecentTracks.h
//  Music Info
//
//  Created by Chloe Stars on 8/14/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+URLEncoding.h"
#import "LFMTrack.h"

@protocol LFMRecentTracksDelegate <NSObject>
@required
- (void) didReceiveRecentTracks: (LFMTrack*)track;
- (void) didFailToReceiveRecentTracks: (NSError *)error;
@end

@interface LFMRecentTracks : NSObject <NSXMLParserDelegate> {
    id <LFMRecentTracksDelegate> delegate;
    LFMTrack *mostRecentTrack;
    
@private
    NSString *currentElement;
    NSString *currentAttribute;
    NSString *artist;
    NSString *track;
    NSString *musicBrainzID;
    BOOL nowPlaying;
}

@property (strong) id delegate;

- (void)requestInfo:(NSString*)user;
-(NSError *)parseData:(NSData *)info;

@end
