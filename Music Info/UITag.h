//
//  UITag.h
//  Artista
//
//  Created by Chloe Stars on 8/21/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITag : UIView {
	@private
	UIFont *font;
	UIColor *textColor;
	UIColor *backgroundColor;
	NSString *string;
}

- (id)initWithString:(NSString *)string withFont:(UIFont*)font withTextColor:(UIColor*)textColor withBackgroundColor:(UIColor*)_backgroundColor withPoint:(CGPoint)point;

@end
