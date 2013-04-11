//
//  ShadowedLabel.h
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 11/29/09.
//  Copyright 2009 The Byte Factory. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ShadowedLabel : UILabel {
	float shadowBlur;
	UIColor *shadowColor;
}

@property float shadowBlur;
@property (nonatomic, retain) UIColor *shadowColor;

@end
