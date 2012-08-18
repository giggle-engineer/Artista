//
//  LFMTrackInfo.h
//  Artista
//
//  Created by Chloe Stars on 8/17/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LFMTrack.h"

@protocol LFMTrackInfoDelegate <NSObject>
@required
- (void) didReceiveTrackInfo: (LFMTrack*)track;
- (void) didFailToReceiveTrackInfo: (NSError *)error;
@end

@interface LFMTrackInfo : NSObject <NSXMLParserDelegate> {
    id <LFMTrackInfoDelegate> delegate;
    LFMTrack *mostRecentTrack;
    
@private
    NSString *currentElement;
    NSString *currentAttribute;
    NSString *album;
    UIImage *artwork;
}

@property (strong) id delegate;

- (void)requestInfo:(NSString*)artist withTrack:(NSString*)track;
-(NSError *)parseData:(NSData *)info;

@end
