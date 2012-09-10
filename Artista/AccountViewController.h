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
    
    UITextField *userNameTextField;
}

@property (strong) id delegate;

@end
