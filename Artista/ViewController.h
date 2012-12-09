//
//  ViewController.h
//  Music Info
//
//  Created by Chloe Stars on 8/14/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AccountViewController.h"
#import "LFM.h"
#import "ODRefreshControl.h"
#import "PSCTagView.h"
#import "SVSegmentedControl.h"

@interface ViewController : UIViewController <AccountViewControllerDelegate, LFMRecentTracksDelegate, LFMArtistInfoDelegate, LFMTrackInfoDelegate, LFMArtistTopAlbumsDelegate, LFMArtistTopTracksDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, UITabBarDelegate> {
    IBOutlet UILabel *artist;
    IBOutlet UIImageView *artistImageView;
	IBOutlet UIProgressView *playTimeProgressView;
	IBOutlet UILabel *album;
	IBOutlet UILabel *track;
	IBOutlet UIImageView *albumArtView;
	IBOutlet UIView *bottomBarView;
	IBOutlet PSCTagView *tagView;
	IBOutlet UIView *biographyView;
	IBOutlet UIView *topAlbumsView;
	IBOutlet UIView *topTracksView;
	IBOutlet UITextView *bioTextView;
	IBOutlet UICollectionView *albumGridView;
	IBOutlet UITableView *topTracksTableView;
	IBOutlet UITabBar *tabBar;
	BOOL isFinishedLoadingArtistInfo, isFinishedLoadingTrackInfo, isFinishedLoadingTopAlbums, isFinishedLoadingTopTracks;
	BOOL isUsingiPod;
    LFMRecentTracks *recentTracks;
    LFMArtistInfo *artistInfo;
	LFMTrackInfo *trackInfo;
	LFMArtistTopAlbums *topAlbums;
	LFMArtistTopTracks *topTracks;
	MPMusicPlayerController *iPodController;
	NSTimer *playbackTimer;
	ODRefreshControl *refreshControl;
	ODRefreshControl *albumRefreshControl;
	ODRefreshControl *trackRefreshControl;
	SVSegmentedControl *navigation;
	CALayer *bioMask;
	CALayer *tagMaskLeft;
	CALayer *tagMaskMiddle;
	CALayer *tagMaskRight;
	NSThread *iPodReloadingThread;
	NSArray *topAlbumsArray;
	NSArray *topTracksArray;
	UILabel *versionLabel;
	UILabel *copyrightLabel;
	MPMusicPlaybackState lastPlaybackState;
}

@end
