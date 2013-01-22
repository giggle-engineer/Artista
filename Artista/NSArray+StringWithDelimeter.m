//
//  NSArray+StringWithDelimeter.m
//  Artista
//
//  Created by Chloe Stars on 8/21/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import "NSArray+StringWithDelimeter.h"

@implementation NSArray (StringWithDelimeter)

- (NSString*)stringWithDelimeter:(NSString*)delimeter {
	NSMutableString *stringWithDelimeter = [NSMutableString new];
	//NSLog(@"array count:%u", [self count]);
	if ([self count]!=0) {
		for (int i = 0; i<[self count]; i++) {
			if (i!=[self count]) {
				[stringWithDelimeter appendString:[NSString stringWithFormat:@"%@%@", [self objectAtIndex:i], delimeter]];
			}
			else {
				[stringWithDelimeter appendString:[self objectAtIndex:i]];
			}
		}
		return stringWithDelimeter;
	}
	else {
		return [NSString new];
	}
}

@end
