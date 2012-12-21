//
//  PhotoViewerView.m
//  Artista
//
//  Created by Chloe Stars on 12/20/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import "PhotoViewerView.h"

@implementation PhotoViewerView
@synthesize photoScrollView;
@synthesize currentPhoto;
@synthesize doneButton;
@synthesize shareButton;

+ (instancetype)viewFromNib {
	
	static UINib *nib = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		nib = [UINib nibWithNibName:NSStringFromClass([self class])  bundle:nil];
	});
	
	NSArray *objects = [nib instantiateWithOwner:nil options:nil];
	
	for (PhotoViewerView *view in objects)
		if ([view isKindOfClass:[PhotoViewerView class]])
			return view;
	
	return nil;
	
}

@end
