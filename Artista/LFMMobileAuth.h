//
//  LFMMobileAuth.h
//  Artista
//
//  Created by Chloe Stars on 1/7/13.
//  Copyright (c) 2013 Chloe Stars. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RaptureXML/RXMLElement.h>

@interface LFMMobileAuth : NSObject

- (NSString*)createSignatureWithPassword:(NSString*)password username:(NSString*)username;
- (NSString*)getSesssionKeyWithUsername:(NSString*)username password:(NSString*)password signature:(NSString*)signature;

@end
