//
//  PSCPhotoScrollView.m
//  Artista
//
//  Created by Chloe Stars on 12/20/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import "PSCPhotoScrollView.h"

@implementation PSCPhotoScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (UIImageView*)imageView
{
	for (UIView *view in [self subviews])
	{
		if ([view class]==[UIImageView class])
		{
			return (UIImageView*)view;
		}
	}
	// this should never happen
	return nil;
}

@end
