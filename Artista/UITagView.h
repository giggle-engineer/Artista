//
//  UITagView.h
//  Artista
//
//  Created by Chloe Stars on 8/21/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITag.h"

@interface UITagView : UIScrollView {
	@private
	NSMutableArray *tagArray;
}

- (void)setTags:(NSArray*)tags;

@property UIFont *font;
@property UIColor *textColor;
@property UIColor *backgroundColor;

@end
