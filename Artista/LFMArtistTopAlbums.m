//
//  LFMArtistTopAlbums.m
//  Artista
//
//  Created by Chloe Stars on 8/27/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import "LFMArtistTopAlbums.h"
#import "NSString+URLEncoding.h"
#import "LFMDefines.h"

@implementation LFMArtistTopAlbums
@synthesize delegate;

// http://ws.audioscrobbler.com/2.0/?method=artist.gettopalbums&artist=Nadia%20Ali&api_key=b25b959554ed76058ac220b7b2e0a026

- (void)requestTopAlbumsWithURL:(NSString*)urlRequestString
{
	// Initialization code here.
	NSMutableArray *albums = [NSMutableArray new];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlRequestString]];
	NSError *connectionError;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&connectionError];
	RXMLElement *rootXML = [RXMLElement elementFromXMLData:data];
	
	if ([rootXML isValid]) {
		if ([[rootXML attribute:@"status"] isEqualToString:@"failed"]) {
			RXMLElement *errorElement = [rootXML child:@"error"];
			
			NSMutableDictionary* details = [NSMutableDictionary dictionary];
			[details setValue:errorElement.text forKey:NSLocalizedDescriptionKey];
			
			// populate the error object with the details
			NSError *error = [NSError errorWithDomain:@"ParsingFailed" code:[[errorElement attribute:@"code"] intValue] userInfo:details];
			[[self delegate] didFailToReceiveTopAlbums:error];
			return;
		}
	}
	else {
		// populate the error object with the details
		NSMutableDictionary* details = [NSMutableDictionary dictionary];
		[details setValue:@"Last.fm is likely having issues." forKey:NSLocalizedDescriptionKey];
		
		NSError *error = [NSError errorWithDomain:@"ParsingFailed" code:404 userInfo:details];
		[[self delegate] didFailToReceiveTopAlbums:error];
		return;
	}
	
	[rootXML iterate:@"topalbums.album" usingBlock: ^(RXMLElement *e) {
		LFMAlbum *album = [LFMAlbum new];
		[album setName:[e child:@"name"].text];
		
		for (RXMLElement *image in [e children:@"image"]) {
			if ([[image attribute:@"size"] isEqualToString:@"large"]) {
				//NSLog(@"url:%@", image.text);
				[album setURL:[NSURL URLWithString:image.text]];
				//[album setArtwork:[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:image.text]]]];
			}
		}
		// TODO: Have the adding to the array be done on the view controller through the delegate
		[albums addObject:album];
		//[[self delegate] didReceiveTopAlbums:(NSArray*)[albums copy]];
	}];
	
	//NSLog(@"albums count:%d", [albums count]);
    [[self delegate] didFinishReceivingTopAlbums:(NSArray*)[albums copy]];
	//[albums removeAllObjects];
}

- (void)requestTopAlbumsWithArtist:(NSString*)artist
{
    NSString *urlRequestString = [[NSString alloc] initWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=artist.gettopalbums&artist=%@&api_key=%@",
                                  [artist URLEncodedString], kAPIKey];
    //NSLog(@"LFMArtistTopAlbums artist requested: %@", artist);
    //NSLog(@"LFMArtistTopAlbums Requesting from url: %@", urlRequestString);
	[self requestTopAlbumsWithURL:urlRequestString];
}

- (void)requestTopAlbumsWithMusicBrainzID:(NSString*)mbid
{
    NSString *urlRequestString = [[NSString alloc] initWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=artist.gettopalbums&mbid=%@&api_key=%@",
                                  [mbid URLEncodedString], kAPIKey];
    //NSLog(@"LFMArtistTopAlbums artist requested: %@", mbid);
    //NSLog(@"LFMArtistTopAlbums Requesting from url: %@", urlRequestString);
	[self requestTopAlbumsWithURL:urlRequestString];
}

@end
