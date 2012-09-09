//
//  LFMArtistInfo.h
//  Musica
//
//  Created by Chloe Stars on 2/27/11.
//  Copyright 2011 Ozipto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RaptureXML/RXMLElement.h>
#import "LFMArtist.h"
#import "NSString+URLEncoding.h"

@protocol LFMArtistInfoDelegate <NSObject>
@required
- (void) didReceiveArtistInfo: (LFMArtist *)artist;
- (void) didFailToReceiveArtistDetails: (NSError *)error;
@end

@interface LFMArtistInfo : NSObject <NSXMLParserDelegate> {
    id <LFMArtistInfoDelegate> delegate;
    
    @private
	NSMutableArray *tagsArray;
}

@property (strong) id delegate;

- (void)requestInfoWithArtist:(NSString*)artist;
- (void)requestInfoWithMusicBrainzID:(NSString*)mbid;
-(NSError *)parseData:(NSData *)info;

@end
