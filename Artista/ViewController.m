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
	
	// setup quilt view
	photoGridView.delegate = self;
	photoGridView.dataSource = self;
	
	// disable scroll to top on tag view
	tagView.scrollsToTop = NO;
	// change scrolls to top to Biography view
	bioTextView.scrollsToTop = YES;
	albumGridView.scrollsToTop = NO;
	topTracksTableView.scrollsToTop = NO;
	photoGridView.scrollsToTop = NO;
	
	// set track table separator to semi transparent
	topTracksTableView.separatorColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
	
	// setup refreshing
	refreshButton.imageView.animationImages = @[[UIImage imageNamed:@"refresh-0.png"],
	[UIImage imageNamed:@"refresh-1.png"],
	[UIImage imageNamed:@"refresh-2.png"],
	[UIImage imageNamed:@"refresh-3.png"],
	[UIImage imageNamed:@"refresh-4.png"],
	[UIImage imageNamed:@"refresh-5.png"],
	[UIImage imageNamed:@"refresh-6.png"],
	[UIImage imageNamed:@"refresh-7.png"],
	[UIImage imageNamed:@"refresh-8.png"],
	[UIImage imageNamed:@"refresh-9.png"],
	[UIImage imageNamed:@"refresh-10.png"],
	[UIImage imageNamed:@"refresh-11.png"]];
	refreshButton.imageView.animationDuration = 0.5;
	
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
	
	// make sure the photo gallery view is never really "blank" while loading in the beginning
	[self performSelector:@selector(setupPhotoGridPagingButton) withObject:nil afterDelay:0.0];
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

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
	/*if (isInPhotoviewer)
		return UIInterfaceOrientationMaskAll;
	else*/
	return UIInterfaceOrientationMaskPortrait;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Account"])
	{
        AccountViewController *accountViewController = segue.destinationViewController;
        [accountViewController setDelegate:self];
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
					[UIView animateWithDuration:0.25
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
					[UIView animateWithDuration:0.25
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
					[UIView animateWithDuration:0.25
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
					[UIView animateWithDuration:0.25
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

#pragma mark - Refresh

- (IBAction)didPressReload:(id)sender
{
	// only allow reloading if we aren't already loading
	if (!refreshButton.imageView.isAnimating)
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

#pragma mark - Main Loading Methods

- (void)loadInfoFromiPod {
	if (artistImageView.alpha==1.0)
		dispatch_async(dispatch_get_main_queue(), ^{
			[self undoResetChanges];
		});
	if ([iPodController playbackState]==MPMusicPlaybackStateStopped) {
		[self reset:YES];
		return;
	}
	// let the refresher know we're using the iPod info
	isUsingiPod = YES;
	MPMediaItem *mediaItem = [iPodController nowPlayingItem];
	NSString *artistName = [mediaItem valueForKey:MPMediaItemPropertyArtist];
	
	// bail if the artist didn't change
	if ([artistName isEqualToString:previousArtistName])
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			[refreshButton.imageView stopAnimating];
		});
		return;
	}
	// otherwise let the refresher know we're going to continue loading the artist
	previousArtistName = artistName;
	
	// used if the player notification is called
	dispatch_async(dispatch_get_main_queue(), ^{
		[refreshButton.imageView startAnimating];
	});
	// immediately setup ipod info
	dispatch_async(dispatch_get_main_queue(), ^{
		[artist setText:artistName];
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
		// if there's an error bail and reset
		if (error!=nil)
		{
			isFinishedLoadingArtistInfo = NO;
			isFinishedLoadingTopAlbums = NO;
			isFinishedLoadingTopTracks = NO;
			isFinishedLoadingArtistImages = NO;
			[self reset:NO];
		}
		[[SDImageCache sharedImageCache] cleanDisk];
		if (images.count==0 || paging)
		{
			if (images.count==0)
			{
				UIImage *image = [UIImage imageNamed:@"top-default.png"];
				dispatch_async(dispatch_get_main_queue(), ^{
					[photoGridView reloadData];
					[artistImageView setImage:image];
					//[self performSelector:@selector(setupPhotoGridPagingButton) withObject:nil afterDelay:0.0];
				});
				[pagingButton removeFromSuperview];
				// show the empty image view for the albums
				if (emptyPhotosImageView==nil)
					emptyPhotosImageView = [[UIImageView alloc] init];
				else
					[emptyPhotosImageView removeFromSuperview];
				UIImage *errorImage = [UIImage imageNamed:@"no-photos.png"];
				[emptyPhotosImageView setFrame:CGRectMake(0, (photoGridView.frame.size.height/2)-49-(errorImage.size.height/3), errorImage.size.width, errorImage.size.height)];
				[emptyPhotosImageView setCenter:CGPointMake(photoGridView.center.x, emptyPhotosImageView.center.y)];
				[emptyPhotosImageView setImage:errorImage];
				// only undo reset changes
				if (emptyPhotosImageView.alpha!=1.0)
					[emptyPhotosImageView setAlpha:0.0];
				[photoGridView addSubview:emptyPhotosImageView];
				dispatch_async(dispatch_get_main_queue(), ^{
				[UIView animateWithDuration:0.25
									  delay:0
									options:UIViewAnimationCurveEaseIn
								 animations:^{
									 [emptyPhotosImageView setAlpha:1.0];
								 }
								 completion:^(BOOL finished){
								 }];
				});
				
				isFinishedLoadingArtistImages = YES;
				[self finishLoadingAction];
			}
			if (paging)
			{
				dispatch_async(dispatch_get_main_queue(), ^{
					[photoGridView reloadData];
					[self performSelector:@selector(setupPhotoGridPagingButton) withObject:nil afterDelay:0.0];
				});
			}
			return;
		}
		if (emptyPhotosImageView.alpha==1.0)
		{
			[UIView animateWithDuration:0.25
								  delay:0
								options:UIViewAnimationCurveEaseIn
							 animations:^{
								 [emptyPhotosImageView setAlpha:0.0];
							 }
							 completion:^(BOOL finished){
								 [emptyPhotosImageView removeFromSuperview];
							 }];
		}
		LFMArtistImage *artistImage = [images objectAtIndex:arc4random() % images.count];
		__block UIImage *image;
		dispatch_async(queue,^{
			NSMutableURLRequest *request = [NSMutableURLRequest
											requestWithURL:[artistImage.qualities objectForKey:@"original"]
											cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
			NSError *connectionError;
			NSData *data = [NSURLConnection sendSynchronousRequest:request
												 returningResponse:nil error:&connectionError];
			if (connectionError!=nil)
			{
				NSLog(@"there was an error loading the image");
			}
			
			image = [UIImage imageWithData:data];
			if ([UIScreen mainScreen].scale==2.0f)
				image = [image imageToFitSize:(CGSize){640, 250} method:MGImageResizeCropStart];
			else
				image = [image imageToFitSize:(CGSize){320, 125} method:MGImageResizeCropStart];
			dispatch_async(dispatch_get_main_queue(), ^{
				[artistImageView setImage:image];
				[photoGridView reloadData];
				[self performSelector:@selector(setupPhotoGridPagingButton) withObject:nil afterDelay:0.0];
			});
			isFinishedLoadingArtistImages = YES;
			[self finishLoadingAction];
		});
	}];
}

- (void)undoResetChanges
{
	[[[tabBar items] objectAtIndex:1] setEnabled:YES];
	[[[tabBar items] objectAtIndex:2] setEnabled:YES];
	[[[tabBar items] objectAtIndex:3] setEnabled:YES];
	[UIView animateWithDuration:0.25
						  delay:0
						options:UIViewAnimationCurveEaseIn
					 animations:^{
						 [errorImageView setAlpha:0.0];
						 [artistImageView setAlpha:1.0];
						 [artistGradientView setAlpha:1.0];
					 }
					 completion:^(BOOL finished){
						 //[errorImageView removeFromSuperview];
					 }];
}

- (void)reset:(BOOL)isInternetWorking {
	// clear out tables
	topAlbumsArray = nil;
	topTracksArray = nil;
	artistImages = nil;
	// reset previous artists... this way in case we try reloading an artist after a failure it works
	previousArtistMusicBrainzID = @"";
	previousArtistName = @"";
	dispatch_async(dispatch_get_main_queue(), ^{
		[refreshButton.imageView stopAnimating];
		// select middle item, biography
		[tabBar setSelectedItem:[[tabBar items] objectAtIndex:0]];
		// simulate switch back to biography to show the message
		[self tabBar:tabBar didSelectItem:[[tabBar items] objectAtIndex:0]];
		// disable other tabs
		[[[tabBar items] objectAtIndex:1] setEnabled:NO];
		[[[tabBar items] objectAtIndex:2] setEnabled:NO];
		[[[tabBar items] objectAtIndex:3] setEnabled:NO];
		// remove all possible empty image views
		if (emptyBioImageView.alpha==1.0)
		{
			[UIView animateWithDuration:0.25
								  delay:0
								options:UIViewAnimationCurveEaseIn
							 animations:^{
								 [emptyBioImageView setAlpha:0.0];
							 }
							 completion:^(BOOL finished){
								 [emptyBioImageView removeFromSuperview];
							 }];
		}
		if (emptyAlbumsImageView.alpha==1.0)
		{
			[UIView animateWithDuration:0.25
								  delay:0
								options:UIViewAnimationCurveEaseIn
							 animations:^{
								 [emptyAlbumsImageView setAlpha:0.0];
							 }
							 completion:^(BOOL finished){
								 [emptyAlbumsImageView removeFromSuperview];
							 }];
		}
		if (emptyPhotosImageView.alpha==1.0)
		{
			[UIView animateWithDuration:0.25
								  delay:0
								options:UIViewAnimationCurveEaseIn
							 animations:^{
								 [emptyPhotosImageView setAlpha:0.0];
							 }
							 completion:^(BOOL finished){
								 [emptyPhotosImageView removeFromSuperview];
							 }];
		}
		// Internet isn't working display message.
		if (errorImageView==nil)
			errorImageView = [[UIImageView alloc] init];
		else
			[errorImageView removeFromSuperview];
		[bioTextView setText:@""];
		UIImage *errorImage;
		if (isInternetWorking==NO) {
			errorImage = [UIImage imageNamed:@"no-connection.png"];
			//[bioTextView setText:@"Artista requires an active internet connection. It is also possible that Last.fm is either down or having issues and is unable to display information at this time. Sorry for any inconvenience, but if this is the case please try again later."];
		}
		// Internet is working but absolutely nothing is playing. Display message.
		else {
			errorImage = [UIImage imageNamed:@"no-music.png"];
			//[bioTextView setText:@"Nothing is playing at the moment. Viewing information about the artist requires a song to be currently playing. If your Last.fm account is linked please ensure that your audio application is scrobbling successfully or try pulling to refresh again."];
		}
		[errorImageView setFrame:CGRectMake(0, (bioTextView.frame.size.height/2)-49-(errorImage.size.height/3), errorImage.size.width, errorImage.size.height)];
		[errorImageView setCenter:CGPointMake(bioTextView.center.x, errorImageView.center.y)];
		[errorImageView setImage:errorImage];
		// only undo reset changes
		if (artistImageView.alpha!=0.5) {
			[artistImageView setAlpha:0.5];
			[errorImageView setAlpha:0.0];
		}
		[bioTextView addSubview:errorImageView];
		[UIView animateWithDuration:0.25
							  delay:0
							options:UIViewAnimationCurveEaseIn
						 animations:^{
							 [errorImageView setAlpha:1.0];
							 [artistImageView setAlpha:0.5];
							 [artistGradientView setAlpha:0.5];
						 }
						 completion:^(BOOL finished){
						 }];
		// make sure the hidden view still works
		[self setupHiddenVersionView];
		[artistImageView setImage:nil];
		[tagView setTags:nil];
		[topTracksTableView reloadData];
		[albumGridView reloadData];
		// reset photo grid and top image
		[artistImageView setImage:[UIImage imageNamed:@"top-default.png"]];
		[self performSelector:@selector(setupPhotoGridPagingButton) withObject:nil afterDelay:0.0];
		[photoGridView reloadData];
		[artist setText:nil];
	});
}

- (void)load {
	dispatch_async(dispatch_get_main_queue(), ^{
		[refreshButton.imageView startAnimating];
	});
	iPodController = [MPMusicPlayerController iPodMusicPlayer];
	// begin generating notifications now because even if we aren't playing then at some point we will be and we want to be ready for it
	[iPodController beginGeneratingPlaybackNotifications];
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
	// TODO: Implement network timeout detection. Maybe?
	// this will go through only if we're playing from the iPod
	if (isUsingiPod && isFinishedLoadingArtistInfo && isFinishedLoadingTopAlbums && isFinishedLoadingTopTracks && isFinishedLoadingArtistImages) {
		#if !(TARGET_IPHONE_SIMULATOR)
		dispatch_async(dispatch_get_main_queue(), ^{
			[refreshButton.imageView stopAnimating];
		});
		isFinishedLoadingArtistInfo = NO;
		isFinishedLoadingTopAlbums = NO;
		isFinishedLoadingTopTracks = NO;
		isFinishedLoadingArtistImages = NO;
		#endif
	}
	if (isFinishedLoadingArtistInfo && isFinishedLoadingTopAlbums && isFinishedLoadingTopTracks && isFinishedLoadingArtistImages) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[refreshButton.imageView stopAnimating];
		});
		isFinishedLoadingArtistInfo = NO;
		isFinishedLoadingTopAlbums = NO;
		isFinishedLoadingTopTracks = NO;
		isFinishedLoadingArtistImages = NO;
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
	float bottomBarHeight = 49;
	float y;
	
	if (bioTextView.contentSize.height > bioTextView.frame.size.height) {
		y = bioTextView.contentSize.height+bottomBarHeight;
	}
	// if the text doesn't fill up the entire view then append the text at the bottom of the view
	else {
		y = bioTextView.frame.size.height;
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

#pragma mark - Setup Paging for Photo Grid View

- (void)setupPhotoGridPagingButton
{
	// Remove old label
	[pagingButton removeFromSuperview];
	
	UIImage *buttonImage = [UIImage imageNamed:@"dots.png"];
	float height = buttonImage.size.height; //31;
	float width = buttonImage.size.width; //85;
	float padding = 10;
	float y = photoGridView.contentSize.height;
	float bottomBarHeight = 49;
	
	photoGridView.contentInset = UIEdgeInsetsMake(0, 0, padding+height+bottomBarHeight, 0);	
		
	pagingButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[pagingButton addTarget:self
					 action:@selector(page:)
	 forControlEvents:UIControlEventTouchDown];
	pagingButton.frame = CGRectMake(0, y, width, height);
	[pagingButton setImage:buttonImage forState:UIControlStateNormal];
	[pagingButton setImage:[UIImage imageNamed:@"dots-pressed.png"] forState:UIControlStateHighlighted];
	pagingButton.center = CGPointMake(photoGridView.center.x, pagingButton.center.y);
	[photoGridView addSubview:pagingButton];
	
	// grey out the button and disable it if there are no more pages to load
	if ([artistImages page_index]<[artistImages page_count])
	{
		[pagingButton setAlpha:1.0];
		[pagingButton setEnabled:YES];
	}
	else
	{
		[pagingButton setAlpha:0.3];
		[pagingButton setEnabled:NO];
	}
}

- (void)page:(id)sender
{
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
	dispatch_async(queue,^{
		[artistImages loadNewPage];
	});
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
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
		dispatch_async(queue,^{
			dispatch_async(dispatch_get_main_queue(), ^{
				[artist setText:[_track artist]];
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
			if (topTracks==nil) {
				topTracks = [[LFMArtistTopTracks alloc] init];
				[topTracks setDelegate:self];
			}
			if (artistImages==nil)
			{
				artistImages = [LFMArtistImages new];
			}
			
			// request all the info
			if (![[_track musicBrainzID] isEqualToString:@""]) {
				// bail if the music brainz ID didn't change
				if ([[_track musicBrainzID] isEqualToString:previousArtistMusicBrainzID])
				{
					dispatch_async(dispatch_get_main_queue(), ^{
						[refreshButton.imageView stopAnimating];
					});
					return;
				}
				// otherwise let the refresher know we're going to continue loading the artist
				previousArtistMusicBrainzID = [_track musicBrainzID];
				
				dispatch_async(queue,^{
				[artistInfo requestInfoWithMusicBrainzID:[_track musicBrainzID]];
				});
				dispatch_async(queue,^{
				[topAlbums requestTopAlbumsWithMusicBrainzID:[_track musicBrainzID]];
				});
				dispatch_async(queue,^{
				[topTracks requestTopTracksWithMusicBrainzID:[_track musicBrainzID]];
				});
				[artistImages requestImagesWithMusicBrainzID:[_track musicBrainzID] completion:^(NSArray *images, NSError *error, BOOL paging) {
					// if there's an error bail and reset
					if (error!=nil)
					{
						isFinishedLoadingArtistInfo = NO;
						isFinishedLoadingTopAlbums = NO;
						isFinishedLoadingTopTracks = NO;
						isFinishedLoadingArtistImages = NO;
						[self reset:NO];
					}
					[[SDImageCache sharedImageCache] cleanDisk];
					if (images.count==0 || paging)
					{
						if (images.count==0)
						{
							UIImage *image = [UIImage imageNamed:@"top-default.png"];
							dispatch_async(dispatch_get_main_queue(), ^{
								[photoGridView reloadData];
								[artistImageView setImage:image];
								//[self performSelector:@selector(setupPhotoGridPagingButton) withObject:nil afterDelay:0.0];
							});
							// show the empty image view for the albums
							if (emptyPhotosImageView==nil)
								emptyPhotosImageView = [[UIImageView alloc] init];
							else
								[emptyPhotosImageView removeFromSuperview];
							UIImage *errorImage = [UIImage imageNamed:@"no-photos.png"];
							[emptyPhotosImageView setFrame:CGRectMake(0, (photoGridView.frame.size.height/2)-49-(errorImage.size.height/3), errorImage.size.width, errorImage.size.height)];
							[emptyPhotosImageView setCenter:CGPointMake(photoGridView.center.x, emptyPhotosImageView.center.y)];
							[emptyPhotosImageView setImage:errorImage];
							// only undo reset changes
							if (emptyPhotosImageView.alpha!=1.0)
								[emptyPhotosImageView setAlpha:0.0];
							[photoGridView addSubview:emptyPhotosImageView];
							dispatch_async(dispatch_get_main_queue(), ^{
								[UIView animateWithDuration:0.25
													  delay:0
													options:UIViewAnimationCurveEaseIn
												 animations:^{
													 [emptyPhotosImageView setAlpha:1.0];
												 }
												 completion:^(BOOL finished){
												 }];
							});

							isFinishedLoadingArtistImages = YES;
							[self finishLoadingAction];
						}
						if (paging)
						{
							dispatch_async(dispatch_get_main_queue(), ^{
								[photoGridView reloadData];
								[self performSelector:@selector(setupPhotoGridPagingButton) withObject:nil afterDelay:0.0];
							});
						}
						return;
					}
					if (emptyPhotosImageView.alpha==1.0)
					{
						dispatch_async(dispatch_get_main_queue(), ^{
							[UIView animateWithDuration:0.25
												  delay:0
												options:UIViewAnimationCurveEaseIn
											 animations:^{
												 [emptyPhotosImageView setAlpha:0.0];
											 }
											 completion:^(BOOL finished){
												 [emptyPhotosImageView removeFromSuperview];
											 }];
						});
					}
					LFMArtistImage *artistImage = [images objectAtIndex:arc4random() % images.count];
					__block UIImage *image;
					dispatch_async(queue,^{
						NSMutableURLRequest *request = [NSMutableURLRequest
														 requestWithURL:[artistImage.qualities objectForKey:@"original"]
														 cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
						NSError *connectionError;
						NSData *data = [NSURLConnection sendSynchronousRequest:request
														   returningResponse:nil error:&connectionError];
						if (connectionError!=nil)
						{
							NSLog(@"there was an error loading the image");
						}
						
						image = [UIImage imageWithData:data];
						if ([UIScreen mainScreen].scale==2.0f)
							image = [image imageToFitSize:(CGSize){640, 250} method:MGImageResizeCropStart];
						else
							image = [image imageToFitSize:(CGSize){320, 125} method:MGImageResizeCropStart];
						dispatch_async(dispatch_get_main_queue(), ^{
							[artistImageView setImage:image];
							[photoGridView reloadData];
							[self performSelector:@selector(setupPhotoGridPagingButton) withObject:nil afterDelay:0.0];
						});
						isFinishedLoadingArtistImages = YES;
						[self finishLoadingAction];
					});
				}];
			}
			else {
				// bail if the artist didn't change
				if ([[_track artist] isEqualToString:previousArtistName])
				{
					dispatch_async(dispatch_get_main_queue(), ^{
						[refreshButton.imageView stopAnimating];
					});
					return;
				}
				// otherwise let the refresher know we're going to continue loading the artist
				previousArtistName = [_track artist];
				
				dispatch_async(queue,^{
				[artistInfo requestInfoWithArtist:[_track artist]];
				});
				dispatch_async(queue,^{
				[topAlbums requestTopAlbumsWithArtist:[_track artist]];
				});
				dispatch_async(queue,^{
				[topTracks requestTopTracksWithArtist:[_track artist]];
				});
				[artistImages requestImagesWithArtist:[_track artist] completion:^(NSArray *images, NSError *error, BOOL paging) {
					// if there's an error bail and reset
					if (error!=nil)
					{
						isFinishedLoadingArtistInfo = NO;
						isFinishedLoadingTopAlbums = NO;
						isFinishedLoadingTopTracks = NO;
						isFinishedLoadingArtistImages = NO;
						[self reset:NO];
					}
					[[SDImageCache sharedImageCache] cleanDisk];
					if (images.count==0 || paging)
					{
						if (images.count==0)
						{
							UIImage *image = [UIImage imageNamed:@"top-default.png"];
							dispatch_async(dispatch_get_main_queue(), ^{
								[photoGridView reloadData];
								[artistImageView setImage:image];
								//[self performSelector:@selector(setupPhotoGridPagingButton) withObject:nil afterDelay:0.0];
							});
							// show the empty image view for the albums
							if (emptyPhotosImageView==nil)
								emptyPhotosImageView = [[UIImageView alloc] init];
							else
								[emptyPhotosImageView removeFromSuperview];
							UIImage *errorImage = [UIImage imageNamed:@"no-photos.png"];
							[emptyPhotosImageView setFrame:CGRectMake(0, (photoGridView.frame.size.height/2)-49-(errorImage.size.height/3), errorImage.size.width, errorImage.size.height)];
							[emptyPhotosImageView setCenter:CGPointMake(photoGridView.center.x, emptyPhotosImageView.center.y)];
							[emptyPhotosImageView setImage:errorImage];
							// only undo reset changes
							if (emptyPhotosImageView.alpha!=1.0)
								[emptyPhotosImageView setAlpha:0.0];
							[photoGridView addSubview:emptyPhotosImageView];
							dispatch_async(dispatch_get_main_queue(), ^{
							[UIView animateWithDuration:0.25
												  delay:0
												options:UIViewAnimationCurveEaseIn
											 animations:^{
												 [emptyPhotosImageView setAlpha:1.0];
											 }
											 completion:^(BOOL finished){
											 }];
							});
							
							isFinishedLoadingArtistImages = YES;
							[self finishLoadingAction];
						}
						if (paging)
						{
							dispatch_async(dispatch_get_main_queue(), ^{
								[photoGridView reloadData];
								[self performSelector:@selector(setupPhotoGridPagingButton) withObject:nil afterDelay:0.0];
							});
						}
						return;
					}
					if (emptyPhotosImageView.alpha==1.0)
					{
						dispatch_async(dispatch_get_main_queue(), ^{
						[UIView animateWithDuration:0.25
											  delay:0
											options:UIViewAnimationCurveEaseIn
										 animations:^{
											 [emptyPhotosImageView setAlpha:0.0];
										 }
										 completion:^(BOOL finished){
											 [emptyPhotosImageView removeFromSuperview];
										 }];
						});
					}
					LFMArtistImage *artistImage = [images objectAtIndex:arc4random() % images.count];
					__block UIImage *image;
					dispatch_async(queue,^{
						NSMutableURLRequest *request = [NSMutableURLRequest
														requestWithURL:[artistImage.qualities objectForKey:@"original"]
														cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
						NSError *connectionError;
						NSData *data = [NSURLConnection sendSynchronousRequest:request
															 returningResponse:nil error:&connectionError];
						if (connectionError!=nil)
						{
							NSLog(@"there was an error loading the image");
						}
						
						image = [UIImage imageWithData:data];
						if ([UIScreen mainScreen].scale==2.0f)
							image = [image imageToFitSize:(CGSize){640, 250} method:MGImageResizeCropStart];
						else
							image = [image imageToFitSize:(CGSize){320, 125} method:MGImageResizeCropStart];
						dispatch_async(dispatch_get_main_queue(), ^{
							[artistImageView setImage:image];
							[photoGridView reloadData];
							[self performSelector:@selector(setupPhotoGridPagingButton) withObject:nil afterDelay:0.0];
						});
						isFinishedLoadingArtistImages = YES;
						[self finishLoadingAction];
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
	isFinishedLoadingArtistInfo = NO;
	isFinishedLoadingTopAlbums = NO;
	isFinishedLoadingTopTracks = NO;
	isFinishedLoadingArtistImages = NO;
	[self reset:NO];
}

#pragma mark - LFMArtistInfo Delegate

- (void)didReceiveArtistInfo: (LFMArtist *)_artist; {
	// only undo reset changes
	if (artistImageView.alpha==0.5)
		dispatch_async(dispatch_get_main_queue(), ^{
			[self undoResetChanges];
		});
	if ([[_artist bio] isEqualToString:@""])
	{
		// show the empty image view for the bio
		if (emptyBioImageView==nil)
			emptyBioImageView = [[UIImageView alloc] init];
		else
			[emptyBioImageView removeFromSuperview];
		UIImage *errorImage = [UIImage imageNamed:@"no-biography.png"];
		[emptyBioImageView setFrame:CGRectMake(0, (bioTextView.frame.size.height/2)-49-(errorImage.size.height/3), errorImage.size.width, errorImage.size.height)];
		[emptyBioImageView setCenter:CGPointMake(bioTextView.center.x, emptyBioImageView.center.y)];
		[emptyBioImageView setImage:errorImage];
		// only undo reset changes
		if (emptyBioImageView.alpha!=1.0)
			[emptyBioImageView setAlpha:0.0];
		[bioTextView addSubview:emptyBioImageView];
		dispatch_async(dispatch_get_main_queue(), ^{
		[UIView animateWithDuration:0.25
							  delay:0
							options:UIViewAnimationCurveEaseIn
						 animations:^{
							 [emptyBioImageView setAlpha:1.0];
						 }
						 completion:^(BOOL finished){
						 }];
		});
	}
	else
	{
		if (emptyBioImageView.alpha==1.0)
		{
			dispatch_async(dispatch_get_main_queue(), ^{
			[UIView animateWithDuration:0.25
								  delay:0
								options:UIViewAnimationCurveEaseIn
							 animations:^{
								 [emptyBioImageView setAlpha:0.0];
							 }
							 completion:^(BOOL finished){
								 [emptyBioImageView removeFromSuperview];
							 }];
			});
		}
	}
	NSString *stripped = [[[_artist bio] stringByDecodingHTMLEntities] stringByStrippingHTML];
	// remove the stupid space at the beginning of paragraphs
	while ([stripped rangeOfString:@"\n "].location != NSNotFound) {
		stripped = [stripped stringByReplacingOccurrencesOfString:@"\n " withString:@"\n"];
	}
    dispatch_async(dispatch_get_main_queue(), ^{
        [bioTextView setText:stripped];
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
	isFinishedLoadingArtistInfo = NO;
	isFinishedLoadingTopAlbums = NO;
	isFinishedLoadingTopTracks = NO;
	isFinishedLoadingArtistImages = NO;
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
	if ([topAlbumsArray count]==0) {
		// show the empty image view for the albums
		if (emptyAlbumsImageView==nil)
			emptyAlbumsImageView = [[UIImageView alloc] init];
		else
			[emptyAlbumsImageView removeFromSuperview];
		UIImage *errorImage = [UIImage imageNamed:@"no-albums.png"];
		[emptyAlbumsImageView setFrame:CGRectMake(0, (albumGridView.frame.size.height/2)-49-(errorImage.size.height/3), errorImage.size.width, errorImage.size.height)];
		[emptyAlbumsImageView setCenter:CGPointMake(albumGridView.center.x, emptyAlbumsImageView.center.y)];
		[emptyAlbumsImageView setImage:errorImage];
		// only undo reset changes
		if (emptyAlbumsImageView.alpha!=1.0)
			[emptyAlbumsImageView setAlpha:0.0];
		[albumGridView addSubview:emptyAlbumsImageView];
		dispatch_async(dispatch_get_main_queue(), ^{
		[UIView animateWithDuration:0.25
							  delay:0
							options:UIViewAnimationCurveEaseIn
						 animations:^{
							 [emptyAlbumsImageView setAlpha:1.0];
						 }
						 completion:^(BOOL finished){
						 }];
		});
	}
	else
	{
		if (emptyAlbumsImageView.alpha==1.0)
		{
			dispatch_async(dispatch_get_main_queue(), ^{
			[UIView animateWithDuration:0.25
								  delay:0
								options:UIViewAnimationCurveEaseIn
							 animations:^{
								 [emptyAlbumsImageView setAlpha:0.0];
							 }
							 completion:^(BOOL finished){
								 [emptyAlbumsImageView removeFromSuperview];
							 }];
			});
		}
	}
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[albumGridView reloadData];
	});
	isFinishedLoadingTopAlbums = YES;
	[self finishLoadingAction];
}

- (void)didFailToReceiveTopAlbums:(NSError *)error {
	NSLog(@"Failed to receive track info with error:%@", [error description]);
	isFinishedLoadingArtistInfo = NO;
	isFinishedLoadingTopAlbums = NO;
	isFinishedLoadingTopTracks = NO;
	isFinishedLoadingArtistImages = NO;
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
	isFinishedLoadingArtistInfo = NO;
	isFinishedLoadingTopAlbums = NO;
	isFinishedLoadingTopTracks = NO;
	isFinishedLoadingArtistImages = NO;
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
		cell = [TrackViewCell cellFromNib];
		cell.reuseIdentifier = reuseIdentifier;
		cell.backgroundColor = [UIColor clearColor];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.trackName.text = [(LFMTrack*)[topTracksArray objectAtIndex:indexPath.row] name];
		cell.listeningAndCount.text = [[NSString alloc] initWithFormat:@"%@ listeners · %@ plays", [(LFMTrack*)[topTracksArray objectAtIndex:indexPath.row] listeners], [(LFMTrack*)[topTracksArray objectAtIndex:indexPath.row] playCount]];
		cell.duration.text =  [(LFMTrack*)[topTracksArray objectAtIndex:indexPath.row] duration];
		
		return cell;
	} else {
		// using dequeued cell
		cell.backgroundColor = [UIColor clearColor];
		cell.trackName.text = [(LFMTrack*)[topTracksArray objectAtIndex:indexPath.row] name];
		cell.listeningAndCount.text = [[NSString alloc] initWithFormat:@"%@ listeners · %@ plays", [(LFMTrack*)[topTracksArray objectAtIndex:indexPath.row] listeners], [(LFMTrack*)[topTracksArray objectAtIndex:indexPath.row] playCount]];
		cell.duration.text =  [(LFMTrack*)[topTracksArray objectAtIndex:indexPath.row] duration];
		
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
	if ([collectionView isEqual:albumGridView])
		return [topAlbumsArray count];
	else
		return [artistImages.images count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	if ([collectionView isEqual:albumGridView]) {
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
	else
	{
		TMPhotoQuiltViewCell *cell = (TMPhotoQuiltViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
		if (!cell) {
			cell = [[TMPhotoQuiltViewCell alloc] init];
		}

		// handle index of 0 exception that seems to happen on instant reload
		@try {
			LFMArtistImage *artistImage = [artistImages.images objectAtIndex:indexPath.row];
			[cell.photoView setImageWithURL:[artistImage.qualities objectForKey:@"original"]
						   placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
		}
		@catch (NSException *exception) {
			NSLog(@"Index of 0... ignoring.");
		}
		
		return cell;
	}
}

#pragma mark UICollectionView delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	if ([collectionView isEqual:photoGridView]) {
		TMPhotoQuiltViewCell *cell = (TMPhotoQuiltViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
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
		[photoViewer setDoubleTapToZoomIsEnabled:YES];
		[photoViewer setZoomingIsEnabled:YES];
		LFMArtistImage *artistImage = [artistImages.images objectAtIndex:indexPath.row];
		[photoViewer setPhotoDimensions:CGSizeMake(artistImage.width, artistImage.height)];
		[photoViewer setImage:cell.photoView.image photoSize:NIPhotoScrollViewPhotoSizeOriginal];
		UITapGestureRecognizer *tapGesture = [UITapGestureRecognizer recognizerWithActionBlock:^(id recognizer) {
			void (^exit_animation)(void) =
			^{
				isInPhotoviewer = NO;
				
				// prepare view by unhiding the popOutImage and removing the photo viewer
				[popOutImageView setHidden:NO];
				[photoViewerView removeFromSuperview];
				// main photo viewer exit animation
				[UIView animateWithDuration:0.25
									  delay:0
									options:UIViewAnimationCurveEaseIn
								 animations:^{
									 // it's probably best to take a photo of the view and shrink it.. maybe?
									 [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
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
						[UIView animateWithDuration:0.25
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
		[photoViewerView addSubview:photoViewer];
		[photoViewerView sendSubviewToBack:photoViewer];
		[photoViewerView setHidden:YES];
		// animations leading up to the photoviewer
		[UIView animateWithDuration:0.25
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
							 isInPhotoviewer = YES;
							 // subtract staus bar offset
							 [photoViewerView setFrame:CGRectOffset([UIScreen mainScreen].bounds, 0, -20)];
							 [popOutImageView setHidden:YES];
							 [photoViewerView setHidden:NO];
						 }];
	}
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
