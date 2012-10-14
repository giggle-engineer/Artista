//
//  UITagView.m
//  Artista
//
//  Created by Chloe Stars on 8/21/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import "PSCTagView.h"
#define kPadding 4

@implementation PSCTagView
@synthesize font;
@synthesize textColor;
@synthesize backgroundColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
	// set defaults
	font = [UIFont fontWithName:@"Helvetica Neue" size:17];
	textColor = [UIColor whiteColor];
	backgroundColor = [UIColor blackColor];
	// setup tag array
	tagArray = [NSMutableArray new];
}

- (void)setTags:(NSArray*)tags {
	// check for nil, if found remove all objects and return
	if (tags==nil) {
		// remove old tags from both array and the superview
		[tagArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
		[tagArray removeAllObjects];
		return;
	}
	
	// remove old tags from both array and the superview
	[tagArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[tagArray removeAllObjects];
	// keep x position to add new tags at
	int pushedX = 0;
    for (int i = 0; i < tags.count; i++) {
		CGPoint point;
		// add padding to tags after the first tag
		if (i!=0)
			point.x = pushedX + kPadding;
		else
			point.x = 0;
		point.y = 0;
		
		PSCTag *tag;
		// The array object can be either a string or an actual tag
		if ([[tags objectAtIndex:i] isKindOfClass:[PSCTag class]]) {
			// is container
			tag = [tags objectAtIndex:i];
			// set the point
			CGRect frame = [tag frame];
			tag.frame = CGRectMake(point.x, point.y, frame.size.width, frame.size.height);
		}
		if ([[tags objectAtIndex:i] isKindOfClass:[NSString class]]) {
			// is string
			tag = [[PSCTag alloc] initWithString:[tags objectAtIndex:i] withFont:font withTextColor:textColor withBackgroundColor:backgroundColor withPoint:point];
		}
		
		// add the same padding to the total width only after the first tag
		if (i!=0)
			pushedX += tag.frame.size.width + kPadding;
		else
			pushedX += tag.frame.size.width;
        
		// add the current tag to the view and array
        [self addSubview:tag];
		[tagArray addObject:tag];
    }
	// adjust the content size for the tags
	self.contentSize = CGSizeMake(pushedX, self.frame.size.height);
}

@end
