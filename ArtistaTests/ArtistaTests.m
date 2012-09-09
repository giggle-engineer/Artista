//
//  ArtistaTests.m
//  ArtistaTests
//
//  Created by Chloe Stars on 8/14/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import "ArtistaTests.h"

@implementation ArtistaTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
	lfmArtistInfo = [[LFMArtistInfo alloc] init];
	NSLog(@"setting up testing");
	[lfmArtistInfo setDelegate:self];
	lfmArtistTopAlbums = [[LFMArtistTopAlbums alloc] init];
	lfmArtistTopTracks = [[LFMArtistTopTracks alloc] init];
	lfmRecentTracks = [[LFMRecentTracks alloc] init];
	lfmTrackInfo = [[LFMTrackInfo alloc] init];
	
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
	[lfmArtistInfo requestInfoWithArtist:@"Tiësto"];
}

#pragma mark - LFMArtistInfo Delegate

- (void)didReceiveArtistInfo:(LFMArtist *)artist {
	STAssertNotNil([artist bio], @"Artist bio found.");
}

#pragma mark -

@end
