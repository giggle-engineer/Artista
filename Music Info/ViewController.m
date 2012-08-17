//
//  ViewController.m
//  Music Info
//
//  Created by Chloe Stars on 8/14/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "LastFMArtistInfo.h"
#import "LFMRecentTracks.h"
#import "LFMTrack.h"
#import "UIImage+DSP.h"
#import "NSString+HTML.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	playbackTimer = nil;
	
	// round the corners of the album art view
	albumArtView.layer.cornerRadius = 5.0;
	albumArtView.layer.masksToBounds = YES;
	
	// skin the playback time progress view
	[playTimeProgressView setProgressImage:[UIImage imageNamed:@"progressbarfill.png"]];
	[playTimeProgressView setTrackImage:[UIImage imageNamed:@"progressbar.png"]];
	[playTimeProgressView setFrame:CGRectMake(playTimeProgressView.frame.origin.x, playTimeProgressView.frame.origin.y, playTimeProgressView.frame.size.width, 1)];
	
	// give shadow to bio text
    bioTextView.layer.shadowColor = [[UIColor blackColor] CGColor];
    bioTextView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    bioTextView.layer.shadowOpacity = 1.0f;
    bioTextView.layer.shadowRadius = 0.5f;
	
	// setup refreshing
	refreshControl = [[ODRefreshControl alloc] initInScrollView:bioTextView];
	[refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
	
	// push in bio scroll view content up past the bottom bar
	UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, bottomBarView.frame.size.height, 0.0);
	bioTextView.contentInset = contentInsets;
	bioTextView.scrollIndicatorInsets = contentInsets;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(load)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dropViewDidBeginRefreshing:(id)sender {
	[self load];
}

- (void)makeMask {
	// fade out text when scrolling
	CAGradientLayer *mask = [CAGradientLayer layer];
	mask.locations = [NSArray arrayWithObjects:
					  [NSNumber numberWithFloat:0.0],
					  [NSNumber numberWithFloat:0.1],
					  [NSNumber numberWithFloat:0.9],
					  [NSNumber numberWithFloat:1.0],
					  nil];
	
	mask.colors = [NSArray arrayWithObjects:
				   (id)[UIColor clearColor].CGColor,
				   (id)[UIColor whiteColor].CGColor,
				   (id)[UIColor whiteColor].CGColor,
				   (id)[UIColor clearColor].CGColor,
				   nil];
	
	mask.frame = bioTextView.bounds;
	// vertical direction
	mask.startPoint = CGPointMake(0, 0);
	mask.endPoint = CGPointMake(0, 1);
	
	bioTextView.layer.mask = mask;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	float offset = scrollView.contentOffset.y;
	if (offset<=0) {
		// add shadow to navigation top bar
		NSLog(@"bioTextView scroll at top");
		bioTextView.layer.mask = nil;
	}
	else {
		[self makeMask];
	}
	
	CGRect layerMaskFrame = bioTextView.layer.mask.frame;
    layerMaskFrame.origin = [self.view convertPoint:bioTextView.bounds.origin toView:self.view];
	
    bioTextView.layer.mask.frame = layerMaskFrame;
	[CATransaction commit];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstRun"]) {
		[self load];
	}
}

- (void)viewDidAppear:(BOOL)animated {
    // load Last.fm account login view. only display this on first run
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstRun"]) {
        [self performSegueWithIdentifier: @"Account"
                                  sender: nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Account"]) {
        AccountViewController *accountViewController = segue.destinationViewController;
        [accountViewController setDelegate:self];
    }
}

- (void)updatePlaybackProgress {
	NSTimeInterval currentTime = [iPodController currentPlaybackTime];
	NSNumber *playbackDuration = [[iPodController nowPlayingItem] valueForKey:MPMediaItemPropertyPlaybackDuration];
	float progress = currentTime/playbackDuration.intValue;
	[playTimeProgressView setProgress:progress];
	// TODO: End updating playback progress and reset if end of currently playing song is reached
}

- (void)load {
	iPodController = [MPMusicPlayerController iPodMusicPlayer];
	if ([iPodController playbackState]==MPMusicPlaybackStatePlaying) {
		MPMediaItem *mediaItem = [iPodController nowPlayingItem];
		NSString *artistName = [mediaItem valueForKey:MPMediaItemPropertyArtist];
		NSString *albumName = [mediaItem valueForKey:MPMediaItemPropertyAlbumTitle];
		NSString *trackName = [mediaItem valueForKey:MPMediaItemPropertyTitle];
		MPMediaItemArtwork *artwork = [mediaItem valueForKey:MPMediaItemPropertyArtwork];
		[albumArtView setImage:[artwork imageWithSize:CGSizeMake(30, 30)]];
		[artist setText:artistName];
		[album setText:albumName];
		[track setText:trackName];
		artistInfo = [[LastFMArtistInfo alloc] init];
		[artistInfo setDelegate:self];
		[artistInfo requestInfoWithArtist:artistName];
		[refreshControl endRefreshing];
		if (playbackTimer!=nil)
			playbackTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updatePlaybackProgress) userInfo:nil repeats:YES];
	}
	else {
		// remove playback timer updating if the iPod is no longer playing
		if ([playbackTimer isValid])
			[playbackTimer invalidate];
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
		dispatch_async(queue,^{
			if (recentTracks==nil) {
				recentTracks = [[LFMRecentTracks alloc] init];
				[recentTracks setDelegate:self];
			}
			[recentTracks requestInfo:[[NSUserDefaults standardUserDefaults] stringForKey:@"user"]];
		});
	}
}

- (IBAction)reloadRecentTracks:(id)sender {
    [self load];
}

#pragma mark - LFMRecentTracks Delegate

- (void)didReceiveRecentTracks:(LFMTrack *)_track {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    dispatch_async(queue,^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [artist setText:[_track artist]];
			[track setText:[_track track]];
        });
        if (artistInfo==nil) {
            artistInfo = [[LastFMArtistInfo alloc] init];
            [artistInfo setDelegate:self];
        }
        if (![[_track musicBrainzID] isEqualToString:@""]) {
            [artistInfo requestInfoWithMusicBrainzID:[_track musicBrainzID]];
        }
        else {
            [artistInfo requestInfoWithArtist:[_track artist]];
        }
    });
}

- (void)didFailToReceiveRecentTracks:(NSError *)error {
    NSLog(@"Failed to receive track with error:%@", [error description]);
}

#pragma mark - LastFMArtistInfo Delegate

- (void)didReceiveArtistDetails:(NSString *)artistDetails withImage:(UIImage *)artistImage {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *blurredImage = [artistImage imageByApplyingGaussianBlur5x5];
        [bioTextView setText:[artistDetails stringByConvertingHTMLToPlainText]];
        [artistImageView setImage:blurredImage];
		[refreshControl endRefreshing];
    });
}

- (void)didFailToReceiveArtistDetails:(NSError *)error {
    NSLog(@"Failed to receive track with error:%@", [error description]);
}

#pragma mark  - Account View Controller Delegate

- (void)didReceiveReceiveUsername {
    [self load];
}

- (void)didFailToReceiveUsername:(NSError *)error {
    NSLog(@"Failed to receive username with error:%@", [error description]);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
