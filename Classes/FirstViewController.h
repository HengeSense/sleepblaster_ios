//
//  FirstViewController.h
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 6/9/09.
//  Copyright The Byte Factory 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstViewController : UIViewController {
	
	IBOutlet UILabel *currentTimeLabel;
	IBOutlet UILabel *currentDateLabel;
	IBOutlet UIWindow *window;
	
//	NSTimer *timer;
//	NSTimer *listenerTimer;
}

@property (nonatomic, retain) UILabel *currentTimeLabel;
@property (nonatomic, retain) UILabel *currentDateLabel;
//@property (nonatomic, retain) NSTimer *timer;


//- (IBAction)setupAlarm:(id)sender;
//- (IBAction)stopAlarm:(id)sender;
//- (IBAction)setAlarmOnValue:(id)sender;
//- (IBAction)showNightView:(id)sender;
- (void)setCurrentDateAndTimeLabels;
//- (void)processVolumeReading:(NSNumber *)volumeLevel;

//- (void)alarmDidStartRinging;


@end
