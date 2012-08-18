//
//  LastFMArtistInfo.m
//  Musica
//
//  Created by Chloe Stars on 2/27/11.
//  Copyright 2011 Ozipto. All rights reserved.
//

#import "LastFMArtistInfo.h"

#define kLastFMKey @"b25b959554ed76058ac220b7b2e0a026"

@implementation LastFMArtistInfo

@synthesize delegate;

- (void)requestInfoWithArtist:(NSString*)artist
{
    NSString *urlRequestString = [[NSString alloc] initWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=artist.getinfo&artist=%@&api_key=%@", 
                                  [artist URLEncodedString], kLastFMKey];
    NSLog(@"LastFMArtistInfo artist requested: %@", artist);
    NSLog(@"LastFMArtistInfo Requesting from url: %@", urlRequestString);
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

- (void)requestInfoWithMusicBrainzID:(NSString*)mbid {
    NSString *urlRequestString = [[NSString alloc] initWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=artist.getinfo&mbid=%@&api_key=%@",
                                  [mbid URLEncodedString], kLastFMKey];
    NSLog(@"LastFMArtistInfo mbid requested: %@", mbid);
    NSLog(@"LastFMArtistInfo Requesting from url: %@", urlRequestString);
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
	[[self delegate] didFailToReceiveArtistDetails:parseError];
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
        // make sure we don't read this twice
        /*if (!artistImage) {
            artistImage = nil;
        }*/
	}
    /*if ([elementName isEqualToString:@"content"]) {
        // make sure we don't read this twice
        if (!artistDetails) {
            artistDetails = nil;
        }
    }*/
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
	if ([currentElement isEqualToString:@"image"]) { 
        if ([currentAttribute isEqualToString:@"mega"]) {
            if (artistImage == nil) {
                NSLog(@"LastFMArtistInfo image Url: %@", string);
                artistImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:string]]];
            }
        }
	} else if ([currentElement isEqualToString:@"content"]) {
        if (artistDetails == nil) {
            artistDetails = string;
            NSLog(@"LastFMArtistInfo Details: %u", [artistDetails length]);
        }
    }
} 

/**
 * Parsing is finished here so this is when the delegate gets called
 */
- (void)parserDidEndDocument:(NSXMLParser *)parser {
	// Success let controller know we have data
    [[self delegate] didReceiveArtistDetails:artistDetails withImage:artistImage];
	
    // reset variables
    artistImage = nil;
    artistDetails = nil;
}


@end
