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
	else
	{
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstRun"])
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
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstRun"];
	[[NSUserDefaults standardUserDefaults] synchronize];
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
	[[NSUserDefaults standardUserDefaults] synchronize];
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


@end
