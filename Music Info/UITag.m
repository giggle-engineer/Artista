//
//  UITag.m
//  Artista
//
//  Created by Chloe Stars on 8/21/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import "UITag.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>

@implementation UITag

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithString:(NSString *)_string withFont:(UIFont*)_font withTextColor:(UIColor*)_textColor withBackgroundColor:(UIColor*)_backgroundColor withPoint:(CGPoint)point
{
	// set up instance variable
	string = _string;
	font = _font;
	textColor = _textColor;
	backgroundColor = _backgroundColor;
	
	CGSize size = [string sizeWithFont:_font];
	self = [super initWithFrame:CGRectMake(point.x, point.y, size.width, size.height)];
	if (self) {
		// Initialization code
		self.layer.cornerRadius = 4.0;
		self.layer.masksToBounds = YES;
	}
	return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	// get the contect
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// now draw the rounded rectangle
	CGContextSetStrokeColorWithColor(context, [backgroundColor CGColor]);
	CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
	
	// finally draw the text
	CATextLayer *textLayer = [CATextLayer layer];
	textLayer.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
	textLayer.string = string;
	textLayer.font = CTFontCreateWithName((__bridge CFStringRef)font.fontName, 0.0, NULL);
	textLayer.fontSize = font.pointSize;
	textLayer.foregroundColor = textColor.CGColor;
	textLayer.alignmentMode = kCAAlignmentCenter;
	[textLayer drawInContext:context];
}

@end
