//
//  UITagView.m
//  Artista
//
//  Created by Chloe Stars on 8/21/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import "UITagView.h"
#define kPadding 4

@implementation UITagView
@synthesize font, textColor, backgroundColor;

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
		
		// create the tag
		UITag *tag = [[UITag alloc] initWithString:[tags objectAtIndex:i] withFont:font withTextColor:textColor withBackgroundColor:backgroundColor withPoint:point];
		
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
