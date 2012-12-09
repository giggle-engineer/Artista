//
//  LFMArtistTopTracks.h
//  Artista
//
//  Created by Chloe Stars on 8/29/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RaptureXML/RXMLElement.h>

@protocol LFMArtistImagesDelegate <NSObject>
@required
- (void) didReceiveImages: (NSArray *)images;
- (void) didFailToReceiveImages: (NSError *)error;
@end

typedef void (^LFMArtistImagesCompletion)(NSArray * images, NSError * error);

@interface LFMArtistImages : NSObject {
	id <LFMArtistImagesDelegate> delegate;
    
@private
	NSMutableArray *images;
}

@property (strong) id delegate;

- (void)requestImagesWithArtist:(NSString*)artist completion:(LFMArtistImagesCompletion)completion;
- (void)requestImagesWithMusicBrainzID:(NSString*)mbid;

@end