//
//  AccountViewController.h
//  Music Info
//
//  Created by Chloe Stars on 8/14/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LFMRecentTracks.h"

@protocol AccountViewControllerDelegate <NSObject>
@required
- (void) didReceiveReceiveUsername;
- (void) didFailToReceiveUsername: (NSError *)error;
@end

@interface AccountViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, LFMRecentTracksDelegate> {
    id <AccountViewControllerDelegate> delegate;
    
    IBOutlet UITextField *userNameTextField;
	IBOutlet UIImageView *verifiedImageView;
	IBOutlet UIView *longButtonsView;
	IBOutlet UIView *shortButtonView;
	IBOutlet UIView *connectedView;
	IBOutlet UIView *notConnectedView;
	IBOutlet UILabel *userNameLabel;
	IBOutlet UIButton *closeButton;
}

- (IBAction)closeView:(id)sender;

@property (strong) id delegate;
@property IBOutlet UITextField *userNameTextField;
@property IBOutlet UIImageView *verifiedImageView;
@property IBOutlet UIView *longButtonsView;
@property IBOutlet UIView *shortButtonView;
@property IBOutlet UIView *connectedView;
@property IBOutlet UIView *notConnectedView;
@property IBOutlet UILabel *userNameLabel;
@property IBOutlet UIButton *closeButton;

@end
