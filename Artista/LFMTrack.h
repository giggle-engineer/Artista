//
//  LFMTrack.h
//  Music Info
//
//  Created by Chloe Stars on 8/14/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LFMTrack : NSObject

@property NSString *artist;
@property NSString *name;
@property NSString *listeners;
@property NSString *playCount;
@property NSString *duration;
@property NSString *album;
@property UIImage *artwork;
@property NSString *musicBrainzID;
@property BOOL nowPlaying;

@end
