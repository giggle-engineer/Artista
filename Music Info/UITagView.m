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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setTags:(NSArray*)tags {
	int pushedX;
    for (int i = 0; i < tags.count; i++) {
		CGPoint point;
		// add padding to tags after the first tag
		if (i!=0) {
			point.x = pushedX + kPadding;
		}
		else {
			point.x = 0;
		}
		point.y = 0;
		
		UITag *tag = [[UITag alloc] initWithString:[tags objectAtIndex:i] withFont:[UIFont fontWithName:@"Helvetica" size:17] withTextColor:[UIColor whiteColor] withBackgroundColor:[UIColor blackColor] withPoint:point];
		[tag setAlpha:0.5];
		
		pushedX += tag.frame.size.width + kPadding;
        
        [self addSubview:tag];
    }
	
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
