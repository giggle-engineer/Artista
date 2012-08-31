//
//  LFMArtistTopAlbums.m
//  Artista
//
//  Created by Chloe Stars on 8/27/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import "LFMArtistTopAlbums.h"
#import "NSString+URLEncoding.h"

#define kLastFMKey @"b25b959554ed76058ac220b7b2e0a026"

@implementation LFMArtistTopAlbums
@synthesize delegate;

// http://ws.audioscrobbler.com/2.0/?method=artist.gettopalbums&artist=Nadia%20Ali&api_key=b25b959554ed76058ac220b7b2e0a026

- (void)requestTopAlbumsWithArtist:(NSString*)artist
{
    NSString *urlRequestString = [[NSString alloc] initWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=artist.gettopalbums&artist=%@&api_key=%@",
                                  [artist URLEncodedString], kLastFMKey];
    NSLog(@"LFMArtistTopAlbums artist requested: %@", artist);
    NSLog(@"LFMArtistTopAlbums Requesting from url: %@", urlRequestString);
    // Initialization code here.
	NSMutableArray *albums = [NSMutableArray new];
	
	RXMLElement *rootXML = [RXMLElement elementFromURL:[NSURL URLWithString:urlRequestString]];
	
	[rootXML iterate:@"topalbums.album" usingBlock: ^(RXMLElement *e) {
		LFMAlbum *album = [LFMAlbum new];
		[album setName:[e child:@"name"].text];
		for (RXMLElement *image in [e children:@"image"]) {
			if ([[image attribute:@"size"] isEqualToString:@"extralarge"]) {
				//NSLog(@"url:%@", image.text);
				[album setArtwork:[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:image.text]]]];
			}
		}
		[albums addObject:album];
	}];
	NSLog(@"albums count:%d", [albums count]);
    [[self delegate] didReceiveTopAlbums:(NSArray*)[albums copy]];
	//[albums removeAllObjects];
}

- (void)requestTopAlbumsWithMusicBrainzID:(NSString*)mbid
{
    NSString *urlRequestString = [[NSString alloc] initWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=artist.gettopalbums&mbid=%@&api_key=%@",
                                  [mbid URLEncodedString], kLastFMKey];
    NSLog(@"LFMArtistTopAlbums artist requested: %@", mbid);
    NSLog(@"LFMArtistTopAlbums Requesting from url: %@", urlRequestString);
    // Initialization code here.
	NSMutableArray *albums = [NSMutableArray new];
	
	RXMLElement *rootXML = [RXMLElement elementFromURL:[NSURL URLWithString:urlRequestString]];
	
	[rootXML iterate:@"topalbums.album" usingBlock: ^(RXMLElement *e) {
		LFMAlbum *album = [LFMAlbum new];
		[album setName:[e child:@"name"].text];
		for (RXMLElement *image in [e children:@"image"]) {
			if ([[image attribute:@"size"] isEqualToString:@"extralarge"]) {
				//NSLog(@"url:%@", image.text);
				[album setArtwork:[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:image.text]]]];
			}
		}
		[albums addObject:album];
	}];
	NSLog(@"albums count:%d", [albums count]);
    [[self delegate] didReceiveTopAlbums:(NSArray*)[albums copy]];
	[albums removeAllObjects];
}

@end
