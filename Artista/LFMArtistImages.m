//
//  LFMArtistTopTracks.m
//  Artista
//
//  Created by Chloe Stars on 8/29/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import "LFMArtistImages.h"
#import "LFMTrack.h"
#import "NSString+URLEncoding.h"
#import "LFMDefines.h"

@implementation LFMArtistImages
@synthesize delegate;

// http://ws.audioscrobbler.com/2.0/?method=artist.gettoptracks&artist=cher&api_key=b25b959554ed76058ac220b7b2e0a026

- (void)requestImagesWithURL:(NSString*)urlRequestString completion:(LFMArtistImagesCompletion)completion
{
	// Initialization code here.
	
	images = [NSMutableArray new];
	
	RXMLElement *rootXML = [RXMLElement elementFromURL:[NSURL URLWithString:urlRequestString]];
	
	if ([rootXML isValid]) {
		if ([[rootXML attribute:@"status"] isEqualToString:@"failed"]) {
			RXMLElement *errorElement = [rootXML child:@"error"];
			
			NSMutableDictionary* details = [NSMutableDictionary dictionary];
			[details setValue:errorElement.text forKey:NSLocalizedDescriptionKey];
			
			// populate the error object with the details
			NSError *error = [NSError errorWithDomain:@"ParsingFailed" code:[[errorElement attribute:@"code"] intValue] userInfo:details];
			[[self delegate] didFailToReceiveImages:error];
			return;
		}
	}
	else {
		// populate the error object with the details
		NSMutableDictionary* details = [NSMutableDictionary dictionary];
		[details setValue:@"Last.fm is likely having issues." forKey:NSLocalizedDescriptionKey];
		
		NSError *error = [NSError errorWithDomain:@"ParsingFailed" code:404 userInfo:details];
		[[self delegate] didFailToReceiveImages:error];
		return;
	}
	
	int pages = [[[rootXML child:@"images"] attribute:@"totalPages"] intValue];
	NSLog(@"pages: %i", pages);
	
	[rootXML iterate:@"images.image" usingBlock: ^(RXMLElement *e) {		
		NSMutableDictionary *sizeDictionary = [NSMutableDictionary new];
		BOOL acceptable = NO;
		for (RXMLElement *size in [[e child:@"sizes"] children:@"size"])
		{
			[sizeDictionary setValue:[NSURL URLWithString:[size text]] forKey:[size attribute:@"name"]];
			//NSLog(@"artist image thing %@", [size attribute:@"name"]);
			/*if ([[size attribute:@"name"] isEqualToString:@"original"])
			{
				float width = [[size attribute:@"width"] floatValue];
				float height = [[size attribute:@"height"] floatValue];
				
				float ratio = width/height;
				NSRange a = NSMakeRange(2.56f-0.7, 2.56f+0.7);
				NSRange b = NSMakeRange(ratio, ratio);
				NSRange intersection = NSIntersectionRange(a, b);
				if (intersection.length <= 0)
				{
					NSLog(@"Ranges do not intersect");
				}
				else
				{
					NSLog(@"Intersection = %@", NSStringFromRange(intersection));
					acceptable = YES;
				}
			}*/
		}
		//if (acceptable)
			[images addObject:sizeDictionary];
	}];
	NSLog(@"images count:%d", [images count]);
    //[[self delegate] didReceiveImages:(NSArray*)[images copy]];
	completion([images copy], nil);
	[images removeAllObjects];
}

- (void)requestImagesWithArtist:(NSString*)artist completion:(LFMArtistImagesCompletion)completion {
	NSString *urlRequestString = [[NSString alloc] initWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=artist.getimages&artist=%@&api_key=%@",
                                  [artist URLEncodedString], kAPIKey];
    NSLog(@"LFMArtistImages artist requested: %@", artist);
    NSLog(@"LFMArtistImages Requesting from url: %@", urlRequestString);
	[self requestImagesWithURL:urlRequestString completion:completion];
}

- (void)requestImagesWithMusicBrainzID:(NSString*)mbid completion:(LFMArtistImagesCompletion)completion {
	NSString *urlRequestString = [[NSString alloc] initWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=artist.getimages&mbid=%@&api_key=%@",
                                  [mbid URLEncodedString], kAPIKey];
    NSLog(@"LFMArtistImages mbid requested: %@", mbid);
    NSLog(@"LFMArtistImages Requesting from url: %@", urlRequestString);
	[self requestImagesWithURL:urlRequestString completion:completion];
}

@end