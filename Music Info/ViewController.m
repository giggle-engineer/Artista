//
//  ViewController.m
//  Music Info
//
//  Created by Chloe Stars on 8/14/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import "ViewController.h"
#import "LastFMArtistInfo.h"
#import "LFMRecentTracks.h"
#import "LFMTrack.h"
#import "AccountViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // ![[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstRun"]
    if (YES) {
        [self performSegueWithIdentifier: @"Account"
                                  sender: nil];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
