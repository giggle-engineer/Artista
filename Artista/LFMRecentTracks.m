//
//  LFMRecentTracks.m
//  Music Info
//
//  Created by Chloe Stars on 8/14/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import "LFMRecentTracks.h"

#define kLastFMKey @"b25b959554ed76058ac220b7b2e0a026"

@implementation LFMRecentTracks

// http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=CodinGuru&api_key=b25b959554ed76058ac220b7b2e0a026

- (void)requestInfo:(NSString*)user
{
    NSString *urlRequestString = [[NSString alloc] initWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=%@&api_key=%@",
                                  [user URLEncodedString], kLastFMKey];
    NSLog(@"LFMRecentTracks user requested: %@", user);
    NSLog(@"LFMRecentTracks Requesting from url: %@", urlRequestString);
    // Initialization code here.
    RXMLElement *rootXML = [RXMLElement elementFromURL:[NSURL URLWithString:urlRequestString]];
	
	if ([rootXML isValid]) {
		if ([[rootXML attribute:@"status"] isEqualToString:@"failed"]) {
			RXMLElement *errorElement = [rootXML child:@"error"];
			
			NSMutableDictionary* details = [NSMutableDictionary dictionary];
			[details setValue:errorElement.text forKey:NSLocalizedDescriptionKey];
			
			// populate the error object with the details
			NSError *error = [NSError errorWithDomain:@"ParsingFailed" code:[[errorElement attribute:@"code"] intValue] userInfo:details];
			[[self delegate] didFailToReceiveRecentTracks:error];
			return;
		}
	}
	else {
		// populate the error object with the details
		NSMutableDictionary* details = [NSMutableDictionary dictionary];
		[details setValue:@"Last.fm is likely having issues." forKey:NSLocalizedDescriptionKey];
		
		NSError *error = [NSError errorWithDomain:@"ParsingFailed" code:404 userInfo:details];
		[[self delegate] didFailToReceiveRecentTracks:error];
		return;
	}
	
	NSMutableArray *tracks = [NSMutableArray new];

	[rootXML iterate:@"recenttracks.track" usingBlock: ^(RXMLElement *e) {
		LFMTrack *track = [LFMTrack new];
		RXMLElement *artist = [e child:@"artist"];
		
		[track setArtist:[artist child:@"name"].text];
		[track setMusicBrainzID:[artist child:@"mbid"].text];
		
		[track setName:[e child:@"name"].text];

		[tracks addObject:track];
	}];
	
	[[self delegate] didReceiveRecentTracks:tracks];
}

@end
