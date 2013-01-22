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
#import "PhotoViewController.h"
#import "LFM.h"
#import "PSCTagView.h"

@interface ViewController : UIViewController <AccountViewControllerDelegate, LFMRecentTracksDelegate, LFMArtistInfoDelegate, LFMArtistTopAlbumsDelegate, LFMArtistTopTracksDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, UITabBarDelegate> {
    IBOutlet UILabel *artist;
    IBOutlet UIImageView *artistImageView;
	IBOutlet PSCTagView *tagView;
	IBOutlet UITextView *bioTextView;
	IBOutlet UICollectionView *albumGridView;
	IBOutlet UITableView *topTracksTableView;
	IBOutlet UICollectionView *photoGridView;
	IBOutlet UITabBar *tabBar;
	IBOutlet UIImageView *artistGradientView;
	IBOutlet UIButton *refreshButton;
	BOOL isFinishedLoadingArtistInfo, isFinishedLoadingTopAlbums, isFinishedLoadingTopTracks, isFinishedLoadingArtistImages;
	BOOL isUsingiPod;
	BOOL isInPhotoviewer;
    LFMRecentTracks *recentTracks;
    LFMArtistInfo *artistInfo;
	LFMArtistImages *artistImages;
	LFMArtistTopAlbums *topAlbums;
	LFMArtistTopTracks *topTracks;
	MPMusicPlayerController *iPodController;
	CALayer *bioMask;
	CALayer *albumsMask;
	CALayer *tracksMask;
	CALayer *photosMask;
	CALayer *tagMaskLeft;
	CALayer *tagMaskMiddle;
	CALayer *tagMaskRight;
	NSThread *iPodReloadingThread;
	NSArray *topAlbumsArray;
	NSArray *topTracksArray;
	UILabel *versionLabel;
	UILabel *copyrightLabel;
	MPMusicPlaybackState lastPlaybackState;
	UIButton *pagingButton;
	NSString *previousArtistName;
	NSString *previousArtistMusicBrainzID;
	UIImageView *errorImageView;
	UIImageView *emptyBioImageView;
	UIImageView *emptyAlbumsImageView;
	UIImageView *emptyPhotosImageView;
}

@end
