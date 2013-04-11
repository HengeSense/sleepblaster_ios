//
//  NightView.m
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 10/7/09.
//  Copyright 2009 The Byte Factory. All rights reserved.
//

#import "NightView.h"


@implementation NightView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetRGBFillColor(context, 0.0,0.0,0.0,1.0);
	CGContextFillRect(context, rect);
}


- (void)dealloc {
    [super dealloc];
}


@end
