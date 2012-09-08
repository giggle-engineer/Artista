//
//  LFMRecentTracks.h
//  Music Info
//
//  Created by Chloe Stars on 8/14/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RaptureXML/RXMLElement.h>
#import "NSString+URLEncoding.h"
#import "LFMTrack.h"

@protocol LFMRecentTracksDelegate <NSObject>
@required
- (void) didReceiveRecentTracks: (NSArray*)tracks;
- (void) didFailToReceiveRecentTracks: (NSError *)error;
@end

@interface LFMRecentTracks : NSObject <NSXMLParserDelegate> {
    id <LFMRecentTracksDelegate> delegate;
}

@property (strong) id delegate;

- (void)requestInfo:(NSString*)user;
-(NSError *)parseData:(NSData *)info;

@end
