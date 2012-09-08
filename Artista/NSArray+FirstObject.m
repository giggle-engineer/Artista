//
//  NSArray+FirstObject.m
//  Artista
//
//  Created by Chloe Stars on 9/7/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import "NSArray+FirstObject.h"

@implementation NSArray (FirstObject)

- (id)firstObject {
	if (self.count!=0) {
		return [self objectAtIndex:0];
	}
	else {
		return nil;
	}
}

@end
