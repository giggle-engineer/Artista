//
//  ViewController.m
//  Music Info
//
//  Created by Chloe Stars on 8/14/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "UIImage+DSP.h"
#import "NSString+HTML.h"
#import "NSString_stripHtml.h"
#import "NSArray+StringWithDelimeter.h"
#import "UITag.h"
#import "AlbumViewCell.h"
#import "TrackViewCell.h"
#import "NSArray+FirstObject.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	playbackTimer = nil;
	
	// setup grid view
	albumGridView.cellSize = CGSizeMake(100.f, 100.f);
	albumGridView.backgroundColor = [UIColor clearColor];
	
	// set up navigation bar. notice that conspicuous blank space in the storyboard? yea, that's for this
	navigation = [[SVSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:@"Biography", @"Top Albums", @"Top Tracks", nil]];
	navigation.font = [UIFont fontWithName:@"Helvetica Neue" size:12];
	navigation.alpha = 0.7f;
	navigation.titleEdgeInsets = UIEdgeInsetsMake(-1, 16, 0, 16);
    [navigation addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    
	[self.view addSubview:navigation];
	
	navigation.center = CGPointMake(160, 80);
	
	// subtly dim the tag view
	tagView.alpha = 0.5;
	
	// round the corners of the album art view
	albumArtView.layer.cornerRadius = 3.0;
	albumArtView.layer.masksToBounds = YES;
	
	// skin the playback time progress view
	[playTimeProgressView setProgressImage:[UIImage imageNamed:@"progressbarfill.png"]];
	[playTimeProgressView setTrackImage:[UIImage imageNamed:@"progressbar.png"]];
	[playTimeProgressView setFrame:CGRectMake(playTimeProgressView.frame.origin.x, playTimeProgressView.frame.origin.y, playTimeProgressView.frame.size.width, 1)];
	
	// give shadow to bio text
    /*bioTextView.layer.shadowColor = [[UIColor whiteColor] CGColor];
    bioTextView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    bioTextView.layer.shadowOpacity = 1.0f;
    bioTextView.layer.shadowRadius = 0.5f;*/
	
	// set track table separator to semi transparent
	topTracksTableView.separatorColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
	
	// give shadow to artist text
    artist.layer.shadowColor = [[UIColor whiteColor] CGColor];
    artist.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    artist.layer.shadowOpacity = 0.5f;
    artist.layer.shadowRadius = 0.5f;
	
	// setup refreshing
	refreshControl = [[ODRefreshControl alloc] initInScrollView:bioTextView];
	[refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];

	albumRefreshControl = [[ODRefreshControl alloc] initInScrollView:albumGridView];
	[albumRefreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
	
	trackRefreshControl = [[ODRefreshControl alloc] initInScrollView:topTracksTableView];
	[trackRefreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
	
	// push scroll views content up past the bottom bar...
	// was bottomBarView.frame.size.height now 49 because of unaccounted for transparency height
	UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 49, 0.0);
	bioTextView.contentInset = contentInsets;
	bioTextView.scrollIndicatorInsets = contentInsets;
	albumGridView.contentInset = contentInsets;
	albumGridView.scrollIndicatorInsets = contentInsets;
	topTracksTableView.contentInset = contentInsets;
	topTracksTableView.scrollIndicatorInsets = contentInsets;
	
	// adjust tag view so that it doesn't default to being on the edges when overflowing
	UIEdgeInsets moreContentInsets = UIEdgeInsetsMake(0.0, 8.0, 0.0, 8.0);
	tagView.contentInset = moreContentInsets;
	tagView.scrollIndicatorInsets = moreContentInsets;
    
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
						   selector:@selector(load)
							   name:UIApplicationDidBecomeActiveNotification object:nil];
	[notificationCenter addObserver:self
						   selector:@selector (handleNowPlayingItemChanged:)
							   name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(handlePlaybackChanged:)
							   name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    // load Last.fm account login view. only display this on first run
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstRun"]) {
        [self performSegueWithIdentifier: @"Account"
                                  sender: nil];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Account"]) {
        AccountViewController *accountViewController = segue.destinationViewController;
        [accountViewController setDelegate:self];
    }
}

#pragma mark - Segment Control Target

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

#pragma mark - Pull to refresh

- (void)dropViewDidBeginRefreshing:(id)sender {
	[self load];
}

#pragma mark - Scrolling

// Technically everwhere I've found says to override layoutSubviews on UIScrollView but this works just fine.
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
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

- (IBAction)scrollCurrentViewToTop:(id)sender {
	// if the view is visible scroll it to the top
	if (navigation.selectedIndex==0)
		[bioTextView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
	if (navigation.selectedIndex==1)
		[albumGridView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
	if (navigation.selectedIndex==2)
		[topTracksTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

#pragma mark - iPod Change Notifications

- (void)handleNowPlayingItemChanged:(id)sender {
	// only one copy of this thread should ever be running
	if (![iPodReloadingThread isExecuting]) {
		iPodReloadingThread = [[NSThread alloc] initWithTarget:self selector:@selector(loadInfoFromiPod) object:nil];
		[iPodReloadingThread start];
	}
}

- (void)handlePlaybackChanged:(id)sender {
	// if iPod has begun playing and was paused reload
	if (lastPlaybackState==MPMusicPlaybackStateStopped) {
		if ([iPodController playbackState]==MPMusicPlaybackStatePlaying||[iPodController playbackState]==MPMusicPlaybackStatePaused) {
			if (![iPodReloadingThread isExecuting]) {
				iPodReloadingThread = [[NSThread alloc] initWithTarget:self selector:@selector(loadInfoFromiPod) object:nil];
				[iPodReloadingThread start];
			}
		}
	}
	// keep track of last playback state
	lastPlaybackState = [iPodController playbackState];
}

#pragma mark - Playback Timer

- (void)updatePlaybackProgress {
	NSTimeInterval currentTime = [iPodController currentPlaybackTime];
	NSNumber *playbackDuration = [[iPodController nowPlayingItem] valueForKey:MPMediaItemPropertyPlaybackDuration];
	float progress = currentTime/playbackDuration.intValue;
	[playTimeProgressView setProgress:progress];
}

#pragma mark - Main Loading Methods

- (void)loadInfoFromiPod {
	if ([iPodController playbackState]==MPMusicPlaybackStateStopped) {
		[self reset:YES];
		return;
	}
	// let the refresher know we're using the iPod info
	isUsingiPod = YES;
	// used if the player notification is called
	dispatch_async(dispatch_get_main_queue(), ^{
		[refreshControl beginRefreshing];
		[albumRefreshControl beginRefreshing];
		[trackRefreshControl beginRefreshing];
	});
	[iPodController beginGeneratingPlaybackNotifications];
	MPMediaItem *mediaItem = [iPodController nowPlayingItem];
	NSString *artistName = [mediaItem valueForKey:MPMediaItemPropertyArtist];
	NSString *albumName = [mediaItem valueForKey:MPMediaItemPropertyAlbumTitle];
	NSString *trackName = [mediaItem valueForKey:MPMediaItemPropertyTitle];
	MPMediaItemArtwork *artwork = [mediaItem valueForKey:MPMediaItemPropertyArtwork];
	// immediately setup ipod info
	dispatch_async(dispatch_get_main_queue(), ^{
		[albumArtView setImage:[artwork imageWithSize:CGSizeMake(30, 30)]];
		[artist setText:artistName];
		[album setText:albumName];
		[track setText:trackName];
		
		// setup playback progress bar timer
		if (playbackTimer == nil)
			playbackTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updatePlaybackProgress) userInfo:nil repeats:YES];
	});
	// only use one instance of artistInfo
	if (artistInfo==nil) {
		artistInfo = [[LFMArtistInfo alloc] init];
		[artistInfo setDelegate:self];
	}
	// setup top albums
	if (topAlbums==nil) {
		topAlbums = [[LFMArtistTopAlbums alloc] init];
		[topAlbums setDelegate:self];
	}
	// setup top tracks
	if (topTracks==nil) {
		topTracks = [[LFMArtistTopTracks alloc] init];
		[topTracks setDelegate:self];
	}
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
	dispatch_async(queue,^{
	[artistInfo requestInfoWithArtist:artistName];
	});
	dispatch_async(queue,^{
	[topAlbums requestTopAlbumsWithArtist:artistName];
	});
	dispatch_async(queue,^{
	[topTracks requestTopTracksWithArtist:artistName];
	});
}

- (void)reset:(BOOL)isInternetWorking {
	topAlbumsArray = nil;
	topTracksArray = nil;
	dispatch_async(dispatch_get_main_queue(), ^{
		[refreshControl endRefreshing];
		[albumRefreshControl endRefreshing];
		[trackRefreshControl endRefreshing];
		[navigation moveThumbToIndex:0 animate:YES];
		// Internet isn't working display message.
		if (isInternetWorking==NO) {
			[bioTextView setText:@"Artista requires an active internet connection. It is also possible that Last.fm is either down or having issues and is unable to display information at this time. Sorry for any inconvenience, but if this is the case please try again later."];
		}
		// Internet is working but absolutely nothing is playing. Display message.
		else {
			[bioTextView setText:@"Nothing is playing at the moment. Viewing information about the artist requires a song to be currently playing. If your Last.fm account is linked please insure that your application is scrobbling successfully."];
		}
		[artistImageView setImage:nil];
		[tagView setTags:nil];
		[topTracksTableView reloadData];
		[albumGridView reloadData];
		[albumArtView setImage:nil];
		[artist setText:nil];
		[album setText:nil];
		[track setText:nil];
	});
}

- (void)load {
	dispatch_async(dispatch_get_main_queue(), ^{
		[refreshControl beginRefreshing];
		[albumRefreshControl beginRefreshing];
		[trackRefreshControl beginRefreshing];
	});
	iPodController = [MPMusicPlayerController iPodMusicPlayer];
	if ([iPodController playbackState]==MPMusicPlaybackStatePlaying) {
		#if !(TARGET_IPHONE_SIMULATOR)
		// only one copy of this thread should ever be running
		if (![iPodReloadingThread isExecuting]) {
			iPodReloadingThread = [[NSThread alloc] initWithTarget:self selector:@selector(loadInfoFromiPod) object:nil];
			[iPodReloadingThread start];
		}
		#endif
	}
	else {
		// make sure we have a Last.fm account setup
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user"]!=nil) {
			dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
			dispatch_async(queue,^{
				if (recentTracks==nil) {
					recentTracks = [[LFMRecentTracks alloc] init];
					[recentTracks setDelegate:self];
				}
				[recentTracks requestInfo:[[NSUserDefaults standardUserDefaults] stringForKey:@"user"]];
			});
		}
		// default back to loading the iPod if we don't havea Last.fm account and nothing is playing
		else {
			// only one copy of this thread should ever be running
			if (![iPodReloadingThread isExecuting]) {
				iPodReloadingThread = [[NSThread alloc] initWithTarget:self selector:@selector(loadInfoFromiPod) object:nil];
				[iPodReloadingThread start];
			}
		}
	}
}

// called from each delegate that downloads data after it finishes
// this way no matter what order they finish in the final conditions the refreshing ends
- (void)finishLoadingAction {
	#warning No timeout detection
	// this will go through only if we're playing from the iPod
	if (isUsingiPod && isFinishedLoadingArtistInfo && isFinishedLoadingTopAlbums && isFinishedLoadingTopTracks) {
		#if !(TARGET_IPHONE_SIMULATOR)
		dispatch_async(dispatch_get_main_queue(), ^{
			[refreshControl endRefreshing];
			[albumRefreshControl endRefreshing];
			[trackRefreshControl endRefreshing];
		});
		isFinishedLoadingArtistInfo = NO, isFinishedLoadingTrackInfo = NO;
		isFinishedLoadingTopAlbums = NO, isFinishedLoadingTopTracks = NO;
		#endif
	}
	if (isFinishedLoadingArtistInfo && isFinishedLoadingTrackInfo && isFinishedLoadingTopAlbums && isFinishedLoadingTopTracks) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[refreshControl endRefreshing];
			[albumRefreshControl endRefreshing];
			[trackRefreshControl endRefreshing];
		});
		isFinishedLoadingArtistInfo = NO, isFinishedLoadingTrackInfo = NO;
		isFinishedLoadingTopAlbums = NO, isFinishedLoadingTopTracks = NO;
	}
}

#pragma mark - LFMRecentTracks Delegate

- (void)didReceiveRecentTracks:(NSArray*)tracks {
	// first object is most recent
	LFMTrack *_track = [tracks firstObject];
	// only display tracks from Last.fm is we are currently playing
	isUsingiPod = NO;
	#if !(TARGET_IPHONE_SIMULATOR)
	if ([_track nowPlaying]) {
	#endif
		// remove playback timer updating if the iPod is no longer playing
		if ([playbackTimer isValid]) {
			[playbackTimer invalidate], playbackTimer = nil;
			dispatch_async(dispatch_get_main_queue(), ^{
				[playTimeProgressView setProgress:0];
			});
		}
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
		dispatch_async(queue,^{
			dispatch_async(dispatch_get_main_queue(), ^{
				[artist setText:[_track artist]];
				[track setText:[_track name]];
			});
			
			// setup artist info
			if (artistInfo==nil) {
				artistInfo = [[LFMArtistInfo alloc] init];
				[artistInfo setDelegate:self];
			}
			// setup top albums
			if (topAlbums==nil) {
				topAlbums = [[LFMArtistTopAlbums alloc] init];
				[topAlbums setDelegate:self];
			}
			// setup get track info
			if (trackInfo==nil) {
				trackInfo = [[LFMTrackInfo alloc] init];
				[trackInfo setDelegate:self];
			}
			if (topTracks==nil) {
				topTracks = [[LFMArtistTopTracks alloc] init];
				[topTracks setDelegate:self];
			}
			
			// request all the info
			if (![[_track musicBrainzID] isEqualToString:@""]) {
				dispatch_async(queue,^{
				[artistInfo requestInfoWithMusicBrainzID:[_track musicBrainzID]];
				});
				dispatch_async(queue,^{
				[trackInfo requestInfo:[_track artist] withTrack:[_track name]];
				});
				dispatch_async(queue,^{
				[topAlbums requestTopAlbumsWithMusicBrainzID:[_track musicBrainzID]];
				});
				dispatch_async(queue,^{
				[topTracks requestTopTracksWithMusicBrainzID:[_track musicBrainzID]];
				});
			}
			else {
				dispatch_async(queue,^{
				[artistInfo requestInfoWithArtist:[_track artist]];
				});
				dispatch_async(queue,^{
				[trackInfo requestInfo:[_track artist] withTrack:[_track name]];
				});
				dispatch_async(queue,^{
				[topAlbums requestTopAlbumsWithArtist:[_track artist]];
				});
				dispatch_async(queue,^{
				[topTracks requestTopTracksWithArtist:[_track artist]];
				});
			}
		});
	#if !(TARGET_IPHONE_SIMULATOR)
	}
	else {
		// reverting to iPod info even if not playing or perhaps show nothing all together
		// only one copy of this thread should ever be running
		if (![iPodReloadingThread isExecuting]) {
			iPodReloadingThread = [[NSThread alloc] initWithTarget:self selector:@selector(loadInfoFromiPod) object:nil];
			[iPodReloadingThread start];
		}
	}
	#endif
}

- (void)didFailToReceiveRecentTracks:(NSError *)error {
    NSLog(@"Failed to receive track with error:%@", [error description]);
	isFinishedLoadingArtistInfo = NO, isFinishedLoadingTrackInfo = NO;
	isFinishedLoadingTopAlbums = NO, isFinishedLoadingTopTracks = NO;
	[self reset:NO];
}

#pragma mark - Setup Hidden Version View

- (void)setupHiddenVersionView {
	// Remove old label
	[versionLabel removeFromSuperview];
	[copyrightLabel removeFromSuperview];
	
	NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
	NSString *appDisplayName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
	NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
	NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
	
	UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:12];
	
	NSString *versionString = [[NSString alloc] initWithFormat:@"%@ %@ (%@)", appDisplayName, majorVersion, minorVersion];
	CGSize textSize = [versionString sizeWithFont:font];
	
	float height = textSize.height;
	float width = textSize.width;
	float padding = 30;
	float y;
	
	if (bioTextView.contentSize.height > bioTextView.frame.size.height) {
		y = bioTextView.contentSize.height + padding;
	}
	// if the text doesn't fill up the entire view then append the text at the bottom of the view
	else {
		y = bioTextView.frame.size.height - padding;
	}
	
	versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, width, height)];
	versionLabel.backgroundColor = [UIColor clearColor];
	versionLabel.textColor = [UIColor darkGrayColor];
	versionLabel.center = CGPointMake(bioTextView.center.x, versionLabel.center.y);
	versionLabel.font = font;
	versionLabel.text = versionString;
	
	NSString *copyrightString = @"Copyright © 2012 Phantom Sun Creative.";
	textSize = [copyrightString sizeWithFont:font];
	
	height = textSize.height;
	width = textSize.width;

	y = versionLabel.frame.origin.y + versionLabel.frame.size.height;
	
	copyrightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, width, height)];
	copyrightLabel.backgroundColor = [UIColor clearColor];
	copyrightLabel.textColor = [UIColor darkGrayColor];
	copyrightLabel.center = CGPointMake(bioTextView.center.x, copyrightLabel.center.y);
	copyrightLabel.font = font;
	copyrightLabel.text = copyrightString;
	
	[bioTextView addSubview:versionLabel];
	[bioTextView addSubview:copyrightLabel];
}

#pragma mark - LFMArtistInfo Delegate

- (void)didReceiveArtistInfo: (LFMArtist *)_artist; {
	//NSLog(@"tags:%u", [[_artist tags] count]);
	//NSString *tagString = [[_artist tags] stringWithDelimeter:@", "];
	NSString *stripped = [[[_artist bio] stringByDecodingHTMLEntities] stringByStrippingHTML];
	// remove the stupid space at the beginning of paragraphs
	while ([stripped rangeOfString:@"\n "].location != NSNotFound) {
		stripped = [stripped stringByReplacingOccurrencesOfString:@"\n " withString:@"\n"];
	}
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *blurredImage = [[_artist image] imageByApplyingGaussianBlur5x5];
        [bioTextView setText:stripped];
		//NSLog(@"bio:%@", [[_artist bio] stringByDecodingHTMLEntities]);
        [artistImageView setImage:blurredImage];
		[tagView setTags:[_artist tags]];
		
		[self setupHiddenVersionView];
    });
	isFinishedLoadingArtistInfo = YES;
	[self finishLoadingAction];
}

- (void)didFailToReceiveArtistDetails:(NSError *)error {
    NSLog(@"Failed to receive track with error:%@", [error description]);
	isFinishedLoadingArtistInfo = NO, isFinishedLoadingTrackInfo = NO;
	isFinishedLoadingTopAlbums = NO, isFinishedLoadingTopTracks = NO;
	[self reset:NO];
}

#pragma mark - LFMTrackInfo Delegate

- (void)didReceiveTrackInfo:(LFMTrack *)_track {
	dispatch_async(dispatch_get_main_queue(), ^{
		[album setText:[_track album]];
		[albumArtView setImage:[_track artwork]];
	});
	isFinishedLoadingTrackInfo = YES;
	[self finishLoadingAction];
}

- (void)didFailToReceiveTrackInfo:(NSError *)error {
	NSLog(@"Failed to receive track info with error:%@", [error description]);
	isFinishedLoadingArtistInfo = NO, isFinishedLoadingTrackInfo = NO;
	isFinishedLoadingTopAlbums = NO, isFinishedLoadingTopTracks = NO;
	[self reset:NO];
}

#pragma mark - LFMArtistTopAlbums Delegate

- (void)didReceiveTopAlbums:(NSArray *)albums {
	topAlbumsArray = albums;
	dispatch_async(dispatch_get_main_queue(), ^{
		[albumGridView reloadData];
	});
}

- (void)didFinishReceivingTopAlbums:(NSArray *)albums {
	topAlbumsArray = albums;
	dispatch_async(dispatch_get_main_queue(), ^{
		[albumGridView reloadData];
	});
	isFinishedLoadingTopAlbums = YES;
	[self finishLoadingAction];
}

- (void)didFailToReceiveTopAlbums:(NSError *)error {
	NSLog(@"Failed to receive track info with error:%@", [error description]);
	isFinishedLoadingArtistInfo = NO, isFinishedLoadingTrackInfo = NO;
	isFinishedLoadingTopAlbums = NO, isFinishedLoadingTopTracks = NO;
	[self reset:NO];
}

#pragma mark - LFMArtistTopTracks Delegate

- (void)didReceiveTopTracks:(NSArray *)tracks {
	topTracksArray = tracks;
	dispatch_async(dispatch_get_main_queue(), ^{
		[topTracksTableView reloadData];
	});
	isFinishedLoadingTopTracks = YES;
	[self finishLoadingAction];
}

- (void)didFailToReceiveTopTracks:(NSError *)error {
	NSLog(@"Failed to receive track info with error:%@", [error description]);
	isFinishedLoadingArtistInfo = NO, isFinishedLoadingTrackInfo = NO;
	isFinishedLoadingTopAlbums = NO, isFinishedLoadingTopTracks = NO;
	[self reset:NO];
}

#pragma mark - UITableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [topTracksArray count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString * const reuseIdentifier = @"TracksViewCell";
	
	TrackViewCell *cell = (TrackViewCell*)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	
	if (!cell) {
		//NSCParameterAssert([cell isKindOfClass:[TrackViewCell class]]);
		cell = [TrackViewCell cellFromNib];
		cell.reuseIdentifier = reuseIdentifier;
		cell.backgroundColor = [UIColor clearColor];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.trackName.text = [(LFMTrack*)[topTracksArray objectAtIndex:indexPath.row] name];
		cell.listeningAndCount.text = [[NSString alloc] initWithFormat:@"%@ listeners · %@ plays", [(LFMTrack*)[topTracksArray objectAtIndex:indexPath.row] listeners], [(LFMTrack*)[topTracksArray objectAtIndex:indexPath.row] playCount]];
		cell.duration.text =  [(LFMTrack*)[topTracksArray objectAtIndex:indexPath.row] duration];
		//cell.textLabel.text = [topTracksArray objectAtIndex:indexPath.row];
		//cell.textLabel.textColor = [UIColor blackColor];
		//cell.textLabel.shadowColor = [UIColor whiteColor];
		//cell.textLabel.shadowOffset = CGSizeMake(0, 1);
		
		return cell;
	} else {
		// using dequeued cell
		cell.backgroundColor = [UIColor clearColor];
		cell.trackName.text = [(LFMTrack*)[topTracksArray objectAtIndex:indexPath.row] name];
		cell.listeningAndCount.text = [[NSString alloc] initWithFormat:@"%@ listeners · %@ plays", [(LFMTrack*)[topTracksArray objectAtIndex:indexPath.row] listeners], [(LFMTrack*)[topTracksArray objectAtIndex:indexPath.row] playCount]];
		cell.duration.text =  [(LFMTrack*)[topTracksArray objectAtIndex:indexPath.row] duration];
		//cell.textLabel.text = [topTracksArray objectAtIndex:indexPath.row];
		//cell.textLabel.textColor = [UIColor blackColor];
		//cell.textLabel.shadowColor = [UIColor whiteColor];
		//cell.textLabel.shadowOffset = CGSizeMake(0, 1);
		
		return cell;
	}
}

// Top tracks view tracks are not selectable
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)path
{	
    return nil;
}

#pragma mark - KKGridView Data Source

- (NSUInteger)gridView:(KKGridView *)gridView numberOfItemsInSection:(NSUInteger)section
{
	return [topAlbumsArray count];
}

- (KKGridViewCell *)gridView:(KKGridView *)gridView cellForItemAtIndexPath:(KKIndexPath *)indexPath
{
	static NSString * const identifier = @"Cell";
	AlbumViewCell *cell = (AlbumViewCell *)[gridView dequeueReusableCellWithIdentifier:identifier];
	
	if (cell) {
		NSCParameterAssert([cell isKindOfClass:[AlbumViewCell class]]);
		cell.artworkView.image = [(LFMAlbum*)[topAlbumsArray objectAtIndex:indexPath.index] artwork];
		cell.nameLabel.text = [(LFMAlbum*)[topAlbumsArray objectAtIndex:indexPath.index] name];
		cell.backgroundColor = [UIColor clearColor];
		cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
		cell.contentView.backgroundColor = [UIColor clearColor];
	}
	if (!cell) {
		cell = [AlbumViewCell cellFromNib];
		cell.reuseIdentifier = identifier;
		cell.artworkView.image = [(LFMAlbum*)[topAlbumsArray objectAtIndex:indexPath.index] artwork];
		cell.nameLabel.text = [(LFMAlbum*)[topAlbumsArray objectAtIndex:indexPath.index] name];
		cell.backgroundColor = [UIColor clearColor];
		cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
		cell.contentView.backgroundColor = [UIColor clearColor];
	}
	
	return cell;
}

#pragma mark  - Account View Controller Delegate

- (void)didReceiveReceiveUsername {
    [self load];
}

- (void)didFailToReceiveUsername:(NSError *)error {
    NSLog(@"Failed to receive username with error:%@", [error description]);
	[self load];
}

// edit account options
- (IBAction)showAccountView:(id)sender {
	[self performSegueWithIdentifier: @"Account"
							  sender: nil];
}

@end
