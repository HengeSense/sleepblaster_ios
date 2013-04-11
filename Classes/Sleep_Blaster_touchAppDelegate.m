//
//  Sleep_Blaster_touchAppDelegate.m
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 6/9/09.
//  Copyright The Byte Factory 2009. All rights reserved.
//

#import "Sleep_Blaster_touchAppDelegate.h"
#import "AlarmRingingViewController.h"
#import "Constants.h"
#import "ClockViewController.h"
#include <AudioToolbox/AudioToolbox.h>
#import "SleepTimerController.h"
#import "AlarmController.h"

@implementation Sleep_Blaster_touchAppDelegate

@synthesize window;
@synthesize clockViewController;
@synthesize tabBarController;
@synthesize mapViewController;
@synthesize alarmSongsCollection;
@synthesize sleepTimerSongsCollection;
@synthesize hasLoadedAlarmSongsCollection;
@synthesize hasLoadedSleepTimerSongsCollection;
@synthesize backgroundSupported;
@synthesize previousView;
@synthesize alarmSettingsNavigationController;
@synthesize sleepTimerSettingsNavigationController;
@synthesize bypassAlarm;

int numberOfNotifications = 0;

+ (void)initialize 
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
								 [NSDate date], kAlarmDate, 
								 [NSNumber numberWithBool:NO], kEnableVoiceControls, 
								 [NSNumber numberWithBool:NO], kAlarmOn, 
								 [NSNumber numberWithBool:NO], kAlarmMusicShuffle,
								 [NSNumber numberWithBool:NO], kSleepTimerMusicShuffle,
								 [NSNumber numberWithBool:NO], kEnableDynamiteMode, 
								 [NSNumber numberWithInt:2], kAlarmPlayInterval, 
								 [NSNumber numberWithInt:2], kAlarmPauseInterval, 
								 [NSNumber numberWithInt:1], kVoiceFunction,  
								 [NSNumber numberWithInt:1], kSleepTimerFunction,
								 [NSNumber numberWithInt:3600], kSleepTimerSeconds,
								 [NSNumber numberWithInt:0], kAlarmMode, 
								 [NSNumber numberWithBool:NO], kHasShownDrawingMessage,
								 [NSNumber numberWithBool:NO], kHasShownChargingMessage,
								 [NSNumber numberWithBool:NO], kHasShownBrightnessMessage,
								 [NSNumber numberWithBool:NO], kHasShownBackgroundMessage,
								 [NSNumber numberWithInt:10], kSnoozeMinutes,
								 [[NSTimeZone defaultTimeZone] name], kOldTimeZone, NULL];
	
	[defaults registerDefaults:appDefaults];		
	
}
- (id)init
{
    if (self = [super init] ) {
		
		hasLoadedAlarmSongsCollection = NO;
		hasLoadedSleepTimerSongsCollection = NO;
		
		UIDevice* device = [UIDevice currentDevice];
		backgroundSupported = NO;
		if ([device respondsToSelector:@selector(isMultitaskingSupported)]) {
			backgroundSupported = device.multitaskingSupported;
		}
		
    }
	return self;
}
/*
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
	if ([[notification.userInfo objectForKey:@"PresentedImmediately"] boolValue] == YES)
	{
		NSLog(@"presented immediately!");

	} else {
		NSLog(@"not presented immediately");
		self.bypassAlarm = YES;

	}
	NSLog(@"did receive local notification");
}
*/
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	if (self.backgroundSupported)
	{
		if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey])
		{
			NSLog(@"local notification!");
			// One of the notifications has gone off...
			self.bypassAlarm = YES;
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kAlarmOn];
		}
//		[[UIApplication sharedApplication] cancelAllLocalNotifications];
//		NSLog(@"scheduled notifications now: %d", [[UIApplication sharedApplication] scheduledLocalNotifications].count);
//		NSLog(@"notifications before: %d", numberOfNotifications);
					
	}
	
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
	[UIApplication sharedApplication].statusBarHidden = YES;

	// We have to create the map view controller at the very beginning, because this is what controls the location updates and stuff.
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		mapViewController = [[MapViewController alloc] initWithNibName:@"MapView-iPad" bundle:nil];					
	} else {
		mapViewController = [[MapViewController alloc] initWithNibName:@"MapView" bundle:nil];			
	}
	//	// Force it to load the mapViewController immediately.
	//	mapViewController.view;

	[window addSubview:clockViewController.view];
	
	[NSThread detachNewThreadSelector:@selector(loadSongsAsynchronously:) toTarget:self withObject:nil];

	
	return NO;
}

- (void)flipToSettings
{
	[UIApplication sharedApplication].statusBarHidden = NO;
		
//	self.tabBarController = [[UITabBarController alloc] init];
//	
//	NSArray* controllers = [NSArray arrayWithObjects:self.alarmSettingsNavigationController, self.sleepTimerSettingsNavigationController, nil];
//	tabBarController.viewControllers = controllers;

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1.0];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:window cache:YES];

	[window addSubview:self.tabBarController.view];			//	retains tabBarController
	[clockViewController.view removeFromSuperview];

	[UIView commitAnimations];
}

- (IBAction)flipToClockView:(id)sender
{
	[UIApplication sharedApplication].statusBarHidden = YES;

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1.0];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:window cache:YES];
	
	[window addSubview:clockViewController.view];
	[self.tabBarController.view removeFromSuperview];		// releases tabBarController
	
	[UIView commitAnimations];
}

- (void)showAlarmRingingView
{
	[UIApplication sharedApplication].statusBarHidden = YES;

	alarmRingingViewController = [[[AlarmRingingViewController alloc] initWithNibName:@"AlarmRingingView" bundle:nil] autorelease];

	self.previousView = [window.subviews objectAtIndex:0];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1.0];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:window cache:YES];
	
	[self.previousView removeFromSuperview];
	[window addSubview:alarmRingingViewController.view];
	
	[UIView commitAnimations];
}

- (void)hideAlarmRingingView
{
	if (self.previousView == tabBarController.view) {
		[UIApplication sharedApplication].statusBarHidden = NO;
	}
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1.0];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:window cache:NO];
	
	[alarmRingingViewController.view removeFromSuperview];
	[window addSubview:self.previousView];

	[UIView commitAnimations];
}

- (void)loadSongsAsynchronously:(id)sender
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kAlarmSongsCollection]) {
		self.alarmSongsCollection = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmSongsCollection]];
	}
/*	if (self.alarmSongsCollection.count == 0)		// if there are no songs selected....
	{
		MPMediaQuery *everything = [[MPMediaQuery alloc] init];
		if (everything.items.count)		// if there are songs in the user's iPod library, add them all.
		{
			self.alarmSongsCollection = [MPMediaItemCollection collectionWithItems:everything.items];
			//[self.alarmSongsCollection retain];
		}
		[everything release];
	}
*/	
	hasLoadedAlarmSongsCollection = YES;
	[[self.alarmSettingsNavigationController.viewControllers objectAtIndex:0] setLabelInMusicCell];

	if ([[NSUserDefaults standardUserDefaults] objectForKey:kSleepTimerSongsCollection]) {
		self.sleepTimerSongsCollection = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:kSleepTimerSongsCollection]];
	}
	hasLoadedSleepTimerSongsCollection = YES;
	[[self.sleepTimerSettingsNavigationController.viewControllers objectAtIndex:0] setLabelInMusicCell];

	[pool release];
}

 - (void)applicationWillTerminate:(UIApplication *)application
{
	[self scheduleAlarmNotificationsIfNeeded];
	
/*//	NSData *alarmSongsData = [NSKeyedArchiver archivedDataWithRootObject:self.alarmSongsCollection];
	NSData *sleepTimerSongsData = [NSKeyedArchiver archivedDataWithRootObject:self.sleepTimerSongsCollection];
	
//	[[NSUserDefaults standardUserDefaults] setObject:alarmSongsData forKey:kAlarmSongsCollection];
	[[NSUserDefaults standardUserDefaults] setObject:sleepTimerSongsData forKey:kSleepTimerSongsCollection];
	NSLog(@"about to save the data!");
	NSLog(@"terminating");
 */
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
//	[[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	NSLog(@"enter background");
	[self scheduleAlarmNotificationsIfNeeded];
	if (![SleepTimerController sharedSleepTimerController].sleepTimerIsOn)
	{
		[[DeepSleepPreventer sharedDeepSleepPreventer] stopPreventSleep];
	}
}

- (void)scheduleAlarmNotificationsIfNeeded
{
	if (self.backgroundSupported)
	{
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmOn] boolValue] && ([[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmMode] boolValue] == 0)) 
		{
			UILocalNotification *notification = [[UILocalNotification alloc] init];
			notification.fireDate = [[AlarmController sharedAlarmController] dateAlarmWillGoOff];
			notification.soundName = @"beep.wav";
			notification.alertAction = @"Turn off";
			notification.alertBody = @"Hey, it's time to wake up!";
			[[UIApplication sharedApplication] scheduleLocalNotification:notification];
			
		}
		numberOfNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications].count;
//		NSLog(@"number of notifications now... %d", numberOfNotifications);
	}
}

-(void) applicationWillResignActive:(UIApplication *)application {
//	NSLog(@"resign active");
	if (self.backgroundSupported)
	{
		numberOfNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications].count;
	}
	// If the user puts the iPhone to sleep while the alarm is set for "time" mode, just don't let it go into deep sleep.
	if (([[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmOn] boolValue] && ([[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmMode] boolValue] == 0)) 
		|| [SleepTimerController sharedSleepTimerController].sleepTimerIsOn)
	{
		[[DeepSleepPreventer sharedDeepSleepPreventer] startPreventSleep];
//		[TBFOceanWaveGenerator sharedOceanWaveGenerator].silentMode = YES;
//		[[TBFOceanWaveGenerator sharedOceanWaveGenerator] play];
	}
	if (![[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmOn] boolValue])	{
			[mapViewController stopTrackingLocation];
		}
	}

/*
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
	if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kAlarmOn];
	}
}
*/

- (UINavigationController *)alarmSettingsNavigationController
{
	if (!alarmSettingsNavigationController)
	{
		AlarmSettingsViewController *viewController;
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		{
			// The device is an iPad running iPhone 3.2 or later.
			viewController = [[AlarmSettingsViewController alloc] initWithNibName:@"AlarmSettingsView-iPad" bundle:nil];
		} else {
			// The device is an iPhone or iPod touch.
			viewController = [[AlarmSettingsViewController alloc] initWithNibName:@"AlarmSettingsView" bundle:nil];
			UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(flipToClockView:)];
			viewController.navigationItem.rightBarButtonItem = doneButton;
		}

		alarmSettingsNavigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
		alarmSettingsNavigationController.delegate = viewController;
		if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
		{
			alarmSettingsNavigationController.navigationBar.barStyle = UIBarStyleBlack;
			alarmSettingsNavigationController.navigationBar.translucent = YES;
		}
		
		[viewController release];
	}
	
	return alarmSettingsNavigationController;
}

- (UINavigationController *)sleepTimerSettingsNavigationController
{
	if (!sleepTimerSettingsNavigationController)
	{
		SleepTimerSettingsViewController *viewController;
		
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		{
			// The device is an iPad running iPhone 3.2 or later.
			viewController = [[SleepTimerSettingsViewController alloc] initWithNibName:@"SleepTimerSettingsView-iPad" bundle:nil];
		} else {
			// The device is an iPhone or iPod touch.
			viewController = [[SleepTimerSettingsViewController alloc] initWithNibName:@"SleepTimerSettingsView" bundle:nil];
			UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(flipToClockView:)];
			viewController.navigationItem.rightBarButtonItem = doneButton;
		}
		
		sleepTimerSettingsNavigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
		
		if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
		{
			sleepTimerSettingsNavigationController.navigationBar.barStyle = UIBarStyleBlack;
			sleepTimerSettingsNavigationController.navigationBar.translucent = YES;
		}
		
		[viewController release];
	}
	
	return sleepTimerSettingsNavigationController;
}

-(void) applicationDidBecomeActive:(UIApplication *)application 
{
	if (self.backgroundSupported)
	{
		if ([[UIApplication sharedApplication] scheduledLocalNotifications].count < numberOfNotifications)
		{
			// One of the notifications has gone off...
			self.bypassAlarm = YES;
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kAlarmOn];
		}
		[[UIApplication sharedApplication] cancelAllLocalNotifications];
//		NSLog(@"scheduled notifications now: %d", [[UIApplication sharedApplication] scheduledLocalNotifications].count);
//		NSLog(@"notifications before: %d", numberOfNotifications);

	}
	
	[[DeepSleepPreventer sharedDeepSleepPreventer] stopPreventSleep];
	
	if (!self.tabBarController)
	{
		self.tabBarController = [[UITabBarController alloc] init];
		NSArray* controllers = [NSArray arrayWithObjects:self.alarmSettingsNavigationController, self.sleepTimerSettingsNavigationController, nil];
		self.tabBarController.viewControllers = controllers;
	}		
}

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/

- (void)dealloc {
    [tabBarController release];
	[alarmSettingsNavigationController release];
	[sleepTimerSettingsNavigationController release];
	[clockViewController release];
	[mapViewController release];
    [window release];
    [super dealloc];
}

@end

