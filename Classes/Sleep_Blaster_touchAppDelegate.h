//
//  Sleep_Blaster_touchAppDelegate.h
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 6/9/09.
//  Copyright The Byte Factory 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "DeepSleepPreventer.h"
#import "ClockViewController.h"
#import "AlarmRingingViewController.h"
#import "MapViewController.h"
#import "AlarmSettingsViewController.h"
#import "SleepTimerSettingsViewController.h"

@interface Sleep_Blaster_touchAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
	UIWindow *window;
	UITabBarController *tabBarController;
	IBOutlet ClockViewController *clockViewController;
	AlarmRingingViewController *alarmRingingViewController;
	MapViewController *mapViewController;
	UINavigationController *alarmSettingsNavigationController;
	UINavigationController *sleepTimerSettingsNavigationController;
	
	UIView *previousView;
	
	MPMediaItemCollection *alarmSongsCollection;
	MPMediaItemCollection *sleepTimerSongsCollection;
	BOOL hasLoadedAlarmSongsCollection;
	BOOL hasLoadedSleepTimerSongsCollection;
	BOOL backgroundSupported;
	
	BOOL bypassAlarm;
}

- (void)showAlarmRingingView;
- (void)hideAlarmRingingView;
- (void)flipToSettings;
- (IBAction)flipToClockView:(id)sender;
- (void)scheduleAlarmNotificationsIfNeeded;

- (void)loadSongsAsynchronously:(id)sender;

@property (nonatomic, retain) ClockViewController *clockViewController;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) MapViewController *mapViewController;
@property (nonatomic, retain) MPMediaItemCollection *alarmSongsCollection;
@property (nonatomic, retain) MPMediaItemCollection *sleepTimerSongsCollection;
@property (nonatomic) BOOL hasLoadedAlarmSongsCollection;
@property (nonatomic) BOOL hasLoadedSleepTimerSongsCollection;
@property (nonatomic) BOOL backgroundSupported;
@property (nonatomic, retain) UIView *previousView;
@property (nonatomic, retain) UINavigationController *alarmSettingsNavigationController;
@property (nonatomic, retain) UINavigationController *sleepTimerSettingsNavigationController;
@property (nonatomic) BOOL bypassAlarm;
@end
