//
//  LFMArtistInfo.m
//  Musica
//
//  Created by Chloe Stars on 2/27/11.
//  Copyright 2011 Ozipto. All rights reserved.
//

#import "LFMArtistInfo.h"
#import "LFMDefines.h"

@implementation LFMArtistInfo

@synthesize delegate;

- (void)requestInfoWithArtist:(NSString*)artist
{
    NSString *urlRequestString = [[NSString alloc] initWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=artist.getinfo&artist=%@&api_key=%@", 
                                  [artist URLEncodedString], kAPIKey];
    NSLog(@"LastFMArtistInfo artist requested: %@", artist);
    NSLog(@"LastFMArtistInfo Requesting from url: %@", urlRequestString);
    // Initialization code here.
	RXMLElement *rootXML = [RXMLElement elementFromURL:[NSURL URLWithString:urlRequestString]];
	
	if ([rootXML isValid]) {
		if ([[rootXML attribute:@"status"] isEqualToString:@"failed"]) {
			RXMLElement *errorElement = [rootXML child:@"error"];
			
			NSMutableDictionary* details = [NSMutableDictionary dictionary];
			[details setValue:errorElement.text forKey:NSLocalizedDescriptionKey];
			
			// populate the error object with the details
			NSError *error = [NSError errorWithDomain:@"ParsingFailed" code:[[errorElement attribute:@"code"] intValue] userInfo:details];
			[[self delegate] didFailToReceiveArtistDetails:error];
			return;
		}
	}
	else {
		// populate the error object with the details
		NSMutableDictionary* details = [NSMutableDictionary dictionary];
		[details setValue:@"Last.fm is likely having issues." forKey:NSLocalizedDescriptionKey];
		
		NSError *error = [NSError errorWithDomain:@"ParsingFailed" code:404 userInfo:details];
		[[self delegate] didFailToReceiveArtistDetails:error];
		return;
	}
	
	[rootXML iterate:@"artist" usingBlock: ^(RXMLElement *e) {
		LFMArtist *artist = [LFMArtist new];
		[artist setName:[e child:@"name"].text];
		[artist setBio:[[e child:@"bio"] child:@"content"].text];
		
		[tagsArray removeAllObjects];
		tagsArray = [NSMutableArray new];
		for (RXMLElement *tag in [[e child:@"tags"] children:@"tag"]) {
			[tagsArray addObject:[tag child:@"name"].text];
		}
		[artist setTags:(NSArray*)tagsArray];
		NSLog(@"tagging:%u", [tagsArray count]);

		for (RXMLElement *image in [e children:@"image"]) {
			if ([[image attribute:@"size"] isEqualToString:@"mega"]) {
				//NSLog(@"url:%@", image.text);
				[artist setImage:[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:image.text]]]];
			}
		}
		[[self delegate] didReceiveArtistInfo:artist];
	}];
	
}

- (void)requestInfoWithMusicBrainzID:(NSString*)mbid {
    NSString *urlRequestString = [[NSString alloc] initWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=artist.getinfo&mbid=%@&api_key=%@",
                                  [mbid URLEncodedString], kAPIKey];
    NSLog(@"LastFMArtistInfo mbid requested: %@", mbid);
    NSLog(@"LastFMArtistInfo Requesting from url: %@", urlRequestString);
    // Initialization code here.
	RXMLElement *rootXML = [RXMLElement elementFromURL:[NSURL URLWithString:urlRequestString]];
	
	if ([rootXML isValid]) {
		if ([[rootXML attribute:@"status"] isEqualToString:@"failed"]) {
			RXMLElement *errorElement = [rootXML child:@"error"];
			
			NSMutableDictionary* details = [NSMutableDictionary dictionary];
			[details setValue:errorElement.text forKey:NSLocalizedDescriptionKey];
			
			// populate the error object with the details
			NSError *error = [NSError errorWithDomain:@"ParsingFailed" code:[[errorElement attribute:@"code"] intValue] userInfo:details];
			[[self delegate] didFailToReceiveArtistDetails:error];
			return;
		}
	}
	else {
		// populate the error object with the details
		NSMutableDictionary* details = [NSMutableDictionary dictionary];
		[details setValue:@"Last.fm is likely having issues." forKey:NSLocalizedDescriptionKey];
		
		NSError *error = [NSError errorWithDomain:@"ParsingFailed" code:404 userInfo:details];
		[[self delegate] didFailToReceiveArtistDetails:error];
		return;
	}
	
	[rootXML iterate:@"artist" usingBlock: ^(RXMLElement *e) {
		LFMArtist *artist = [LFMArtist new];
		[artist setName:[e child:@"name"].text];
		[artist setBio:[[e child:@"bio"] child:@"content"].text];
		
		[tagsArray removeAllObjects];
		tagsArray = [NSMutableArray new];
		for (RXMLElement *tag in [[e child:@"tags"] children:@"tag"]) {
			[tagsArray addObject:[tag child:@"name"].text];
		}
		[artist setTags:(NSArray*)tagsArray];
		NSLog(@"tagging:%u", [tagsArray count]);
		
		for (RXMLElement *image in [e children:@"image"]) {
			if ([[image attribute:@"size"] isEqualToString:@"mega"]) {
				//NSLog(@"url:%@", image.text);
				[artist setImage:[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:image.text]]]];
			}
		}
		[[self delegate] didReceiveArtistInfo:artist];
	}];
}

@end
