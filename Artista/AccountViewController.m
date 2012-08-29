//
//  AccountViewController.m
//  Music Info
//
//  Created by Chloe Stars on 8/14/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import "AccountViewController.h"

@interface AccountViewController ()

@end

@implementation AccountViewController

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
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)saveAndDismiss {
	// save user name and dissmiss
	[[NSUserDefaults standardUserDefaults] setObject:userNameTextField.text forKey:@"user"];
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstRun"];
	[[self delegate] didReceiveReceiveUsername];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	[textField resignFirstResponder];
	
	[self saveAndDismiss];
	
	return YES;
	
}

#pragma mark - Data Source Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
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
            [userNameTextField setPlaceholder:@"User Name"];
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
			cell.textLabel.text = @"Skip";
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

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==0) {
        if (indexPath.row==1) {
            [self saveAndDismiss];
        }
		if (indexPath.row==2) {
			[self dismissModalViewControllerAnimated:YES];
		}
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
        case 0:
            return @"Last.fm Account";
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
