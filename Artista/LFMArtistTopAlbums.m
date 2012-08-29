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
    NSLog(@"LFMRecentTracks user requested: %@", artist);
    NSLog(@"LFMRecentTracks Requesting from url: %@", urlRequestString);
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
	albums = [NSMutableArray new];
    
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

- (void)requestTopAlbumsWithMusicBrainzID:(NSString*)mbid
{
    NSString *urlRequestString = [[NSString alloc] initWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=artist.gettopalbums&mbid=%@&api_key=%@",
                                  [mbid URLEncodedString], kLastFMKey];
    NSLog(@"LFMRecentTracks user requested: %@", mbid);
    NSLog(@"LFMRecentTracks Requesting from url: %@", urlRequestString);
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
	albums = [NSMutableArray new];
    
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
	[[self delegate] didFailToReceiveTopAlbums:parseError];
}

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
	attributes:(NSDictionary *)attributeDict{
	// element tag began
	currentElement = [elementName copy];
	
	if ([elementName isEqualToString:@"image"]) {
        currentAttribute = [attributeDict valueForKey:@"size"];
	}
	if ([elementName isEqualToString:@"album"]) {
		currentAttribute = [attributeDict valueForKey:@"rank"];
	}
}
- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName{
	// element tag ended
}

// the stuff inside the tags
- (void)parser:(NSXMLParser *)parser
foundCharacters:(NSString *)string{
	//NSLog(@"found characters: %@", string);
	// save the characters for the current item...
	if ([currentElement isEqualToString:@"name"]) {
        currentAlbum = [LFMAlbum new];
		[currentAlbum setName:string];
	}
	if ([currentElement isEqualToString:@"image"]) {
        if ([currentAttribute isEqualToString:@"extralarge"]) {
			[currentAlbum setArtwork:[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:string]]]];
			[albums addObject:currentAlbum];
        }
	}
}

/**
 * Parsing is finished here so this is when the delegate gets called
 */
- (void)parserDidEndDocument:(NSXMLParser *)parser {
	// Success let controller know we have data
	NSLog(@"albums count:%d", [albums count]);
    [[self delegate] didReceiveTopAlbums:albums];
	
    // reset variables
    currentElement = nil;
    currentAttribute = nil;
    /*artist = nil;
    track = nil;
    musicBrainzID = nil;
    nowPlaying = NO;*/
    
}

@end
