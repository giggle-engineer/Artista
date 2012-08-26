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
		self.opaque = NO;
	}
	return self;
}

// taken from  http://www.cocoanetics.com/2010/02/drawing-rounded-rectangles/
- (CGPathRef) newPathForRoundedRect:(CGRect)rect radius:(CGFloat)radius
{
	CGMutablePathRef retPath = CGPathCreateMutable();
	
	CGRect innerRect = CGRectInset(rect, radius, radius);
	
	CGFloat inside_right = innerRect.origin.x + innerRect.size.width;
	CGFloat outside_right = rect.origin.x + rect.size.width;
	CGFloat inside_bottom = innerRect.origin.y + innerRect.size.height;
	CGFloat outside_bottom = rect.origin.y + rect.size.height;
	
	CGFloat inside_top = innerRect.origin.y;
	CGFloat outside_top = rect.origin.y;
	CGFloat outside_left = rect.origin.x;
	
	CGPathMoveToPoint(retPath, NULL, innerRect.origin.x, outside_top);
	
	CGPathAddLineToPoint(retPath, NULL, inside_right, outside_top);
	CGPathAddArcToPoint(retPath, NULL, outside_right, outside_top, outside_right, inside_top, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_right, inside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_right, outside_bottom, inside_right, outside_bottom, radius);
	
	CGPathAddLineToPoint(retPath, NULL, innerRect.origin.x, outside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_bottom, outside_left, inside_bottom, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_left, inside_top);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_top, innerRect.origin.x, outside_top, radius);
	
	CGPathCloseSubpath(retPath);
	
	return retPath;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	// get the contect
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// now draw the rounded rectangle
	CGPathRef roundedRectPath = [self newPathForRoundedRect:self.bounds radius:4];
	[backgroundColor set];
	CGContextAddPath(context, roundedRectPath);
	CGContextFillPath(context);
	CGPathRelease(roundedRectPath);
	
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
