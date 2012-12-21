//
//  PhotoViewController.h
//  Artista
//
//  Created by Chloe Stars on 12/17/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NIPhotoScrollView.h"

@interface PhotoViewController : UIViewController
{
	IBOutlet NIPhotoScrollView *photoView;
	IBOutlet UILabel *currentPhoto;
}

@property IBOutlet NIPhotoScrollView *photoView;
@property IBOutlet UILabel *currentPhoto;

@end
