//
//  LFMTrackInfo.m
//  Artista
//
//  Created by Chloe Stars on 8/17/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import "LFMTrackInfo.h"
#import "NSString+URLEncoding.h"
#import "LFMDefines.h"

@implementation LFMTrackInfo
@synthesize delegate;

// http://ws.audioscrobbler.com/2.0/?method=track.getInfo&api_key=b25b959554ed76058ac220b7b2e0a026&artist=Moe%20Aly&track=The%20Myth

- (void)requestInfo:(NSString*)artist withTrack:(NSString*)track
{
    NSString *urlRequestString = [[NSString alloc] initWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=track.getInfo&artist=%@&track=%@&api_key=%@",
                                  [artist URLEncodedString], [track URLEncodedString], kAPIKey];
    NSLog(@"LFMTrackInfo artist requested: %@ with track:%@", artist, track);
    NSLog(@"LFMTrackInfo Requesting from url: %@", urlRequestString);
    // Initialization code here.
	RXMLElement *rootXML = [RXMLElement elementFromURL:[NSURL URLWithString:urlRequestString]];
	
	if ([rootXML isValid]) {
		if ([[rootXML attribute:@"status"] isEqualToString:@"failed"]) {
			RXMLElement *errorElement = [rootXML child:@"error"];
			
			NSMutableDictionary* details = [NSMutableDictionary dictionary];
			[details setValue:errorElement.text forKey:NSLocalizedDescriptionKey];
			
			// populate the error object with the details
			NSError *error = [NSError errorWithDomain:@"ParsingFailed" code:[[errorElement attribute:@"code"] intValue] userInfo:details];
			[[self delegate] didFailToReceiveTrackInfo:error];
			return;
		}
	}
	else {
		// populate the error object with the details
		NSMutableDictionary* details = [NSMutableDictionary dictionary];
		[details setValue:@"Last.fm is likely having issues." forKey:NSLocalizedDescriptionKey];
		
		NSError *error = [NSError errorWithDomain:@"ParsingFailed" code:404 userInfo:details];
		[[self delegate] didFailToReceiveTrackInfo:error];
		return;
	}
	
	LFMTrack *trackInfo = [[LFMTrack alloc] init];
	[rootXML iterate:@"track.album" usingBlock:^(RXMLElement *albumElement) {
		[trackInfo setAlbum:[albumElement child:@"title"].text];
		for (RXMLElement *image in [albumElement children:@"image"]) {
			if ([[image attribute:@"size"] isEqualToString:@"small"]) {
				[trackInfo setArtwork:[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[image text]]]]];
			}
		}
	}];
	
    [[self delegate] didReceiveTrackInfo:trackInfo];
}

@end
