//
//  LFMMobileAuth.m
//  Artista
//
//  Created by Chloe Stars on 1/7/13.
//  Copyright (c) 2013 Chloe Stars. All rights reserved.
//

#import "LFMMobileAuth.h"
#import "LFMDefines.h"
#import "NSString+MD5.h"

@implementation LFMMobileAuth

- (NSString*)createSignatureWithPassword:(NSString*)password username:(NSString*)username
{
	NSString *signature = [[NSString alloc] initWithFormat:@"api_key%@methodauth.getMobileSessionpassword%@username%@%@",kAPIKey, password, username, kSecret];
	return [signature MD5String];
}

- (NSString*)getSesssionKeyWithUsername:(NSString*)username password:(NSString*)password signature:(NSString*)signature
{
	NSString *urlRequestString = @"https://ws.audioscrobbler.com/2.0/?method=auth.getMobileSession";
	
	// Instructions on how to use the POST method found here http://panditpakhurde.wordpress.com/2009/04/16/posting-data-to-url-in-objective-c/
	NSString *post = [NSString stringWithFormat:@"&password=%@&username=%@&api_key=%@&api_sig=%@",password, username, kAPIKey, signature];
	
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
	/*NSLog(@"response: %@", [[NSString alloc] initWithData:data
												 encoding:NSUTF8StringEncoding]);*/
	
	RXMLElement *rootXML = [RXMLElement elementFromXMLData:data];
	
	if ([rootXML isValid]) {
		if ([[rootXML attribute:@"status"] isEqualToString:@"failed"]) {
			RXMLElement *errorElement = [rootXML child:@"error"];
			
			NSMutableDictionary* details = [NSMutableDictionary dictionary];
			[details setValue:errorElement.text forKey:NSLocalizedDescriptionKey];
			
			// populate the error object with the details
			//NSError *error = [NSError errorWithDomain:@"ParsingFailed" code:[[errorElement attribute:@"code"] intValue] userInfo:details];
			return @"";
		}
	}
	else {
		// populate the error object with the details
		NSMutableDictionary* details = [NSMutableDictionary dictionary];
		[details setValue:@"Last.fm is likely having issues." forKey:NSLocalizedDescriptionKey];
		
		//NSError *error = [NSError errorWithDomain:@"ParsingFailed" code:404 userInfo:details];
		return @"";
	}
	
	RXMLElement *session = [rootXML child:@"session"];
	NSString *key = [[session child:@"key"] text];
	
    return key;
}

@end
