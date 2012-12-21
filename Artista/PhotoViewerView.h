//
//  PhotoViewerView.h
//  Artista
//
//  Created by Chloe Stars on 12/20/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NIPhotoScrollView.h"

@interface PhotoViewerView : UIView
{
	IBOutlet NIPhotoScrollView *photoScrollView;
	IBOutlet UILabel *currentPhoto;
	IBOutlet UIButton *doneButton;
	IBOutlet UIButton *shareButton;
}

@property IBOutlet NIPhotoScrollView *photoScrollView;
@property IBOutlet UILabel *currentPhoto;
@property IBOutlet UIButton *doneButton;
@property IBOutlet UIButton *shareButton;

+ (instancetype)viewFromNib;

@end
