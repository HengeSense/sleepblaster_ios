//
//  ShadowedLabel.m
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 11/29/09.
//  Copyright 2009 The Byte Factory. All rights reserved.
//

#import "ShadowedLabel.h"


@implementation ShadowedLabel

@synthesize shadowBlur;
@synthesize shadowColor;

- (void) drawTextInRect:(CGRect)rect {

	if (!shadowBlur) {
		shadowBlur = 5.0;
	}
		
    CGSize myShadowOffset = CGSizeMake(0, 0);
		
	if (!self.shadowColor)
	{
		self.shadowColor = self.textColor;
	}
	
	const float* myColorValues = CGColorGetComponents(shadowColor.CGColor);
	
    CGContextRef myContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(myContext);
	
    CGColorSpaceRef myColorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef myColor = CGColorCreate(myColorSpace, myColorValues);
    CGContextSetShadowWithColor (myContext, myShadowOffset, shadowBlur, myColor);
	
	[super drawTextInRect:rect];

    CGColorRelease(myColor);
    CGColorSpaceRelease(myColorSpace); 
	
    CGContextRestoreGState(myContext);
}

- (void)setShadowBlur:(float)blur
{
	shadowBlur = blur;
	[self setNeedsDisplay];
}

- (void)dealloc {
    [super dealloc];
}


@end
