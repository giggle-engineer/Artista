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
#import "AlbumViewCell.h"

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
	
	// push scroll views content up past the bottom bar...
	UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, bottomBarView.frame.size.height, 0.0);
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
						   selector:@selector (handle_NowPlayingItemChanged:)
							   name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil];
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

#pragma mark - iPod Change Notifications

- (void)handle_NowPlayingItemChanged:(id)sender {
	// only one copy of this thread should ever be running
	if (![iPodReloadingThread isExecuting]) {
		iPodReloadingThread = [[NSThread alloc] initWithTarget:self selector:@selector(loadInfoFromiPod) object:nil];
		[iPodReloadingThread start];
	}
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

#pragma mark -

- (void)updatePlaybackProgress {
	NSTimeInterval currentTime = [iPodController currentPlaybackTime];
	NSNumber *playbackDuration = [[iPodController nowPlayingItem] valueForKey:MPMediaItemPropertyPlaybackDuration];
	float progress = currentTime/playbackDuration.intValue;
	[playTimeProgressView setProgress:progress];
}

#pragma Main Loading Methods

- (void)loadInfoFromiPod {
	// used if the player notification is called
	dispatch_async(dispatch_get_main_queue(), ^{
		[refreshControl beginRefreshing];
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
		artistInfo = [[LastFMArtistInfo alloc] init];
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
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[refreshControl endRefreshing];
	});
}

- (void)load {
	dispatch_async(dispatch_get_main_queue(), ^{
		[refreshControl beginRefreshing];
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
	// only display tracks from Last.fm is we are currently playing
	#if !(TARGET_IPHONE_SIMULATOR)
	if ([_track nowPlaying]) {
	#endif
		// remove playback timer updating if the iPod is no longer playing
		if ([playbackTimer isValid]) {
			[playbackTimer invalidate], playbackTimer = nil;
			[playTimeProgressView setProgress:0];
		}
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
		dispatch_async(queue,^{
			dispatch_async(dispatch_get_main_queue(), ^{
				[artist setText:[_track artist]];
				[track setText:[_track track]];
			});
			
			// setup artist info
			if (artistInfo==nil) {
				artistInfo = [[LastFMArtistInfo alloc] init];
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
				[trackInfo requestInfo:[_track artist] withTrack:[_track track]];
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
				[trackInfo requestInfo:[_track artist] withTrack:[_track track]];
				});
				dispatch_async(queue,^{
				[topAlbums requestTopAlbumsWithArtist:[_track artist]];
				});
				dispatch_async(queue,^{
				[topTracks requestTopTracksWithArtist:[_track artist]];
				});
			}
			
			dispatch_async(dispatch_get_main_queue(), ^{
				[refreshControl endRefreshing];
			});
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
}

-(NSString *) stringByStrippingHTML:(NSString*)s {
	NSRange r;
	//NSString *s = [[self copy] autorelease];
	while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
		s = [s stringByReplacingCharactersInRange:r withString:@""];
	return s; }

#pragma mark - LastFMArtistInfo Delegate

- (void)didReceiveArtistInfo: (LFMArtist *)_artist; {
	//NSLog(@"tags:%u", [[_artist tags] count]);
	//NSString *tagString = [[_artist tags] stringWithDelimeter:@", "];
	NSString *stripped = [[[_artist bio] stringByDecodingHTMLEntities] stringByStrippingHTML];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *blurredImage = [[_artist image] imageByApplyingGaussianBlur5x5];
        [bioTextView setText:stripped];
		//NSLog(@"bio:%@", [[_artist bio] stringByDecodingHTMLEntities]);
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
	});
}

- (void)didFailToReceiveTrackInfo:(NSError *)error {
	NSLog(@"Failed to receive track info with error:%@", [error description]);
}

#pragma mark - LFMArtistTopAlbums Delegate

- (void)didReceiveTopAlbums:(NSArray *)albums {
	topAlbumsArray = albums;
	dispatch_async(dispatch_get_main_queue(), ^{
		[albumGridView reloadData];
	});
}

- (void)didFailToReceiveTopAlbums:(NSError *)error {
	NSLog(@"Failed to receive track info with error:%@", [error description]);
}

#pragma mark - LFMArtistTopTracks Delegate

- (void)didReceiveTopTracks:(NSArray *)tracks {
	topTracksArray = tracks;
	dispatch_async(dispatch_get_main_queue(), ^{
		[topTracksTableView reloadData];
	});
}

#pragma mark - UITableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [topTracksArray count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString * const reuseIdentifier = @"TracksViewCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
		cell.backgroundColor = [UIColor clearColor];
		cell.textLabel.text = [topTracksArray objectAtIndex:indexPath.row];
		cell.textLabel.textColor = [UIColor blackColor];
		cell.textLabel.shadowColor = [UIColor whiteColor];
		
		return cell;
	} else {
		// using dequeued cell
		cell.backgroundColor = [UIColor clearColor];
		cell.textLabel.text = [topTracksArray objectAtIndex:indexPath.row];
		cell.textLabel.textColor = [UIColor blackColor];
		cell.textLabel.shadowColor = [UIColor whiteColor];
		
		return cell;
	}
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
