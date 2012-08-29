//
//  LFMArtistTopTracks.m
//  Artista
//
//  Created by Chloe Stars on 8/29/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import "LFMArtistTopTracks.h"
#import "NSString+URLEncoding.h"

#define kLastFMKey @"b25b959554ed76058ac220b7b2e0a026"

@implementation LFMArtistTopTracks
@synthesize delegate;

// http://ws.audioscrobbler.com/2.0/?method=artist.gettoptracks&artist=cher&api_key=b25b959554ed76058ac220b7b2e0a026

- (void)requestTopTracksWithArtist:(NSString*)artist {
	NSString *urlRequestString = [[NSString alloc] initWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=artist.gettoptracks&artist=%@&api_key=%@",
                                  [artist URLEncodedString], kLastFMKey];
    NSLog(@"LFMArtistTopTracks artist requested: %@", artist);
    NSLog(@"LFMArtistTopTracks Requesting from url: %@", urlRequestString);
    // Initialization code here.
	tracks = [NSMutableArray new];
	
	RXMLElement *rootXML = [RXMLElement elementFromURL:[NSURL URLWithString:urlRequestString]];
	
	[rootXML iterate:@"toptracks.track" usingBlock: ^(RXMLElement *e) {
		[tracks addObject:[e child:@"name"].text];
	}];
	NSLog(@"tracks count:%d", [tracks count]);
    [[self delegate] didReceiveTopTracks:(NSArray*)[tracks copy]];
	[tracks removeAllObjects];
}

- (void)requestTopTracksWithMusicBrainzID:(NSString*)mbid {
	NSString *urlRequestString = [[NSString alloc] initWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=artist.gettoptracks&mbid=%@&api_key=%@",
                                  [mbid URLEncodedString], kLastFMKey];
    NSLog(@"LFMArtistTopTracks artist requested: %@", mbid);
    NSLog(@"LFMArtistTopTracks Requesting from url: %@", urlRequestString);
    // Initialization code here.
	tracks = [NSMutableArray new];
	
	RXMLElement *rootXML = [RXMLElement elementFromURL:[NSURL URLWithString:urlRequestString]];
	
	[rootXML iterate:@"toptracks.track" usingBlock: ^(RXMLElement *e) {
		[tracks addObject:[e child:@"name"].text];
	}];
	NSLog(@"tracks count:%d", [tracks count]);
    [[self delegate] didReceiveTopTracks:(NSArray*)[tracks copy]];
	[tracks removeAllObjects];
}

@end