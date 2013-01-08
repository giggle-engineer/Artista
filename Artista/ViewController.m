//
//  ViewController.m
//  Music Info
//
//  Created by Chloe Stars on 8/14/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "ViewController.h"
#import "NSString+HTML.h"
#import "NSString_stripHtml.h"
#import "NSArray+StringWithDelimeter.h"
#import "PSCTag.h"
#import "AlbumViewCell.h"
#import "TrackViewCell.h"
#import "NSArray+FirstObject.h"
#import "UIImage+ProportionalFill.h"
#import "TMPhotoQuiltViewCell.h"
#import "NIPhotoScrollView.h"
#import "PhotoViewerView.h"
#import "UIControl+JTTargetActionBlock.h"
#import "FTUtils+UIGestureRecognizer.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	playbackTimer = nil;
	
	// setup grid view
	albumGridView.backgroundColor = [UIColor clearColor];
	[albumGridView registerNib:[UINib nibWithNibName:@"AlbumViewCell" bundle:nil] forCellWithReuseIdentifier:@"Cell"];
	
	// setup tab bar
	UIImage *tabBackground = [[UIImage imageNamed:@"tab-bar.png"]
							  resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
	[[UITabBar appearance] setBackgroundImage:tabBackground];
    // Custom highlight image
    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"tab-highlight.png"]];
	// select middle item, biography
	[tabBar setSelectedItem:[[tabBar items] objectAtIndex:0]];
	//[[UITabBar appearance] setTintColor:[UIColor clearColor]];
	//[[UITabBar appearance] setSelectedImageTintColor:[UIColor colorWithRed:0.0 green:0.2 blue:1.0 alpha:1.0]];
	// set the images for the tab bar items
	UITabBarItem *topAlbumsItem = [[tabBar items] objectAtIndex:1];
	[topAlbumsItem setFinishedSelectedImage:[UIImage imageNamed:@"albums-selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"albums.png"]];
	UITabBarItem *biographyItem = [[tabBar items] objectAtIndex:0];
	[biographyItem setFinishedSelectedImage:[UIImage imageNamed:@"biography-selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"biography.png"]];
	UITabBarItem *topTracksItem = [[tabBar items] objectAtIndex:2];
	[topTracksItem setFinishedSelectedImage:[UIImage imageNamed:@"tracks-selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tracks.png"]];
    UITabBarItem *photosItem = [[tabBar items] objectAtIndex:3];
	[photosItem setFinishedSelectedImage:[UIImage imageNamed:@"photos-selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"photos.png"]];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{ UITextAttributeTextColor : [UIColor lightGrayColor] }
                                             forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{ UITextAttributeTextColor : [UIColor darkGrayColor] }
                                             forState:UIControlStateHighlighted];
	
	// subtly dim the tag view
	//tagView.alpha = 0.5;
	
	// setup quilt view
	photoGridView.delegate = self;
	photoGridView.dataSource = self;
	
	// round the corners of the album art view
	albumArtView.layer.cornerRadius = 3.0;
	albumArtView.layer.masksToBounds = YES;
	
	// disable scroll to top on tag view
	tagView.scrollsToTop = NO;
	// change scrolls to top to Biography view
	bioTextView.scrollsToTop = YES;
	albumGridView.scrollsToTop = NO;
	topTracksTableView.scrollsToTop = NO;
	photoGridView.scrollsToTop = NO;
	
	
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
	
	// setup refreshing
	refreshControl = [[ODRefreshControl alloc] initInScrollView:bioTextView];
	[refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];

	albumRefreshControl = [[ODRefreshControl alloc] initInScrollView:albumGridView];
	[albumRefreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
	
	trackRefreshControl = [[ODRefreshControl alloc] initInScrollView:topTracksTableView];
	[trackRefreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
	
	photosRefreshControl = [[ODRefreshControl alloc] initInScrollView:photoGridView];
	[photosRefreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
	
	// push scroll views content up past the bottom bar...
	// was bottomBarView.frame.size.height now 49 because of unaccounted for transparency height
	UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 49, 0.0);
	bioTextView.contentInset = contentInsets;
	bioTextView.scrollIndicatorInsets = contentInsets;
	albumGridView.contentInset = contentInsets;
	albumGridView.scrollIndicatorInsets = contentInsets;
	topTracksTableView.contentInset = contentInsets;
	topTracksTableView.scrollIndicatorInsets = contentInsets;
	photoGridView.contentInset = contentInsets;
	photoGridView.scrollIndicatorInsets = contentInsets;
	
	// set fonts
	//[bioTextView setFont:[UIFont fontWithName:@"Grandesign Neue Serif" size:14]];
	//[albumGridView setFont:[UIFont fontWithName:@"Grandesign Neue Serif" size:14]];
	//[topTracksTableView setFont:[UIFont fontWithName:@"Grandesign Neue Serif" size:14]];
	
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
    if ([segue.identifier isEqualToString:@"Account"])
	{
        AccountViewController *accountViewController = segue.destinationViewController;
        [accountViewController setDelegate:self];
    }
	if ([segue.identifier isEqual:@"PhotoViewer"])
	{
		//PhotoViewController *photoViewController = segue.destinationViewController;
		//[[photoViewController photoView] setImage:[UIImage imageNamed:@"placeholder.png"] photoSize:NIPhotoScrollViewPhotoSizeOriginal];
		//[[photoViewController view] setBackgroundColor:[UIColor purpleColor]];
		//NIToolbarPhotoViewController *photoViewController = segue.destinationViewController;
		//[photoViewController setChromeCanBeHidden:YES];
	}
}

#pragma mark - Tab Control Target
- (void)tabBar:(UITabBar *)_tabBar didSelectItem:(UITabBarItem *)_item
{
	int i = 0;
	for (UITabBarItem *item in [_tabBar items])
	{
		if (item==_item)
		{
			switch (i) {
				case 0:
				{
					[UIView animateWithDuration:0.50
										  delay:0
										options:UIViewAnimationCurveEaseIn
									 animations:^{
										 bioTextView.alpha = 1.0;
										 albumGridView.alpha = 0.0;
										 topTracksTableView.alpha = 0.0;
										 photoGridView.alpha = 0.0;
									 }
									 completion:^(BOOL finished){
										 bioTextView.scrollsToTop = YES;
										 albumGridView.scrollsToTop = NO;
										 topTracksTableView.scrollsToTop = NO;
										 photoGridView.scrollsToTop = NO;
									 }];
					break;
				}
				case 1:
				{
					[UIView animateWithDuration:0.50
										  delay:0
										options:UIViewAnimationCurveEaseIn
									 animations:^{
										 bioTextView.alpha = 0.0;
										 albumGridView.alpha = 1.0;
										 topTracksTableView.alpha = 0.0;
										 photoGridView.alpha = 0.0;
									 }
									 completion:^(BOOL finished){
										 bioTextView.scrollsToTop = NO;
										 albumGridView.scrollsToTop = YES;
										 topTracksTableView.scrollsToTop = NO;
										 photoGridView.scrollsToTop = NO;
									 }];
					break;
				}
				case 2:
				{
					[UIView animateWithDuration:0.50
										  delay:0
										options:UIViewAnimationCurveEaseIn
									 animations:^{
										 bioTextView.alpha = 0.0;
										 albumGridView.alpha = 0.0;
										 topTracksTableView.alpha = 1.0;
										 photoGridView.alpha = 0.0;
									 }
									 completion:^(BOOL finished){
										 bioTextView.scrollsToTop = NO;
										 albumGridView.scrollsToTop = NO;
										 topTracksTableView.scrollsToTop = YES;
										 photoGridView.scrollsToTop = NO;
									 }];
					break;
				}
				case 3:
				{
					[UIView animateWithDuration:0.50
										  delay:0
										options:UIViewAnimationCurveEaseIn
									 animations:^{
										 bioTextView.alpha = 0.0;
										 albumGridView.alpha = 0.0;
										 topTracksTableView.alpha = 0.0;
										 photoGridView.alpha = 1.0;
									 }
									 completion:^(BOOL finished){
										 bioTextView.scrollsToTop = NO;
										 albumGridView.scrollsToTop = NO;
										 topTracksTableView.scrollsToTop = NO;
										 photoGridView.scrollsToTop = YES;
									 }];
					break;
				}
				default:
					break;
			}
		}
		++i;
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
	if (scrollView==albumGridView) {
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
		float offset = scrollView.contentOffset.y;
		if (offset<=0) {
			// remove fade mask
			//NSLog(@"bioTextView scroll at top");
			albumGridView.layer.mask = nil;
		}
		else {
			if (albumsMask==nil) {
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
				
				mask.frame = albumGridView.bounds;
				// vertical direction
				mask.startPoint = CGPointMake(0, 0);
				mask.endPoint = CGPointMake(0, 1);
				
				albumsMask = mask;
			}
			albumGridView.layer.mask = albumsMask;
		}
		
		CGRect layerMaskFrame = albumGridView.layer.mask.frame;
		layerMaskFrame.origin = [self.view convertPoint:albumGridView.bounds.origin toView:self.view];
		
		albumGridView.layer.mask.frame = layerMaskFrame;
		[CATransaction commit];
	}
	if (scrollView==topTracksTableView) {
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
		float offset = scrollView.contentOffset.y;
		if (offset<=0) {
			// remove fade mask
			//NSLog(@"bioTextView scroll at top");
			topTracksTableView.layer.mask = nil;
		}
		else {
			if (tracksMask==nil) {
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
				
				mask.frame = topTracksTableView.bounds;
				// vertical direction
				mask.startPoint = CGPointMake(0, 0);
				mask.endPoint = CGPointMake(0, 1);
				
				tracksMask = mask;
			}
			topTracksTableView.layer.mask = tracksMask;
		}
		
		CGRect layerMaskFrame = topTracksTableView.layer.mask.frame;
		layerMaskFrame.origin = [self.view convertPoint:topTracksTableView.bounds.origin toView:self.view];
		
		topTracksTableView.layer.mask.frame = layerMaskFrame;
		[CATransaction commit];
	}
	if (scrollView==photoGridView) {
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
		float offset = scrollView.contentOffset.y;
		if (offset<=0) {
			// remove fade mask
			//NSLog(@"bioTextView scroll at top");
			photoGridView.layer.mask = nil;
		}
		else {
			if (photosMask==nil) {
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
				
				mask.frame = photoGridView.bounds;
				// vertical direction
				mask.startPoint = CGPointMake(0, 0);
				mask.endPoint = CGPointMake(0, 1);
				
				photosMask = mask;
			}
			photoGridView.layer.mask = photosMask;
		}
		
		CGRect layerMaskFrame = photoGridView.layer.mask.frame;
		layerMaskFrame.origin = [self.view convertPoint:photoGridView.bounds.origin toView:self.view];
		
		photoGridView.layer.mask.frame = layerMaskFrame;
		[CATransaction commit];
	}
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
		[photosRefreshControl beginRefreshing];
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
		/*if (playbackTimer == nil)
			playbackTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updatePlaybackProgress) userInfo:nil repeats:YES];*/
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
	if (artistImages==nil)
	{
		artistImages = [LFMArtistImages new];
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
	[artistImages requestImagesWithArtist:artistName completion:^(NSArray *images, NSError *error, BOOL paging) {
		[[SDImageCache sharedImageCache] cleanDisk];
		if (images.count==0 || paging)
		{
			if (images.count==0)
			{
				dispatch_async(queue,^{
					UIImage *image = [UIImage imageNamed:@"Header.png"];
					if ([UIScreen mainScreen].scale==2.0f)
						image = [image imageToFitSize:(CGSize){640, 250} method:MGImageResizeCropStart];
					else
						image = [image imageToFitSize:(CGSize){320, 125} method:MGImageResizeCropStart];
					dispatch_async(dispatch_get_main_queue(), ^{
						[artistImageView setImage:image];
					});
				});
			}
			return;
		}
		
		LFMArtistImage *artistImage = [images objectAtIndex:arc4random() % images.count];
		__block UIImage *image;
		dispatch_async(queue,^{
			image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[artistImage.qualities objectForKey:@"original"]]];
			if ([UIScreen mainScreen].scale==2.0f)
				image = [image imageToFitSize:(CGSize){640, 250} method:MGImageResizeCropStart];
			else
				image = [image imageToFitSize:(CGSize){320, 125} method:MGImageResizeCropStart];
			dispatch_async(dispatch_get_main_queue(), ^{
				[artistImageView setImage:image];
				[photoGridView reloadData];
			});
		});
	}];
}

- (void)reset:(BOOL)isInternetWorking {
	// clear out tables
	topAlbumsArray = nil;
	topTracksArray = nil;
	artistImages = nil;
	dispatch_async(dispatch_get_main_queue(), ^{
		[refreshControl endRefreshing];
		[albumRefreshControl endRefreshing];
		[trackRefreshControl endRefreshing];
		[photosRefreshControl endRefreshing];
		// select middle item, biography
		[tabBar setSelectedItem:[[tabBar items] objectAtIndex:0]];
		// simulate switch back to biography to show the message
		[self tabBar:tabBar didSelectItem:[[tabBar items] objectAtIndex:0]];
		// Internet isn't working display message.
		#warning Fix issue #3
		if (isInternetWorking==NO) {
			[bioTextView setText:@"Artista requires an active internet connection. It is also possible that Last.fm is either down or having issues and is unable to display information at this time. Sorry for any inconvenience, but if this is the case please try again later."];
		}
		// Internet is working but absolutely nothing is playing. Display message.
		else {
			[bioTextView setText:@"Nothing is playing at the moment. Viewing information about the artist requires a song to be currently playing. If your Last.fm account is linked please ensure that your audio application is scrobbling successfully or try pulling to refresh again."];
		}
		// make sure the hidden view still works
		[self setupHiddenVersionView];
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
		[photosRefreshControl beginRefreshing];
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
			[photosRefreshControl endRefreshing];
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
			[photosRefreshControl endRefreshing];
		});
		isFinishedLoadingArtistInfo = NO, isFinishedLoadingTrackInfo = NO;
		isFinishedLoadingTopAlbums = NO, isFinishedLoadingTopTracks = NO;
	}
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
	
	NSString *copyrightString = @"Copyright © 2013 Phantom Sun Creative, Ltd.";
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
			if (artistImages==nil)
			{
				artistImages = [LFMArtistImages new];
			}
			
			// move this to an iVar?
			
			
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
				[artistImages requestImagesWithMusicBrainzID:[_track musicBrainzID] completion:^(NSArray *images, NSError *error, BOOL paging) {
					[[SDImageCache sharedImageCache] cleanDisk];
					if (images.count==0 || paging)
					{
						if (images.count==0)
						{
							UIImage *image = [UIImage imageNamed:@"Login.png"];
							if ([UIScreen mainScreen].scale==2.0f)
								image = [image imageToFitSize:(CGSize){640, 250} method:MGImageResizeCropStart];
							else
								image = [image imageToFitSize:(CGSize){320, 125} method:MGImageResizeCropStart];
							[artistImageView setImage:image];
						}
						return;
					}
					//NSLog(@"IMGES:%i",artistImages.images.count);
					LFMArtistImage *artistImage = [images objectAtIndex:arc4random() % images.count];
					__block UIImage *image;
					dispatch_async(queue,^{
						image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[artistImage.qualities objectForKey:@"original"]]];
						if ([UIScreen mainScreen].scale==2.0f)
							image = [image imageToFitSize:(CGSize){640, 250} method:MGImageResizeCropStart];
						else
							image = [image imageToFitSize:(CGSize){320, 125} method:MGImageResizeCropStart];
						dispatch_async(dispatch_get_main_queue(), ^{
							[artistImageView setImage:image];
							[photoGridView reloadData];
						});
					});
				}];
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
				[artistImages requestImagesWithArtist:[_track artist] completion:^(NSArray *images, NSError *error, BOOL paging) {
					[[SDImageCache sharedImageCache] cleanDisk];
					if (images.count==0 || paging)
					{
						if (images.count==0)
						{
							dispatch_async(queue,^{
								UIImage *image = [UIImage imageNamed:@"Header.png"];
								if ([UIScreen mainScreen].scale==2.0f)
									image = [image imageToFitSize:(CGSize){640, 250} method:MGImageResizeCropStart];
								else
									image = [image imageToFitSize:(CGSize){320, 125} method:MGImageResizeCropStart];
								dispatch_async(dispatch_get_main_queue(), ^{
									[artistImageView setImage:image];
								});
							});
						}
						return;
					}

					LFMArtistImage *artistImage = [images objectAtIndex:arc4random() % images.count];
					__block UIImage *image;
					dispatch_async(queue,^{
						image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[artistImage.qualities objectForKey:@"original"]]];
						if ([UIScreen mainScreen].scale==2.0f)
							image = [image imageToFitSize:(CGSize){640, 250} method:MGImageResizeCropStart];
						else
							image = [image imageToFitSize:(CGSize){320, 125} method:MGImageResizeCropStart];
						dispatch_async(dispatch_get_main_queue(), ^{
							[artistImageView setImage:image];
							[photoGridView reloadData];
						});
					});
				}];
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
        //UIImage *blurredImage = [[_artist image] imageByApplyingGaussianBlur5x5];
        [bioTextView setText:stripped];
		//NSLog(@"bio:%@", [[_artist bio] stringByDecodingHTMLEntities]);
        //[artistImageView setImage:blurredImage];
		NSMutableArray *array = [NSMutableArray arrayWithArray:[_artist tags]];
		NSMutableArray *tagArray = [NSMutableArray new];
		int i = 0;
		for (NSString *tagString in array)
		{
			NSString *newTagString;
			++i;
			if (i!=array.count)
				newTagString = [[NSString alloc] initWithFormat:@"%@,", tagString];
			else
				newTagString = tagString;
            // Define tag text colour below
			PSCTag *tag = [[PSCTag alloc] initWithString:newTagString withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12] withTextColor:[UIColor whiteColor] withBackgroundColor:[UIColor clearColor]];
			[tagArray addObject:tag];
            //tag.shadowColor = [UIColor colorWithRed:0 green:0 blue: alpha:.35];
            //tag.shadowOffset = CGSizeMake(0, -1.0);
            
            // tag view text shadow
            tagView.layer.shadowColor = [[UIColor blackColor] CGColor];
            tagView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
            tagView.layer.shadowOpacity = 0.50f;
            tagView.layer.shadowRadius = 0.0f;
		}
		[tagView setTags:tagArray];
		
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
	/*if (albums.count==1 && topAlbumsArray.count != 0) {
		topAlbumsArray = albums;
		// remove current rows if present
		NSMutableArray *indexPaths = [NSMutableArray new];
		for (int i = 0; i==albums.count-1; i++)
		{
			[indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
		}
		[albumGridView deleteItemsAtIndexPaths:indexPaths];
	}*/
	topAlbumsArray = albums;
	dispatch_async(dispatch_get_main_queue(), ^{
		//NSLog(@"albums.count:%i",albums.count);
		//[albumGridView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:albums.count-1 inSection:0]]];
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

#pragma mark - UICollectionView Data Source

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return [topAlbumsArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString * const identifier = @"Cell";
	AlbumViewCell *cell = (AlbumViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
	
	if (!cell) {
		// setup cells
		NSCParameterAssert([cell isKindOfClass:[AlbumViewCell class]]);
		cell.backgroundColor = [UIColor clearColor];
		cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
		cell.contentView.backgroundColor = [UIColor clearColor];
	}
	
	NSURL *imageURL = [(LFMAlbum*)[topAlbumsArray objectAtIndex:indexPath.row] URL];
	// detect Last.fm's ugly default album image and replace it with the placeholder
	if (![[imageURL absoluteString] isEqualToString:@"http://cdn.last.fm/flatness/catalogue/noimage/2/default_album_medium.png"])
	{
		[cell.artworkView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"album-placeholder.png"]];
	}
	else
	{
		[cell.artworkView setImage:[UIImage imageNamed:@"album-placeholder.png"]];
	}
	cell.nameLabel.text = [(LFMAlbum*)[topAlbumsArray objectAtIndex:indexPath.row] name];
	
	
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

#pragma mark - QuiltViewControllerDataSource

- (NSInteger)quiltViewNumberOfCells:(TMQuiltView *)TMQuiltView {
	//NSLog(@"gallery:%i", artistImages.images.count);
    return [artistImages.images count];
}

- (TMQuiltViewCell *)quiltView:(TMQuiltView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath {
    TMPhotoQuiltViewCell *cell = (TMPhotoQuiltViewCell *)[quiltView dequeueReusableCellWithReuseIdentifier:@"PhotoCell"];
    if (!cell) {
        cell = [[TMPhotoQuiltViewCell alloc] initWithReuseIdentifier:@"PhotoCell"];
    }
    
	// handle index of 0 exception that seems to happen on instant reload
	@try {
		LFMArtistImage *artistImage = [artistImages.images objectAtIndex:indexPath.row];
		//[cell.photoView loadImageAtURL:[artistImage.qualities objectForKey:@"original"]];
		[cell.photoView setImageWithURL:[artistImage.qualities objectForKey:@"original"]
					   placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
	}
	@catch (NSException *exception) {
		NSLog(@"Index of 0... ignoring.");
	}
	
	cell.titleLabel.hidden = YES;
    //cell.titleLabel.text = [NSString stringWithFormat:@"%d", indexPath.row + 1];
	//cell.titleLabel.text = artistImage.title;
    return cell;
}

#pragma mark - TMQuiltViewDelegate

- (NSInteger)quiltViewNumberOfColumns:(TMQuiltView *)quiltView {
	
    
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft
        || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        return 3;
    } else {
        return 2;
    }
}

- (CGFloat)quiltView:(TMQuiltView *)quiltView heightForCellAtIndexPath:(NSIndexPath *)indexPath {
	// handle index of 0 exception that seems to happen on instant reload
	/*@try {
		LFMArtistImage *artistImage = [artistImages.images objectAtIndex:indexPath.row];
		return artistImage.height / [self quiltViewNumberOfColumns:quiltView];
	}
	@catch (NSException *exception) {
		NSLog(@"Index of 0... ignoring.");
		return 0;
	}*/
	return 100;
}

- (void)quiltView:(TMQuiltView *)quiltView didSelectCellAtIndexPath:(NSIndexPath *)indexPath;
{
	TMPhotoQuiltViewCell *cell = (TMPhotoQuiltViewCell *)[quiltView cellAtIndexPath:indexPath];
	// if we're still loading don't allow to view the image
	if ([cell.photoView.image isEqual:[UIImage imageNamed:@"placeholder.png"]])
		return;
	// hide the photo in the cell
	[cell.photoView setHidden:YES];
	// convert the coordinates of the cell from inside photoGridView to self.view
	CGRect rectInSelf = [photoGridView convertRect:cell.frame toView:self.view];
	// mirror the cell's imageview properties
	UIImageView *popOutImageView = [[UIImageView alloc] initWithFrame:rectInSelf];
	[popOutImageView setImage:cell.photoView.image];
	[popOutImageView setContentMode:UIViewContentModeScaleAspectFill];
	[popOutImageView setClipsToBounds:YES];
	PhotoViewerView *photoViewerView = [PhotoViewerView viewFromNib];
	[photoViewerView.currentPhoto setText:[[NSString alloc] initWithFormat:@"%i of %i", indexPath.row+1, [artistImages.images count]]];
	NIPhotoScrollView *photoViewer = [[NIPhotoScrollView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.origin.y-20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height+20)];
	//[photoViewer setContentMode:UIViewContentModeScaleAspectFill];
	//[photoViewer setClipsToBounds:YES];
	//[photoViewer setBackgroundColor:[UIColor purpleColor]];
	[photoViewer setDoubleTapToZoomIsEnabled:YES];
	[photoViewer setZoomingIsEnabled:YES];
	LFMArtistImage *artistImage = [artistImages.images objectAtIndex:indexPath.row];
	[photoViewer setPhotoDimensions:CGSizeMake(artistImage.width, artistImage.height)];
	[photoViewer setImage:cell.photoView.image photoSize:NIPhotoScrollViewPhotoSizeOriginal];
	UITapGestureRecognizer *tapGesture = [UITapGestureRecognizer recognizerWithActionBlock:^(id recognizer) {
		void (^exit_animation)(void) =
		^{
			// prepare view by unhiding the popOutImage and removing the photo viewer
			[popOutImageView setHidden:NO];
			[photoViewerView removeFromSuperview];
			// main photo viewer exit animation
			[UIView animateWithDuration:0.50
								  delay:0
								options:UIViewAnimationCurveEaseIn
							 animations:^{
								 // it's probably best to take a photo of the view and shrink it.. maybe?
								 [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
								 //self.view.frame = CGRectInset(self.view.frame, -5.0, -5.0);
								 self.view.backgroundColor = [UIColor whiteColor];
								 for (UIView *view in [[self view] subviews])
								 {
									 if (view!=popOutImageView && view!=albumGridView && view!=bioTextView && view!=topTracksTableView)
									 {
										 view.alpha = 1.0;
									 }
								 }
								 popOutImageView.frame = rectInSelf;
							 }
							 completion:^(BOOL finished){
								 // revert cell to normal
								 [popOutImageView removeFromSuperview];
								 cell.photoView.hidden = NO;
							 }];
			
		};
		// find the scroll view in the NIPhotoScrollView and reset the zoom
		for (UIView *view in [photoViewer subviews])
		{
			if ([view isKindOfClass:[UIScrollView class]]) {
				if ([(UIScrollView*)view zoomScale]!=0.0f)
				{
					[UIView animateWithDuration:0.50
										  delay:0
										options:UIViewAnimationCurveEaseIn
									 animations:^{
										 [(UIScrollView*)view setZoomScale:0.0f animated:NO];
									 }
									 completion:^(BOOL finished){
										 exit_animation();
									 }];
				}
				else {
					exit_animation();
				}
				
			}
		}
	}];
	[tapGesture requireGestureRecognizerToFail:photoViewer.doubleTapGestureRecognizer];
    tapGesture.numberOfTapsRequired = 1;
    [photoViewer addGestureRecognizer:tapGesture];
	[photoViewerView.shareButton addEventHandler:^(id sender, UIEvent *event) {
		UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
															initWithActivityItems:@[cell.photoView.image] applicationActivities:nil];
		activityViewController.completionHandler = ^(NSString *activityType, BOOL completed) {
			if (completed) {
				[self dismissViewControllerAnimated:YES completion:nil];
			}
			[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];
		};
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
		[self presentViewController:activityViewController animated:YES completion:nil];
	} forControlEvent:UIControlEventTouchUpInside];
	[self.view addSubview:popOutImageView];
	[self.view addSubview:photoViewerView];
	//[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[photoViewerView]" options:NSLayoutFormatAlignAllLeading metrics:nil views:NSDictionaryOfVariableBindings(photoViewerView)]];
	//NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:photoViewerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:568.0f];
	//[photoViewer addConstraint:constraint];
	[photoViewerView addSubview:photoViewer];
	[photoViewerView sendSubviewToBack:photoViewer];
	[photoViewerView setHidden:YES];
	// animations leading up to the photoviewer
	[UIView animateWithDuration:0.50
						  delay:0
						options:UIViewAnimationCurveEaseIn
					 animations:^{
						 // hide staus bar
						 [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];
						 // view dance to get the photoviewer location extraction to work
						 self.view.frame = CGRectInset(self.view.frame, 0.01, 0);
						 self.view.frame = CGRectInset(self.view.frame, -0.01, 0);
						 //self.view.frame = CGRectInset(self.view.frame, 5.0, 5.0);
						 self.view.backgroundColor = [UIColor blackColor];
						 for (UIView *view in [[self view] subviews])
						 {
							 if (view!=popOutImageView && view!=photoViewerView)
							 {
								 view.alpha = 0.0;
							 }
						 }
						 // process location of image view
						 for (UIView *view in [photoViewer subviews])
						 {
							 if ([view isKindOfClass:[UIScrollView class]]) {
								 for(UIView* subview in [view subviews]) {
									 if ([subview isKindOfClass:[UIImageView class]])
									 {
										 // adjust for adjustment because of status bar offset
										 [popOutImageView setFrame:CGRectOffset(subview.frame, 0, -40)];
									 }
								 }
							 }
						 }
					 }
					 completion:^(BOOL finished){
						 // subtract staus bar offset
						 [photoViewerView setFrame:CGRectOffset([UIScreen mainScreen].bounds, 0, -20)];
						 [popOutImageView setHidden:YES];
						 [photoViewerView setHidden:NO];
					 }];
}

@end
