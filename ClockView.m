//
//  ClockBackgroundView.m
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 12/28/09.
//  Copyright 2009 The Byte Factory. All rights reserved.
//

#import "ClockView.h"
#import "ShadowedLabel.h"

@implementation ClockView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        subviewsAreInPortraitMode =	NO;
		[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
    return self;
}

- (void)layoutSubviews
{	
	if ((UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) && subviewsAreInPortraitMode) ||
		(UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) && subviewsAreInPortraitMode == NO) ||
		!UIDeviceOrientationIsValidInterfaceOrientation([UIDevice currentDevice].orientation))
	{
		return;
	}
		
	float ratio = [UIScreen mainScreen].bounds.size.height/[UIScreen mainScreen].bounds.size.width;

	// This is simply the number of pixels from the top of the screen to the top of the clock image when it's in portrait,
	// and centered on the screen.
	float yOffset = [UIScreen mainScreen].bounds.size.height/2 - [UIScreen mainScreen].bounds.size.width/ratio/2;
	
	if (UIInterfaceOrientationIsPortrait([UIDevice currentDevice].orientation))
	{
		ratio = 1.0/ratio;
	}
	
	for (int i = 0; i < self.subviews.count; i++)
	{
		UIView *view = [self.subviews objectAtIndex:i];
		CGRect frame = view.frame;
		
/*		if (view == rightSettingsButton)
		{
			if (UIInterfaceOrientationIsPortrait([UIDevice currentDevice].orientation))
			{
				frame.origin.x = [UIScreen mainScreen].bounds.size.width - frame.size.width - 10.0;
				frame.origin.y = [UIScreen mainScreen].bounds.size.height - frame.size.height - 10.0;
				NSLog(@"positioning the button at: %f, %f", frame.origin.x, frame.origin.y);
			} else {
				frame.origin.x = [UIScreen mainScreen].bounds.size.height - frame.size.width - 10.0;
				frame.origin.y = [UIScreen mainScreen].bounds.size.width - frame.size.height - 10.0;
				NSLog(@"positioning the button at: %f, %f", frame.origin.x, frame.origin.y);
			}
			
			
		} else*/ 
		
		if ([view class] != [UIButton class]) {
			
			if (UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation))
			{
				frame.origin.y -= yOffset;
			}
			
			frame.size.width *= ratio;
			frame.size.height *= ratio;
			frame.origin.x *= ratio;
			frame.origin.y *= ratio;
			
			if (UIInterfaceOrientationIsPortrait([UIDevice currentDevice].orientation))
			{
				frame.origin.y += yOffset;
			}
			
			if ([view class] == [ShadowedLabel class])
			{
				UIFont *originalFont = ((UILabel*)view).font;
				UIFont *newFont = [UIFont fontWithName:originalFont.fontName size:originalFont.pointSize*ratio];
				
				((UILabel*)view).font = newFont;
			}
		}
		view.frame = frame;
	}
	
	subviewsAreInPortraitMode = !subviewsAreInPortraitMode;
}



- (void)dealloc {
    [super dealloc];
}


@end
