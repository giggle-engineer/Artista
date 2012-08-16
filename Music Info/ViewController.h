//
//  ViewController.h
//  Music Info
//
//  Created by Chloe Stars on 8/14/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccountViewController.h"
#import "LFMRecentTracks.h"
#import "LastFMArtistInfo.h"

@interface ViewController : UIViewController <AccountViewControllerDelegate, LFMRecentTracksDelegate, LastFMArtistInfoDelegate, UITextViewDelegate> {
    IBOutlet UILabel *artist;
    IBOutlet UILabel *yearsActive;
    IBOutlet UITextView *bioTextView;
    IBOutlet UIImageView *artistImageView;
    LFMRecentTracks *recentTracks;
    LastFMArtistInfo *artistInfo;
}

@end
