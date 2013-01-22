//
//  AccountViewController.m
//  Music Info
//
//  Created by Chloe Stars on 8/14/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import "AccountViewController.h"
#import "UIImage+H568.h"
#import "NSTimer+Blocks.h"
#import "LFMMobileAuth.h"
#import "FDKeychain.h"

@interface AccountViewController ()

@end

@implementation AccountViewController
@synthesize delegate;
@synthesize userNameTextField;
@synthesize passwordTextField;
@synthesize verifiedImageView;
@synthesize longButtonsView;
@synthesize shortButtonView;
@synthesize connectedView;
@synthesize notConnectedView;
@synthesize userNameLabel;
@synthesize closeButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	if  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) &&
		 ([UIScreen mainScreen].bounds.size.height == 480.0f))
	{
		[longButtonsView setHidden:YES];
		[shortButtonView setHidden:NO];
	}
	
	// set the background image
	[[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Login"]]];
	
	// if an account is already linked show it
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user"]!=nil) {
		// show appropriate UI stuff on the screen
		[shortButtonView setHidden:YES];
		[longButtonsView setHidden:YES];
		[notConnectedView setHidden:YES];
		[connectedView setHidden:NO];
		// setup the attributed label
		[self setAttributedUserName:[[NSUserDefaults standardUserDefaults] objectForKey:@"user"]];
		[closeButton setHidden:NO];
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated {
	// show keyboard for username text field if not connected
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user"]==nil) {
		[userNameTextField becomeFirstResponder];
	}
}

#pragma mark -
#pragma mark Button Actions

- (IBAction)skipOrUnlink:(id)sender
{
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user"]!=nil)
	{
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user"];
		// delete the session key and api signature from the iOS keychain
		[FDKeychain deleteItemForKey: @"sessionKey"
						  forService: @"Last.fm"];
		[FDKeychain deleteItemForKey: @"apiSignature"
						  forService: @"Last.fm"];
		[notConnectedView setHidden:NO];
		// show connected view and unhide appropriate button view
		[connectedView setHidden:YES];
		if  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) &&
			 ([UIScreen mainScreen].bounds.size.height == 480.0f))
		{
			[shortButtonView setHidden:NO];
		}
		else
		{
			[longButtonsView setHidden:NO];
		}
	}
	else
	{
		[self dismissViewControllerAnimated:YES completion:^{}];
	}
}

- (IBAction)verifyUser:(id)sender
{	
	// UIKit isn't threading safe, save them in memory for the dispatch
	NSString *password = passwordTextField.text;
	NSString *userName = userNameTextField.text;
	
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
	dispatch_async(queue,^{
		LFMMobileAuth *mobileAuth = [[LFMMobileAuth alloc] init];
		NSString *apiSignature = [mobileAuth createSignatureWithPassword:password username:userName];
		NSString *sessionKey = [mobileAuth getSesssionKeyWithUsername:userName password:password signature:apiSignature];
		
		// if authenticated then save the details
		if (![sessionKey isEqualToString:@""])
		{
			// save session key and signature securely and safely to the iOS keychain
			[FDKeychain saveItem: sessionKey
						  forKey: @"sessionKey"
					  forService: @"Last.fm"];
			[FDKeychain saveItem: apiSignature
						  forKey: @"apiSignature"
					  forService: @"Last.fm"];
			dispatch_async(dispatch_get_main_queue(), ^{
				[self saveAndDismiss];
			});
		}
		else
		{
			dispatch_async(dispatch_get_main_queue(), ^{
				[verifiedImageView setImage:[UIImage imageNamed:@"warning.png"]];
			});
		}
	});
}

- (IBAction)closeView:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)setAttributedUserName:(NSString*)userName
{
	NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Connected as " attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
	[attributedString appendAttributedString:
	 [[NSAttributedString alloc] initWithString:
	  userName attributes:@{NSForegroundColorAttributeName:[UIColor darkGrayColor]}]];
	[userNameLabel setAttributedText:attributedString];
}

- (void)saveAndDismiss {
	// save user name and dissmiss
	[userNameTextField resignFirstResponder];
	[[NSUserDefaults standardUserDefaults] setObject:userNameTextField.text forKey:@"user"];
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstRun"];
	[[self delegate] didReceiveReceiveUsername];
	
	// set username in the connected view and hide button views
	[self setAttributedUserName:[[NSUserDefaults standardUserDefaults] objectForKey:@"user"]];
	[notConnectedView setHidden:YES];
	[shortButtonView setHidden:YES];
	[longButtonsView setHidden:YES];
	[connectedView setHidden:NO];
	
	// wait some time so that the user notices the link with Last.fm was successfull
	[NSTimer scheduledTimerWithTimeInterval:2.0 block:^(NSTimer *timer) {
		[self dismissViewControllerAnimated:YES completion:^{}];
	} repeats:NO];
}

- (void)didReceiveRecentTracks:(NSArray *)tracks {
	// account valid. save and dismiss
	dispatch_async(dispatch_get_main_queue(), ^{
		[self saveAndDismiss];
	});
}

- (void)didFailToReceiveRecentTracks:(NSError *)error {
	dispatch_async(dispatch_get_main_queue(), ^{
		[verifiedImageView setImage:[UIImage imageNamed:@"warning.png"]];
	});
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	[textField resignFirstResponder];
	
	[self verifyUser:nil];
	
	return YES;
	
}

#pragma mark - Data Source Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 3;
    }
    else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        if (indexPath.row==0) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
            userNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(19, 12, tableView.bounds.size.width-80, 30)];
			[userNameTextField setDelegate:self];
            [userNameTextField setAdjustsFontSizeToFitWidth:YES];
            [userNameTextField setReturnKeyType:UIReturnKeyDone];
            [userNameTextField setKeyboardType:UIKeyboardTypeURL];
            [userNameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
            [userNameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
            [userNameTextField setPlaceholder:@"Username"];
			// if an account is already linked show it
			if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user"]!=nil) {
				[userNameTextField setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"user"]];
			}
            [cell addSubview:userNameTextField];
            return cell;
        }
        if (indexPath.row==1) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
            cell.textLabel.text = @"Done";
            return cell;
        }
		if (indexPath.row==2) {
			UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
			// if no username is set show the skip button
			if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user"]==nil) {
				cell.textLabel.text = @"Skip";
			}
			// other wise the button will unlink a currently linked account
			else {
				cell.textLabel.text = @"Unlink Account";
			}
			return cell;
		}
    }
    // shuts up the warning about reaching end of void function
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.section==1) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==0) {
        if (indexPath.row==1) {
            [self verifyUser:nil];
        }
		if (indexPath.row==2) {
			// decided not to link an account
			if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user"]==nil) {
				[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstRun"];
				[[self delegate] didFailToReceiveUsername:nil];
				[self dismissViewControllerAnimated:YES completion:^{}];
			}
			// removing existing link to Last.fm
			else {
				[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user"];
				[[self delegate] didFailToReceiveUsername:nil];
				[self dismissViewControllerAnimated:YES completion:^{}];
			}
		}
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
        case 0:
            return @"Last.fm Account";
            break;
		case 1:
			return @"Linking with Last.fm allows you to use Artista with the currently scrobbled track.";
			break;
        default:
            return @"";
            break;
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    // disable editing of the cells. can no longer swipe to delete
    if (indexPath.section==1) {
        return UITableViewCellEditingStyleDelete;
    }
    else {
        return UITableViewCellEditingStyleNone;
    }
}

@end
