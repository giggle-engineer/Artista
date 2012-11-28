//
//  AccountViewController.m
//  Music Info
//
//  Created by Chloe Stars on 8/14/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import "AccountViewController.h"
#import "UIImage+H568.h"

@interface AccountViewController ()

@end

@implementation AccountViewController
@synthesize delegate;
@synthesize userNameTextField;

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
	
	// set the background image
	[[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Login"]]];
	
	// if an account is already linked show it
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user"]!=nil) {
		[userNameTextField setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"user"]];
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated {
	// show keyboard for username text field
	[userNameTextField becomeFirstResponder];
}

- (IBAction)closeView:(id)sender
{
	[self verifyUser];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	[textField resignFirstResponder];
	
	[self verifyUser];
	
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

- (void)verifyUser {
	// don't be that jerk who makes the button stay highlighted until the loading is done
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
	dispatch_async(queue,^{
		LFMRecentTracks *recentTracks = [[LFMRecentTracks alloc] init];
		[recentTracks setDelegate:self];
		[recentTracks requestInfo:userNameTextField.text];
	});
}

- (void)saveAndDismiss {
	// save user name and dissmiss
	[[NSUserDefaults standardUserDefaults] setObject:userNameTextField.text forKey:@"user"];
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstRun"];
	[[self delegate] didReceiveReceiveUsername];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveRecentTracks:(NSArray *)tracks {
	// account valid. save and dismiss
	dispatch_async(dispatch_get_main_queue(), ^{
		[self saveAndDismiss];
	});
}

- (void)didFailToReceiveRecentTracks:(NSError *)error {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid username or Last.fm is down." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[alert show];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==0) {
        if (indexPath.row==1) {
            [self verifyUser];
        }
		if (indexPath.row==2) {
			// decided not to link an account
			if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user"]==nil) {
				[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstRun"];
				[[self delegate] didFailToReceiveUsername:nil];
				[self dismissModalViewControllerAnimated:YES];
			}
			// removing existing link to Last.fm
			else {
				[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user"];
				[[self delegate] didFailToReceiveUsername:nil];
				[self dismissModalViewControllerAnimated:YES];
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
