//
//  LFMRecentTracks.m
//  Music Info
//
//  Created by Chloe Stars on 8/14/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import "LFMRecentTracks.h"
#import "LFMDefines.h"
#import "FDKeychain.h"

@implementation LFMRecentTracks
@synthesize delegate;

// http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=CodinGuru&api_key=b25b959554ed76058ac220b7b2e0a026

- (void)requestInfo:(NSString*)user
{
    NSString *urlRequestString = @"https://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks";
	
    //NSLog(@"LFMRecentTracks user requested: %@", user);
    //NSLog(@"LFMRecentTracks Requesting from url: %@", urlRequestString);
	
	NSString *sessionKey = [FDKeychain itemForKey: @"sessionKey"
									   forService: @"Last.fm"];
	NSString *apiSignature = [FDKeychain itemForKey: @"apiSignature"
										 forService: @"Last.fm"];
	
	// Instructions on how to use the POST method found here http://panditpakhurde.wordpress.com/2009/04/16/posting-data-to-url-in-objective-c/
	NSString *post = [NSString stringWithFormat:@"&user=%@&api_key=%@&sk=%@&api_sig=%@",[user URLEncodedString], kAPIKey, sessionKey, apiSignature];
	
	// Encode the post string using NSASCIIStringEncoding and also the post string you need to send in NSData format.
	NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	// You need to send the actual length of your data. Calculate the length of the post string.
	NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlRequestString]];
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setHTTPBody:postData];
	
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
		
		if ([[e attribute:@"nowplaying"] isEqualToString:@"true"]) {
			[track setNowPlaying:YES];
		}
		
		[track setArtist:artist.text];
		//NSLog(@"artist:%@", [track artist]);
		[track setMusicBrainzID:[artist attribute:@"mbid"]];
		//NSLog(@"music brainz:%@", [track musicBrainzID]);
		[track setName:[e child:@"name"].text];

		[tracks addObject:track];
	}];
	
	[[self delegate] didReceiveRecentTracks:tracks];
}

@end
