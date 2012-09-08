//
//  LFMArtistTopAlbums.h
//  Artista
//
//  Created by Chloe Stars on 8/27/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RaptureXML/RXMLElement.h>
#import "LFMAlbum.h"

@protocol LFMArtistTopAlbumsDelegate <NSObject>
@required
- (void) didReceiveTopAlbums: (NSArray *)albums;
- (void) didFailToReceiveTopAlbums: (NSError *)error;
- (void) didFinishReceivingTopAlbums: (NSArray *)albums;
@end

@interface LFMArtistTopAlbums : NSObject <NSXMLParserDelegate> {
	id <LFMArtistTopAlbumsDelegate> delegate;
    
@private
	//NSMutableArray *albums;
}

@property (strong) id delegate;

- (void)requestTopAlbumsWithArtist:(NSString*)artist;
- (void)requestTopAlbumsWithMusicBrainzID:(NSString*)mbid;

@end
