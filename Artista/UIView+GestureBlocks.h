//
//  UIView+GestureBlocks.h
//  Artista
//
//  Created by Chloe Stars on 12/20/12.
//  Copyright (c) 2012 Chloe Stars. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface UIView (GestureBlocks)

@property (readwrite, nonatomic, copy) void (^tapHandler)(UIGestureRecognizer *sender);

- (void)initialiseTapHandler:(void (^) (UIGestureRecognizer *sender))block forTaps:(int)numberOfTaps;
- (IBAction)handleTap:(UIGestureRecognizer *)sender;

@end