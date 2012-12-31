//
//  LFMArtistTopTracks.h
//  Artista
//
//  Created by Chloe Stars on 8/29/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RaptureXML/RXMLElement.h>

@interface LFMArtistImage : NSObject
@property NSDictionary *qualities;
@property NSString *title;
@property int width;
@property int height;
@end

@protocol LFMArtistImagesDelegate <NSObject>
@required
- (void) didReceiveImages: (NSArray *)images;
- (void) didFailToReceiveImages: (NSError *)error;
@end

typedef void (^LFMArtistImagesCompletion)(NSArray * images, NSError * error, BOOL paging);

@interface LFMArtistImages : NSObject {
	id <LFMArtistImagesDelegate> delegate;
	NSMutableArray *images;
	int isCanceled;
}

@property (strong) id delegate;
@property NSMutableArray *images;

- (void)requestImagesWithArtist:(NSString*)artist completion:(LFMArtistImagesCompletion)completion;
- (void)requestImagesWithMusicBrainzID:(NSString*)mbid completion:(LFMArtistImagesCompletion)completion;
- (void)cancelPagingOperation;

@end