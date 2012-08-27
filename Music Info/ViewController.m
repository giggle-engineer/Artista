//
//  ViewController.m
//  Music Info
//
//  Created by Chloe Stars on 8/14/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "LFMTrack.h"
#import "UIImage+DSP.h"
#import "NSString+HTML.h"
#import "NSString_stripHtml.h"
#import "NSArray+StringWithDelimeter.h"
#import "UITag.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	playbackTimer = nil;
	
	// set up navigation bar. notice that conspicuous blank space in the storyboard? yea, that's for this
	SVSegmentedControl *navigation = [[SVSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:@"Biography", @"Top Albums", @"Top Tracks", nil]];
	navigation.font = [UIFont fontWithName:@"Helvetica Neue" size:12];
	navigation.alpha = 0.7f;
	navigation.titleEdgeInsets = UIEdgeInsetsMake(-1, 16, 0, 16);
    [navigation addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    
	[self.view addSubview:navigation];
	
	navigation.center = CGPointMake(160, 80);
	
	// subtly dim the tag view
	tagView.alpha = 0.5;
	
	// round the corners of the album art view
	albumArtView.layer.cornerRadius = 5.0;
	albumArtView.layer.masksToBounds = YES;
	
	// skin the playback time progress view
	[playTimeProgressView setProgressImage:[UIImage imageNamed:@"progressbarfill.png"]];
	[playTimeProgressView setTrackImage:[UIImage imageNamed:@"progressbar.png"]];
	[playTimeProgressView setFrame:CGRectMake(playTimeProgressView.frame.origin.x, playTimeProgressView.frame.origin.y, playTimeProgressView.frame.size.width, 1)];
	
	// give shadow to bio text
    bioTextView.layer.shadowColor = [[UIColor whiteColor] CGColor];
    bioTextView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    bioTextView.layer.shadowOpacity = 1.0f;
    bioTextView.layer.shadowRadius = 0.5f;
	
	// setup refreshing
	refreshControl = [[ODRefreshControl alloc] initInScrollView:bioTextView];
	[refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
	
	// push in bio scroll view content up past the bottom bar... this is nullified by ODRefreshControl 😢
	UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, bottomBarView.frame.size.height, 0.0);
	bioTextView.contentInset = contentInsets;
	bioTextView.scrollIndicatorInsets = contentInsets;
	
	// adjust tag view so that it doesn't default to being on the edges when overflowing
	UIEdgeInsets moreContentInsets = UIEdgeInsetsMake(0.0, 8.0, 0.0, 8.0);
	tagView.contentInset = moreContentInsets;
	tagView.scrollIndicatorInsets = moreContentInsets;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(load)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)segmentedControlChangedValue:(SVSegmentedControl*)segmentedControl {
	NSLog(@"segmentedControl %i did select index %i (via UIControl method)", segmentedControl.tag, segmentedControl.selectedIndex);
	if (segmentedControl.selectedIndex==0) {
		[UIView animateWithDuration:0.50
							  delay:0
							options:UIViewAnimationCurveEaseIn
						 animations:^{
							 biographyView.alpha = 1.0;
							 topAlbumsView.alpha = 0.0;
							 topTracksView.alpha = 0.0;
						 }
						 completion:^(BOOL finished){
							 
						 }];
	}
	if (segmentedControl.selectedIndex==1) {
		[UIView animateWithDuration:0.50
							  delay:0
							options:UIViewAnimationCurveEaseIn
						 animations:^{
							 biographyView.alpha = 0.0;
							 topAlbumsView.alpha = 1.0;
							 topTracksView.alpha = 0.0;
						 }
						 completion:^(BOOL finished){
							 
						 }];
	}
	if (segmentedControl.selectedIndex==2) {
		[UIView animateWithDuration:0.50
							  delay:0
							options:UIViewAnimationCurveEaseIn
						 animations:^{
							 biographyView.alpha = 0.0;
							 topAlbumsView.alpha = 0.0;
							 topTracksView.alpha = 1.0;
						 }
						 completion:^(BOOL finished){
							 
						 }];
	}
}

- (void)dropViewDidBeginRefreshing:(id)sender {
	[self load];
}

// Technically everwhere I've found says to override layoutSubviews on UIScrollView but this works just fine.
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	/*if (scrollView==tagView) {
		// TODO: Detect when there is no need to scroll and disable all fading
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
		float offset = scrollView.contentOffset.x;
		NSLog(@"offset:%i", (int)((int)tagView.contentOffset.x % (int)tagView.contentSize.width));
		if (offset<=5) {
			if (tagMaskLeft==nil) {
				// fade right
				CAGradientLayer *mask = [CAGradientLayer layer];
				mask.locations = [NSArray arrayWithObjects:
								  [NSNumber numberWithFloat:0.0],
								  [NSNumber numberWithFloat:0.0],
								  [NSNumber numberWithFloat:0.0],
								  [NSNumber numberWithFloat:1.0],
								  nil];
				
				mask.colors = [NSArray arrayWithObjects:
							   (id)[UIColor whiteColor].CGColor,
							   (id)[UIColor whiteColor].CGColor,
							   (id)[UIColor whiteColor].CGColor,
							   (id)[UIColor clearColor].CGColor,
							   nil];
				
				mask.frame = tagView.bounds;
				// vertical direction
				mask.startPoint = CGPointMake(0.9, 0);
				mask.endPoint = CGPointMake(1, 0);
				tagMaskLeft = mask;
			}
			tagView.layer.mask = tagMaskLeft;
		}
		if (offset>=208-5) {
			if (tagMaskRight==nil) {
				// fade left
				CAGradientLayer *mask = [CAGradientLayer layer];
				mask.locations = [NSArray arrayWithObjects:
								  [NSNumber numberWithFloat:0.0],
								  [NSNumber numberWithFloat:0.0],
								  [NSNumber numberWithFloat:0.0],
								  [NSNumber numberWithFloat:1.0],
								  nil];
				
				mask.colors = [NSArray arrayWithObjects:
							   (id)[UIColor whiteColor].CGColor,
							   (id)[UIColor whiteColor].CGColor,
							   (id)[UIColor whiteColor].CGColor,
							   (id)[UIColor clearColor].CGColor,
							   nil];
				
				mask.frame = tagView.bounds;
				// vertical direction
				mask.startPoint = CGPointMake(0.2, 0);
				mask.endPoint = CGPointMake(0.1, 0);
				
				tagMaskRight = mask;
			}
			tagView.layer.mask = tagMaskRight;
		}
		if (offset>0 && offset<=208-5) {
			if (tagMaskMiddle==nil) {
				// fade both
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
				
				mask.frame = tagView.bounds;
				// vertical direction
				mask.startPoint = CGPointMake(0, 0);
				mask.endPoint = CGPointMake(1, 0);
				
				tagMaskMiddle = mask;
			}
			tagView.layer.mask = tagMaskMiddle;
		}
		CGRect layerMaskFrame = tagView.layer.mask.frame;
		layerMaskFrame.origin = [self.view convertPoint:tagView.bounds.origin toView:self.view];
		
		tagView.layer.mask.frame = layerMaskFrame;
		[CATransaction commit];
	}*/
	if (scrollView==bioTextView) {
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
		float offset = scrollView.contentOffset.y;
		if (offset<=0) {
			// remove fade mask
			//NSLog(@"bioTextView scroll at top");
			bioTextView.layer.mask = nil;
		}
		else {
			if (bioMask==nil) {
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
				
				bioMask = mask;
			}
			bioTextView.layer.mask = bioMask;
		}
		
		CGRect layerMaskFrame = bioTextView.layer.mask.frame;
		layerMaskFrame.origin = [self.view convertPoint:bioTextView.bounds.origin toView:self.view];
		
		bioTextView.layer.mask.frame = layerMaskFrame;
		[CATransaction commit];
	}
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
	//NSLog(@"progress:%f", progress);
	/*
	if (ceil(currentTime)==ceil(playbackDuration.intValue)) {
		MPMediaItem *mediaItem = [iPodController nowPlayingItem];
		NSString *artistName = [mediaItem valueForKey:MPMediaItemPropertyArtist];
		NSString *albumName = [mediaItem valueForKey:MPMediaItemPropertyAlbumTitle];
		NSString *trackName = [mediaItem valueForKey:MPMediaItemPropertyTitle];
		MPMediaItemArtwork *artwork = [mediaItem valueForKey:MPMediaItemPropertyArtwork];
		[albumArtView setImage:[artwork imageWithSize:CGSizeMake(30, 30)]];
		[artist setText:artistName];
		[album setText:albumName];
		[track setText:trackName];
	}
	 */
}

- (void)loadInfoFromiPod {
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
	dispatch_async(queue,^{
		MPMediaItem *mediaItem = [iPodController nowPlayingItem];
		NSString *artistName = [mediaItem valueForKey:MPMediaItemPropertyArtist];
		NSString *albumName = [mediaItem valueForKey:MPMediaItemPropertyAlbumTitle];
		NSString *trackName = [mediaItem valueForKey:MPMediaItemPropertyTitle];
		MPMediaItemArtwork *artwork = [mediaItem valueForKey:MPMediaItemPropertyArtwork];
		artistInfo = [[LastFMArtistInfo alloc] init];
		[artistInfo setDelegate:self];
		[artistInfo requestInfoWithArtist:artistName];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[albumArtView setImage:[artwork imageWithSize:CGSizeMake(30, 30)]];
			[artist setText:artistName];
			[album setText:albumName];
			[track setText:trackName];
			[refreshControl endRefreshing];
			
			if (playbackTimer == nil)
				playbackTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updatePlaybackProgress) userInfo:nil repeats:YES];
		});
	});
}

- (void)load {
	dispatch_async(dispatch_get_main_queue(), ^{
		[refreshControl beginRefreshing];
	});
	iPodController = [MPMusicPlayerController iPodMusicPlayer];
	if ([iPodController playbackState]==MPMusicPlaybackStatePlaying) {
		[self loadInfoFromiPod];
	}
	else {
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
		dispatch_async(queue,^{
			// remove playback timer updating if the iPod is no longer playing
			if ([playbackTimer isValid])
				[playbackTimer invalidate];
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
	// only display tracks from Last.fm is we are currently playing
	if ([_track nowPlaying]) {
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
			// setup get track info.. maybe make this an instance variable?
			LFMTrackInfo *trackInfo = [[LFMTrackInfo alloc] init];
			[trackInfo setDelegate:self];
			if (![[_track musicBrainzID] isEqualToString:@""]) {
				[artistInfo requestInfoWithMusicBrainzID:[_track musicBrainzID]];
				[trackInfo requestInfo:[_track artist] withTrack:[_track track]];
			}
			else {
				[artistInfo requestInfoWithArtist:[_track artist]];
				[trackInfo requestInfo:[_track artist] withTrack:[_track track]];
			}
		});
	}
	else {
		// reverting to iPod info even if not playing or perhaps show nothing all together
		[self loadInfoFromiPod];
	}
}

- (void)didFailToReceiveRecentTracks:(NSError *)error {
    NSLog(@"Failed to receive track with error:%@", [error description]);
}

#pragma mark - LastFMArtistInfo Delegate

- (void)didReceiveArtistInfo: (LFMArtist *)_artist; {
	//NSLog(@"tags:%u", [[_artist tags] count]);
	//NSString *tagString = [[_artist tags] stringWithDelimeter:@", "];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *blurredImage = [[_artist image] imageByApplyingGaussianBlur5x5];
        [bioTextView setText:[[_artist bio] stringByDecodingHTMLEntities]];
		NSLog(@"bio:%@", [[_artist bio] stringByDecodingHTMLEntities]);
        [artistImageView setImage:blurredImage];
		[tagView setTags:[_artist tags]];
    });
}

- (void)didFailToReceiveArtistDetails:(NSError *)error {
    NSLog(@"Failed to receive track with error:%@", [error description]);
}

#pragma mark - LFMTrackInfo Delegate

- (void)didReceiveTrackInfo:(LFMTrack *)_track {
	dispatch_async(dispatch_get_main_queue(), ^{
		[album setText:[_track album]];
		[albumArtView setImage:[_track artwork]];
		[refreshControl endRefreshing];
	});
}

- (void)didFailToReceiveTrackInfo:(NSError *)error {
	NSLog(@"Failed to receive track info with error:%@", [error description]);
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
