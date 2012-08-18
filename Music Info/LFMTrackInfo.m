//
//  LFMTrackInfo.m
//  Artista
//
//  Created by Chloe Stars on 8/17/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import "LFMTrackInfo.h"
#import "NSString+URLEncoding.h"

#define kLastFMKey @"b25b959554ed76058ac220b7b2e0a026"

@implementation LFMTrackInfo

// http://ws.audioscrobbler.com/2.0/?method=track.getInfo&api_key=b25b959554ed76058ac220b7b2e0a026&artist=Moe%20Aly&track=The%20Myth

- (void)requestInfo:(NSString*)artist withTrack:(NSString*)track
{
    NSString *urlRequestString = [[NSString alloc] initWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=track.getInfo&artist=%@&track=%@&api_key=%@",
                                  [artist URLEncodedString], [track URLEncodedString], kLastFMKey];
    NSLog(@"LFMTrackInfo artist requested: %@ with track:%@", artist, track);
    NSLog(@"LFMTrackInfo Requesting from url: %@", urlRequestString);
    // Initialization code here.
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:
                              urlRequestString]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    NSURLResponse *response = [[NSURLResponse alloc] init];
    NSError *error = [[NSError alloc] init];
    NSData *returnedData = [[NSData alloc] init];
    returnedData = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response error:&error];
	
	NSLog(@"Loaded:%@", [[NSString alloc] initWithData:returnedData encoding:NSStringEncodingConversionAllowLossy]);
    
    if (returnedData == nil) {
        //[pool release];
        //return -1;
    }
    else {
        if ([self parseData:returnedData] != nil) {
            //[pool release];
            //return -1;
        }
        //[pool release];
        //return 0;
    }
}

/**
 *  Parses the retrieved data from the website
 */
- (NSError *)parseData:(NSData *)info {
    BOOL success;
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:info];
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:YES];
    success = [parser parse];
    if (success == NO) {
        return [parser parserError];
    }
    //[parser release];
    return nil;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	//NSLog(@"found file and started parsing");
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    // Parsing failed
	[[self delegate] didFailToReceiveTrackInfo:parseError];
}

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
	attributes:(NSDictionary *)attributeDict{
	//NSLog(@"found this element: %@", elementName);
	currentElement = [elementName copy];
    
    if ([elementName isEqualToString:@"image"]) {
        currentAttribute = [attributeDict valueForKey:@"size"];
	}
}
- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName{
	// do nothing element tag ended
}

// the stuff inside the tags
- (void)parser:(NSXMLParser *)parser
foundCharacters:(NSString *)string{
	//NSLog(@"found characters: %@", string);
	// save the characters for the current item...
	if ([currentElement isEqualToString:@"title"]) {
        if (album == nil) {
            NSLog(@"LastFMArtistInfo album name: %@", string);
            album = string;
        }
	} else if ([currentElement isEqualToString:@"image"]) {
		if ([currentAttribute isEqualToString:@"small"]) {
			if (artwork == nil) {
				artwork = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:string]]];
				NSLog(@"LFMRecentTracks image URL: %@", string);
			}
		}
    }
}

/**
 * Parsing is finished here so this is when the delegate gets called
 */
- (void)parserDidEndDocument:(NSXMLParser *)parser {
    mostRecentTrack = [[LFMTrack alloc] init];
    [mostRecentTrack setAlbum:album];
    [mostRecentTrack setArtwork:artwork];
	
	// Success let controller know we have data
    [[self delegate] didReceiveTrackInfo:mostRecentTrack];
	
    // reset variables
    currentElement = nil;
    currentAttribute = nil;
    album = nil;
	artwork = nil;
}

@end
