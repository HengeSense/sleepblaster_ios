//
//  ClockViewController.h
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 11/24/09.
//  Copyright 2009 The Byte Factory. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShadowedLabel.h"

@interface ClockViewController : UIViewController {
	
	IBOutlet UIView *portraitClockBackgroundView;
	IBOutlet ShadowedLabel *portraitHourLabel1;
	IBOutlet ShadowedLabel *portraitHourLabel2;
	IBOutlet ShadowedLabel *portraitMinuteLabel1;
	IBOutlet ShadowedLabel *portraitMinuteLabel2;
	IBOutlet ShadowedLabel *portraitSecondLabel1;
	IBOutlet ShadowedLabel *portraitSecondLabel2;
	IBOutlet ShadowedLabel *portraitSunLabel;
	IBOutlet ShadowedLabel *portraitMonLabel;
	IBOutlet ShadowedLabel *portraitTueLabel;
	IBOutlet ShadowedLabel *portraitWedLabel;
	IBOutlet ShadowedLabel *portraitThuLabel;
	IBOutlet ShadowedLabel *portraitFriLabel;
	IBOutlet ShadowedLabel *portraitSatLabel;
	IBOutlet ShadowedLabel *portraitAmLabel;
	IBOutlet ShadowedLabel *portraitPmLabel;
	IBOutlet ShadowedLabel *portraitColonLabel;
	IBOutlet UIImageView *portraitAlarmBell;

	IBOutlet UIView *landscapeClockBackgroundView;	
	IBOutlet ShadowedLabel *hourLabel1;
	IBOutlet ShadowedLabel *hourLabel2;
	IBOutlet ShadowedLabel *minuteLabel1;
	IBOutlet ShadowedLabel *minuteLabel2;
	IBOutlet ShadowedLabel *secondLabel1;
	IBOutlet ShadowedLabel *secondLabel2;
	IBOutlet ShadowedLabel *sunLabel;
	IBOutlet ShadowedLabel *monLabel;
	IBOutlet ShadowedLabel *tueLabel;
	IBOutlet ShadowedLabel *wedLabel;
	IBOutlet ShadowedLabel *thuLabel;
	IBOutlet ShadowedLabel *friLabel;
	IBOutlet ShadowedLabel *satLabel;
	IBOutlet ShadowedLabel *amLabel;
	IBOutlet ShadowedLabel *pmLabel;
	IBOutlet ShadowedLabel *colonLabel;
	IBOutlet UIImageView *alarmBell;
	IBOutlet UIButton *rightSettingsButton;
	
	IBOutlet UIImageView *backgroundImageView;
	
	IBOutlet UIWindow *window;
	
	UIPopoverController *alarmPopoverController;
	UIPopoverController *sleepTimerPopoverController;
	
	NSTimer *timer;
}

//- (void)layoutForPortraitMode;
//- (void)layoutForLandscapeMode;


- (void)setFontsForLabels;
- (void)positionSettingsButtons;
- (void)setCurrentDateAndTimeLabels;
- (IBAction)infoButtonTapped:(id)sender;
- (IBAction)sleepTimerButtonTapped:(id)sender;

@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) UIPopoverController *alarmPopoverController;
@property (nonatomic, retain) UIPopoverController *sleepTimerPopoverController;
@property (nonatomic, retain) UIButton *rightSettingsButton;


@end
