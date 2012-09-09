//
//  ArtistaTests.h
//  Artista
//
//  Created by Chloe Stars on 8/14/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "LFM.h"

@interface ArtistaTests : SenTestCase <LFMArtistInfoDelegate> {
	LFMArtistInfo *lfmArtistInfo;
	LFMArtistTopAlbums *lfmArtistTopAlbums;
	LFMArtistTopTracks *lfmArtistTopTracks;
	LFMRecentTracks *lfmRecentTracks;
	LFMTrackInfo *lfmTrackInfo;
}

@end
