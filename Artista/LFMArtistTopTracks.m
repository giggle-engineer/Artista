//
//  LFMArtistTopTracks.m
//  Artista
//
//  Created by Chloe Stars on 8/29/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import "LFMArtistTopTracks.h"
#import "LFMTrack.h"
#import "NSString+URLEncoding.h"
#import "LFMDefines.h"

@implementation LFMArtistTopTracks
@synthesize delegate;

// http://ws.audioscrobbler.com/2.0/?method=artist.gettoptracks&artist=cher&api_key=b25b959554ed76058ac220b7b2e0a026

- (void)requestTopTracksWithArtist:(NSString*)artist {
	NSString *urlRequestString = [[NSString alloc] initWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=artist.gettoptracks&artist=%@&api_key=%@",
                                  [artist URLEncodedString], kAPIKey];
    NSLog(@"LFMArtistTopTracks artist requested: %@", artist);
    NSLog(@"LFMArtistTopTracks Requesting from url: %@", urlRequestString);
    // Initialization code here.
	
	tracks = [NSMutableArray new];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlRequestString]];
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
			[[self delegate] didFailToReceiveTopTracks:error];
			return;
		}
	}
	else {
		// populate the error object with the details
		NSMutableDictionary* details = [NSMutableDictionary dictionary];
		[details setValue:@"Last.fm is likely having issues." forKey:NSLocalizedDescriptionKey];
		
		NSError *error = [NSError errorWithDomain:@"ParsingFailed" code:404 userInfo:details];
		[[self delegate] didFailToReceiveTopTracks:error];
		return;
	}
	
	[rootXML iterate:@"toptracks.track" usingBlock: ^(RXMLElement *e) {
		LFMTrack *track = [LFMTrack new];
		[track setName:[e child:@"name"].text];
		
		// format listener and play count with commas/separators
		NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
		[numberFormatter setGroupingSize:3];
		[numberFormatter setUsesGroupingSeparator:YES];
		NSString *formattedListeners = [numberFormatter stringFromNumber:[NSNumber numberWithInt:[[[e child:@"listeners"] text] intValue]]];
		NSString *formattedPlayCount = [numberFormatter stringFromNumber:[NSNumber numberWithInt:[[[e child:@"playcount"] text] intValue]]];
		[track setPlayCount:formattedPlayCount];
		[track setListeners:formattedListeners];
		
		// convert seconds to hours, minutes and seconds
		NSTimeInterval theTimeInterval = [[[e child:@"duration"] text] doubleValue];
		// Get the system calendar
		NSCalendar *sysCalendar = [NSCalendar currentCalendar];
		// Create the NSDates
		NSDate *date1 = [[NSDate alloc] init];
		NSDate *date2 = [[NSDate alloc] initWithTimeInterval:theTimeInterval sinceDate:date1];
		// Get conversion to months, days, hours, minutes
		unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
		NSDateComponents *conversionInfo = [sysCalendar components:unitFlags fromDate:date1  toDate:date2  options:0];
		NSString *formattedDuration;
		if ([conversionInfo hour]>0) {
			if ([conversionInfo minute]<10) {
				if ([conversionInfo second]<10) {
					formattedDuration = [[NSString alloc] initWithFormat:@"%d:0%d:0%d", [conversionInfo hour], [conversionInfo minute], [conversionInfo second]];
				}
				else {
					formattedDuration = [[NSString alloc] initWithFormat:@"%d:0%d:%d", [conversionInfo hour], [conversionInfo minute], [conversionInfo second]];
				}
			}
			else {
				if ([conversionInfo second]<10) {
					formattedDuration = [[NSString alloc] initWithFormat:@"%d:%d:0%d", [conversionInfo hour], [conversionInfo minute], [conversionInfo second]];
				}
				else {
					formattedDuration = [[NSString alloc] initWithFormat:@"%d:%d:%d", [conversionInfo hour], [conversionInfo minute], [conversionInfo second]];
				}
			}
		}
		else {
			if ([conversionInfo second]<10) {
				formattedDuration = [[NSString alloc] initWithFormat:@"%d:0%d", [conversionInfo minute], [conversionInfo second]];
			}
			else {
				formattedDuration = [[NSString alloc] initWithFormat:@"%d:%d", [conversionInfo minute], [conversionInfo second]];
			}
		}
		[track setDuration:formattedDuration];
		
		[tracks addObject:track];
	}];
	NSLog(@"tracks count:%d", [tracks count]);
    [[self delegate] didReceiveTopTracks:(NSArray*)[tracks copy]];
	[tracks removeAllObjects];
}

- (void)requestTopTracksWithMusicBrainzID:(NSString*)mbid {
	NSString *urlRequestString = [[NSString alloc] initWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=artist.gettoptracks&mbid=%@&api_key=%@",
                                  [mbid URLEncodedString], kAPIKey];
    NSLog(@"LFMArtistTopTracks artist requested: %@", mbid);
    NSLog(@"LFMArtistTopTracks Requesting from url: %@", urlRequestString);
    // Initialization code here.
	
	tracks = [NSMutableArray new];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlRequestString]];
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
			[[self delegate] didFailToReceiveTopTracks:error];
			return;
		}
	}
	else {
		// populate the error object with the details
		NSMutableDictionary* details = [NSMutableDictionary dictionary];
		[details setValue:@"Last.fm is likely having issues." forKey:NSLocalizedDescriptionKey];
		
		NSError *error = [NSError errorWithDomain:@"ParsingFailed" code:404 userInfo:details];
		[[self delegate] didFailToReceiveTopTracks:error];
		return;
	}
	
	[rootXML iterate:@"toptracks.track" usingBlock: ^(RXMLElement *e) {
		LFMTrack *track = [LFMTrack new];
		[track setName:[e child:@"name"].text];
		
		// format listener and play count with commas/separators
		NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
		[numberFormatter setGroupingSize:3];
		[numberFormatter setUsesGroupingSeparator:YES];
		NSString *formattedListeners = [numberFormatter stringFromNumber:[NSNumber numberWithInt:[[[e child:@"listeners"] text] intValue]]];
		NSString *formattedPlayCount = [numberFormatter stringFromNumber:[NSNumber numberWithInt:[[[e child:@"playcount"] text] intValue]]];
		[track setPlayCount:formattedPlayCount];
		[track setListeners:formattedListeners];
		
		// convert seconds to hours, minutes and seconds
		NSTimeInterval theTimeInterval = [[[e child:@"duration"] text] doubleValue];
		// Get the system calendar
		NSCalendar *sysCalendar = [NSCalendar currentCalendar];
		// Create the NSDates
		NSDate *date1 = [[NSDate alloc] init];
		NSDate *date2 = [[NSDate alloc] initWithTimeInterval:theTimeInterval sinceDate:date1];
		// Get conversion to months, days, hours, minutes
		unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
		NSDateComponents *conversionInfo = [sysCalendar components:unitFlags fromDate:date1  toDate:date2  options:0];
		NSString *formattedDuration;
		if ([conversionInfo hour]>0) {
			if ([conversionInfo minute]<10) {
				if ([conversionInfo second]<10) {
					formattedDuration = [[NSString alloc] initWithFormat:@"%d:0%d:0%d", [conversionInfo hour], [conversionInfo minute], [conversionInfo second]];
				}
				else {
					formattedDuration = [[NSString alloc] initWithFormat:@"%d:0%d:%d", [conversionInfo hour], [conversionInfo minute], [conversionInfo second]];
				}
			}
			else {
				if ([conversionInfo second]<10) {
					formattedDuration = [[NSString alloc] initWithFormat:@"%d:%d:0%d", [conversionInfo hour], [conversionInfo minute], [conversionInfo second]];
				}
				else {
					formattedDuration = [[NSString alloc] initWithFormat:@"%d:%d:%d", [conversionInfo hour], [conversionInfo minute], [conversionInfo second]];
				}
			}
		}
		else {
			if ([conversionInfo second]<10) {
				formattedDuration = [[NSString alloc] initWithFormat:@"%d:0%d", [conversionInfo minute], [conversionInfo second]];
			}
			else {
				formattedDuration = [[NSString alloc] initWithFormat:@"%d:%d", [conversionInfo minute], [conversionInfo second]];
			}
		}
		[track setDuration:formattedDuration];
		
		[tracks addObject:track];
	}];
	NSLog(@"tracks count:%d", [tracks count]);
    [[self delegate] didReceiveTopTracks:(NSArray*)[tracks copy]];
	[tracks removeAllObjects];
}

@end