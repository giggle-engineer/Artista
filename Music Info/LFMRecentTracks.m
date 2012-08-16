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
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:
                              urlRequestString]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    NSURLResponse *response = [[NSURLResponse alloc] init];
    NSError *error = [[NSError alloc] init];
    NSData *returnedData = [[NSData alloc] init];
    returnedData = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response error:&error];
    
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
	[[self delegate] didFailToReceiveRecentTracks:parseError];
}

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
	attributes:(NSDictionary *)attributeDict{
	//NSLog(@"found this element: %@", elementName);
	currentElement = [elementName copy];
    
    if ([elementName isEqualToString:@"track"]) {
        currentAttribute = [attributeDict valueForKey:@"nowplaying"];
        // make sure we don't read this twice
        if (!nowPlaying) {
            nowPlaying = NO;
        }
	}
	if ([elementName isEqualToString:@"name"]) {
        // make sure we don't read this twice
        if (!track) {
            track = nil;
        }
	}
    if ([elementName isEqualToString:@"artist"]) {
        // make sure we don't read this twice
        if (!musicBrainzID) {
            musicBrainzID = [attributeDict valueForKey:@"mbid"];
        }
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
	if ([currentElement isEqualToString:@"name"]) {
        if (track == nil) {
            NSLog(@"LastFMArtistInfo track name: %@", string);
            track = string;
        }
	} else if ([currentElement isEqualToString:@"artist"]) {
        if (artist == nil) {
            artist = string;
            NSLog(@"LFMRecentTracks Details: %@", artist);
        }
    }
}

/**
 * Parsing is finished here so this is when the delegate gets called
 */
- (void)parserDidEndDocument:(NSXMLParser *)parser {
    mostRecentTrack = [[LFMTrack alloc] init];
    [mostRecentTrack setArtist:artist];
    [mostRecentTrack setMusicBrainzID:musicBrainzID];
    [mostRecentTrack setTrack:track];
	
    // reset variables
    currentElement = nil;
    currentAttribute = nil;
    artist = nil;
    track = nil;
    musicBrainzID = nil;
    nowPlaying = NO;
	// Success let controller know we have data
    [[self delegate] didReceiveRecentTracks:mostRecentTrack];
    
}

@end
