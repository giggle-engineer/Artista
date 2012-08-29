//
//  LFMArtistTopTracks.h
//  Artista
//
//  Created by Chloe Stars on 8/29/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RaptureXML/RXMLElement.h>

@protocol LFMArtistTopTracksDelegate <NSObject>
@required
- (void) didReceiveTopTracks: (NSArray *)albums;
- (void) didFailToReceiveTopTracks: (NSError *)error;
@end

@interface LFMArtistTopTracks : NSObject {
	id <LFMArtistTopTracksDelegate> delegate;
    
@private
	NSMutableArray *tracks;
}

@property (strong) id delegate;

- (void)requestTopTracksWithArtist:(NSString*)artist;
- (void)requestTopTracksWithMusicBrainzID:(NSString*)mbid;

@end