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

@implementation LFMArtistImage
@end

@implementation LFMArtistImages
@synthesize images;
@synthesize delegate;
@synthesize page_count;
@synthesize page_index;

// http://ws.audioscrobbler.com/2.0/?method=artist.gettoptracks&artist=cher&api_key=b25b959554ed76058ac220b7b2e0a026

- (void)requestImagesWithURL:(NSString*)urlRequestString completion:(LFMArtistImagesCompletion)completion
{	
	images = [NSMutableArray new];
	
	page_completion = completion;
	page_index = 1;
	parse_page = ^(int page)
	{
		NSString *pageString = [[NSString alloc] initWithFormat:@"%@&page=%i", urlRequestString,page];
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:pageString]];
		NSError *connectionError;
		NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&connectionError];
		RXMLElement *rootXML = [RXMLElement elementFromXMLData:data];
		
		if ([rootXML isValid]) {
			if ([[rootXML attribute:@"status"] isEqualToString:@"failed"]) {
				RXMLElement *errorElement = [rootXML child:@"error"];
				
				NSMutableDictionary* details = [NSMutableDictionary dictionary];
				[details setValue:errorElement.text forKey:NSLocalizedDescriptionKey];
				
				// populate the error object with the details
				//NSError *error = [NSError errorWithDomain:@"ParsingFailed" code:[[errorElement attribute:@"code"] intValue] userInfo:details];
				//[[self delegate] didFailToReceiveImages:error];
				return 0;
			}
		}
		else {
			// populate the error object with the details
			NSMutableDictionary* details = [NSMutableDictionary dictionary];
			[details setValue:@"Last.fm is likely having issues." forKey:NSLocalizedDescriptionKey];
			
			//NSError *error = [NSError errorWithDomain:@"ParsingFailed" code:404 userInfo:details];
			//[[self delegate] didFailToReceiveImages:error];
			return 0;
		}
		
		int pages = [[[rootXML child:@"images"] attribute:@"totalPages"] intValue];
		NSLog(@"pages: %i", pages);
		
		[rootXML iterate:@"images.image" usingBlock: ^(RXMLElement *e) {
			NSMutableDictionary *sizeDictionary = [NSMutableDictionary new];
			//BOOL acceptable = NO;
			LFMArtistImage *artistImage = [LFMArtistImage new];
			artistImage.title = [[e child:@"title"] text];
			for (RXMLElement *size in [[e child:@"sizes"] children:@"size"])
			{
				[sizeDictionary setValue:[NSURL URLWithString:[size text]] forKey:[size attribute:@"name"]];
				//NSLog(@"artist image thing %@", [size attribute:@"name"]);
				if ([[size attribute:@"name"] isEqualToString:@"original"])
				{
					int width = [[size attribute:@"width"] intValue];
					int height = [[size attribute:@"height"] intValue];
					
					artistImage.width = width;
					artistImage.height = height;
					
					/*float ratio = width/height;
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
					 }*/
				}
			}
			//if (acceptable)
			artistImage.qualities = sizeDictionary;
			[self.images addObject:artistImage];
		}];
		return pages;
	};
	
	//int pages = parse_page(1);
	// set the number of pages
	page_count = parse_page(1);
	completion(images, nil, NO);
	//for (int i=2; i<pages; ++i)
	//{
		//parse_page(i);
		//completion([images copy], nil, YES);
	//}
	
	NSLog(@"images count:%d", [images count]);
    //[[self delegate] didReceiveImages:(NSArray*)[images copy]];
	//completion([images copy], nil);
}

- (void)requestImagesWithArtist:(NSString*)artist completion:(LFMArtistImagesCompletion)completion
{
	NSString *urlRequestString = [[NSString alloc] initWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=artist.getimages&artist=%@&api_key=%@",
                                  [artist URLEncodedString], kAPIKey];
    NSLog(@"LFMArtistImages artist requested: %@", artist);
    NSLog(@"LFMArtistImages Requesting from url: %@", urlRequestString);
	[self requestImagesWithURL:urlRequestString completion:completion];
}

- (void)requestImagesWithMusicBrainzID:(NSString*)mbid completion:(LFMArtistImagesCompletion)completion
{
	NSString *urlRequestString = [[NSString alloc] initWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=artist.getimages&mbid=%@&api_key=%@",
                                  [mbid URLEncodedString], kAPIKey];
    NSLog(@"LFMArtistImages mbid requested: %@", mbid);
    NSLog(@"LFMArtistImages Requesting from url: %@", urlRequestString);
	[self requestImagesWithURL:urlRequestString completion:completion];
}

- (void)loadNewPage
{
	page_index++;
	// only load the page if we aren't at the last page
	if (page_index<=page_count)
	{
		// detect parsing failure... parse_page returns 0 if no internet or other failure
		if (parse_page(page_index)!=0)
			page_completion(images, nil, YES);
		// retract index increment because page failed
		else
			page_index--;
	}
}

@end