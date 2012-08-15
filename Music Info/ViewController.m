//
//  ViewController.m
//  Music Info
//
//  Created by Chloe Stars on 8/14/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "LastFMArtistInfo.h"
#import "LFMRecentTracks.h"
#import "LFMTrack.h"
#import "UIImage+DSP.h"
#import "NSString+HTML.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    /*if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstRun"]) {
        [self load];
    }*/
    artist.layer.shadowColor = [[UIColor whiteColor] CGColor];
    artist.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    artist.layer.shadowOpacity = 1.0f;
    artist.layer.shadowRadius = 0.5f;
    yearsActive.layer.shadowColor = [[UIColor whiteColor] CGColor];
    yearsActive.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    yearsActive.layer.shadowOpacity = 1.0f;
    yearsActive.layer.shadowRadius = 0.5f;
    bioTextView.layer.shadowColor = [[UIColor blackColor] CGColor];
    bioTextView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    bioTextView.layer.shadowOpacity = 1.0f;
    bioTextView.layer.shadowRadius = 0.5f;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated {
    // load Last.fm account login view. only display this on first run
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstRun"]) {
        [self performSegueWithIdentifier: @"Account"
                                  sender: nil];
    }
    else {
        [self load];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Account"]) {
        AccountViewController *accountViewController = segue.destinationViewController;
        [accountViewController setDelegate:self];
    }
}

- (void)load {
    if (recentTracks==nil) {
        recentTracks = [[LFMRecentTracks alloc] init];
        [recentTracks setDelegate:self];
    }
    [recentTracks requestInfo:[[NSUserDefaults standardUserDefaults] stringForKey:@"user"]];
}

- (IBAction)reloadRecentTracks:(id)sender {
    [self load];
}

#pragma mark - LFMRecentTracks Delegate

- (void)didReceiveRecentTracks:(LFMTrack *)track {
    [artist setText:[track artist]];
    if (artistInfo==nil) {
        artistInfo = [[LastFMArtistInfo alloc] init];
        [artistInfo setDelegate:self];
    }
    [artistInfo requestInfoWithMusicBrainzID:[track musicBrainzID]];
}

- (void)didFailToReceiveRecentTracks:(NSError *)error {
    NSLog(@"Failed to receive track with error:%@", [error description]);
}

#pragma mark - LastFMArtistInfo Delegate

- (void)didReceiveArtistDetails:(NSString *)artistDetails withImage:(UIImage *)artistImage {
    UIImage *blurredImage = [artistImage imageByApplyingGaussianBlur5x5];
    [bioTextView setText:[artistDetails stringByConvertingHTMLToPlainText]];
    [artistImageView setImage:blurredImage];
}

#pragma mark  - Account View Controller Delegate

- (void)didReceiveReceiveUsername {
    [self load];
}

- (void)didFailToReceiveUsername:(NSError *)error {
    NSLog(@"Failed to receive username with error:%@", [error description]);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
