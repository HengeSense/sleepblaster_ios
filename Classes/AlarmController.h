//
//  AlarmController.h
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 9/24/09.
//  Copyright 2009 The Byte Factory. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AlarmController : NSObject <AVAudioPlayerDelegate> {
	NSTimer *timer;
	NSTimer *listenerTimer;
	AVAudioPlayer *explosionSound;
	AVAudioPlayer *alarmSound;

	UIAlertView *alertView;
}

+ (AlarmController *)sharedAlarmController;

- (void)setupAlarm:(id)sender;
- (void)setOffAlarm:(NSTimer *)theTimer;
- (IBAction)stopAlarm:(id)sender;
- (IBAction)snoozeAlarm:(id)sender;
- (NSDate *)dateAlarmWillGoOff;
- (BOOL)isHeadsetPluggedIn;

@property (nonatomic, retain) NSTimer *timer;
//@property (nonatomic, assign) id alarmInterfaceDelegate;
@property (nonatomic, retain) AVAudioPlayer *explosionSound;
@property (nonatomic, retain) AVAudioPlayer *alarmSound;


@end
