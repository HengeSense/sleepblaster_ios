//
//  AlarmController.m
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 9/24/09.
//  Copyright 2009 The Byte Factory. All rights reserved.
//

#import "AlarmController.h"
#import "Constants.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SCListener.h"
#import "Sleep_Blaster_touchAppDelegate.h"
#import "SleepTimerController.h"
#import "DeepSleepPreventer.h"

static AlarmController *sharedAlarmController = nil;

@implementation AlarmController

@synthesize timer;
@synthesize explosionSound;
@synthesize alarmSound;

BOOL alarmIsRinging = NO;
Sleep_Blaster_touchAppDelegate *mainDelegate;

+ (AlarmController *)sharedAlarmController {
	@synchronized(self) {
		if (sharedAlarmController == nil)
			[[self alloc] init];
	}
	
	return sharedAlarmController;
}

- (void)dealloc {
	[explosionSound release];
	[alarmSound release];
	[super dealloc];
}

#pragma mark Alarm methods

- (void)playSongs:(NSTimer *)timer
{
/*		 MPMusicPlayerController *musicPlayerController = [MPMusicPlayerController iPodMusicPlayer];
		 MPMediaQuery *everything = [[MPMediaQuery alloc] init];
		 [musicPlayerController setQueueWithQuery:everything];
		 [musicPlayerController setShuffleMode:MPMusicShuffleModeSongs];
*/
		MPMusicPlayerController *musicPlayerController = [MPMusicPlayerController applicationMusicPlayer];

		// =========================== IT'S THIS LINE RIGHT HERE THAT'S CAUSING THE PROBLEM!!!!!!!
		// ===========	The queue doesn't work if it's been used twice for some reason.
		// =======================================================================================
		// =======================================================================================
		// =======================================================================================
		MPMediaItemCollection *collection = [MPMediaItemCollection collectionWithItems:mainDelegate.alarmSongsCollection.items];
		[musicPlayerController setQueueWithItemCollection:collection];	

		musicPlayerController.shuffleMode = MPMusicShuffleModeSongs;		
		[musicPlayerController play];

		[mainDelegate showAlarmRingingView];
	
}

- (IBAction)setupAlarm:(id)sender
{
	if (timer) {
		// Either the user is changing the alarm time, or the user is turning off the alarm.
		// Either way, we need to disable the timer for now.
		[timer invalidate];
		
	}
	// If we need to, we'll turn this back on a few lines down.
	if (!mainDelegate.mapViewController.view.superview) {		//	...but only do this if the view isn't showing!
		[mainDelegate.mapViewController stopTrackingLocation];
		
	}
	if (![[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmOn] boolValue]) {
		[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
		return;
	}
	
	if (![[[NSUserDefaults standardUserDefaults] objectForKey:kHasShownBackgroundMessage] boolValue])
	{
		if (mainDelegate.backgroundSupported)
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tip" message:@"When you set an alarm, it's a good idea to leave your device charging overnight, especially if you plan to leave the display on. Also, you can close Sleep Blaster and the alarm will still go off, but it will have to use Dynamite Mode because of a bug in the iPhone OS."
														   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
			[alert show];
			[alert release];	
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kHasShownBackgroundMessage];
		} else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tip" message:@"When you set an alarm, it's a good idea to leave your device charging overnight, especially if you plan to leave the display on. Also, you must leave Sleep Blaster open for the alarm to go off!"
														   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
			[alert show];
			[alert release];	
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kHasShownBackgroundMessage];
			
		}
	}
	
	
	// If the alarm is set for a time....
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmMode] boolValue] == 0)
	{
		NSDate *alarmDate = [self dateAlarmWillGoOff];
		
		if (!alarmDate) {
			return;
		}
		
		//[[NSUserDefaults standardUserDefaults] setObject:alarmDate forKey:kAlarmDate];	// update the date in the alarmSettings dictionary with the REAL alarm time/date.
		
		timer = [[[NSTimer alloc] initWithFireDate:alarmDate
										  interval:0
											target:self
										  selector:@selector(setOffAlarm:)
										  userInfo:nil
										   repeats:NO] retain];
		[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
		
		NSLog(@"You will wake up at %@", alarmDate);
		
	// Otherwise, if the alarm is set for a place....
	} else if ([[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmMode] boolValue] == 1)
	{
		mainDelegate.mapViewController.view;	// tell the view controller to load, if it hasn't already.
		[mainDelegate.mapViewController startTrackingLocation];
	}
	
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (IBAction)stopAlarm:(id)sender
{
	if (![[[NSUserDefaults standardUserDefaults] objectForKey:kEnableDynamiteMode] boolValue]) {
		[[MPMusicPlayerController applicationMusicPlayer] stop];
		[[DeepSleepPreventer sharedDeepSleepPreventer] setAudioSessionForMediaPlayback];
		
	} else {
		[explosionSound stop];
		[alarmSound stop];
	}
	
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
	{
		[mainDelegate hideAlarmRingingView];
	}
	
	UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
	AudioSessionSetProperty (
							 kAudioSessionProperty_AudioCategory,
							 sizeof (sessionCategory),
							 &sessionCategory
							 );
	UInt32 property = 1;
//	OSStatus error;
	AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(property), &property);
	
	alarmIsRinging = NO;
	
	// If the alarm is set to go off on weekdays, we need to set the timer again.
	[self setupAlarm:self];
	
	[[DeepSleepPreventer sharedDeepSleepPreventer] stopPreventSleep];
	
//	NSTimer *newTimer = [[[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:10]
//									  interval:0
//										target:self
//									  selector:@selector(playSongs:)
//									  userInfo:nil
//									   repeats:NO] retain];
//	[[NSRunLoop currentRunLoop] addTimer:newTimer forMode:NSRunLoopCommonModes];
}

- (IBAction)snoozeAlarm:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:kAlarmMode];

	//NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:kAlarmDate];
	NSDate *date = [NSDate date];
	
//	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	NSDateComponents *components = [[NSCalendar currentCalendar] components:unitFlags fromDate:date];
	[components setMinute:[components minute]+[[[NSUserDefaults standardUserDefaults] objectForKey:kSnoozeMinutes] intValue]];
	
	NSDate *snoozeDate = [[NSCalendar currentCalendar] dateFromComponents:components];

	[[NSUserDefaults standardUserDefaults] setObject:snoozeDate forKey:kAlarmDate];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kAlarmOn];

//	[calendar release];
	
	[self stopAlarm:self];
	[self setupAlarm:self];
}

- (void)vibrate:(NSTimer *)theTimer {
	if (!alarmIsRinging) {
		[theTimer invalidate];
		return;
	}
	
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

//	SystemSoundID pmph;
//	id sndpath = [[NSBundle mainBundle] 
//				  pathForResource:@"alarm" 
//				  ofType:@"aif"];
//	CFURLRef baseURL = (CFURLRef) [[NSURL alloc] initFileURLWithPath:sndpath];
//	AudioServicesCreateSystemSoundID (baseURL, &pmph);
//	AudioServicesPlaySystemSound(pmph);	
//	[baseURL release];
}


- (BOOL)isHeadsetPluggedIn 
{
	UInt32 routeSize = sizeof (CFStringRef);
	CFStringRef route;
		
	OSStatus error = AudioSessionGetProperty (kAudioSessionProperty_AudioRoute,
											  &routeSize,
											  &route);
	
	if (!error && (route != NULL) && (([route isEqual:@"Headset"]) || ([route isEqual:@"Headphone"]))) {
		return YES;
	}
	
	return NO;
}

- (void)setOffAlarm:(NSTimer *)theTimer
{
	if ([SleepTimerController sharedSleepTimerController].sleepTimerIsOn) 
	{
		[[SleepTimerController sharedSleepTimerController] stopSleepTimer:nil];
	}
	
	if (mainDelegate.bypassAlarm)
	{
		mainDelegate.bypassAlarm = NO;
		return;
	}
	
	if (mainDelegate.backgroundSupported)
	{
		 UILocalNotification *notification = [[UILocalNotification alloc] init];
		 notification.alertBody = @"";
		 notification.alertAction = @"Turn off";
		 notification.userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"PresentedImmediately"];

		 [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
	}
	
	[[DeepSleepPreventer sharedDeepSleepPreventer] startPreventSleep];
	
	// If we're running in the background, or if there's no items in the song queue, use dynamite.
	if (mainDelegate.backgroundSupported)
	{
		if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground ||
			mainDelegate.alarmSongsCollection.items.count == 0)
		{
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kEnableDynamiteMode];	
		}
	} else {

		if (mainDelegate.alarmSongsCollection.items.count == 0)
		{
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kEnableDynamiteMode];	
		}
		
	}
	alarmIsRinging = YES;

	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kAlarmOn];

	[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(vibrate:) userInfo:nil repeats:YES];

	if (!mainDelegate.alarmSongsCollection.count)
	{
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kEnableDynamiteMode];
	}
	
	if (![[[NSUserDefaults standardUserDefaults] objectForKey:kEnableDynamiteMode] boolValue]) {	// if it's set to use music...		
			
		//	Fade in the iTunes volume for the amount of time set.
		//[NSThread detachNewThreadSelector:@selector(graduallyIncreaseiTunesVolumeForSeconds:) toTarget:self 
		//					withObject:[userDef objectForKey:@"TimeToIncreaseAlarmVolume"]];
		
		MPMusicPlayerController *musicPlayerController = [MPMusicPlayerController applicationMusicPlayer];
		MPMediaItemCollection *collection = [MPMediaItemCollection collectionWithItems:mainDelegate.alarmSongsCollection.items];
		[musicPlayerController setQueueWithItemCollection:collection];
//		[musicPlayerController setQueueWithItemCollection:mainDelegate.alarmSongsCollection];
		
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmMusicShuffle] boolValue]) {
			musicPlayerController.shuffleMode = MPMusicShuffleModeSongs;
		} else {
			musicPlayerController.shuffleMode = MPMusicShuffleModeOff;
		}
		
		[musicPlayerController play];
		
		if (![self isHeadsetPluggedIn])
		{
			[musicPlayerController setVolume:1.0];
		}

/*		
		AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:[[mainDelegate.alarmSongsCollection.items objectAtIndex:0] valueForProperty:MPMediaItemPropertyAssetURL] 
												   options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey]];
		
		

		AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:urlAsset];
		//AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"alarm" ofType:@"mp3"]]];
		
		AVPlayer *player = [[AVPlayer playerWithPlayerItem:playerItem] retain];
		[player play];
*/

		if ([[[NSUserDefaults standardUserDefaults] objectForKey:kEnableVoiceControls] boolValue]) {
			// Only enable voice controls if it's using iTunes, and not Dynamite.

			// Set the audio session for voice controls.....
			UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
			AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
			UInt32 property = 1;
			AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(property), &property);
			
/*			UInt32 allowMixing = true;
			AudioSessionSetProperty(kAudioSessionProperty_OtherMixableAudioShouldDuck,    // 1
									sizeof(allowMixing),                                  // 2
									&allowMixing);
*/			// As long as we're not running on an iPod Touch, route the audio output to the bottom speaker.
			NSString *deviceType = [UIDevice currentDevice].model;
			if(![deviceType isEqualToString:@"iPod Touch"])
			{
				UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
				AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
				[musicPlayerController setVolume:1.0];
//				NSLog(@"should have set the volume up...");
			}
			AudioSessionSetActive(true);
						
			UInt32 inputAvailableSize = sizeof(UInt32);
			UInt32 inputAvailable;
			AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable, &inputAvailableSize, &inputAvailable);
			if (inputAvailable)
			{
				[NSThread detachNewThreadSelector:@selector(playAndPauseiTunes:) toTarget:self withObject:nil];
			}
		}
	
	} else {	// otherwise, use dynamite.
		
		[[MPMusicPlayerController iPodMusicPlayer] pause];

		if (![self isHeadsetPluggedIn])
		{
			[[MPMusicPlayerController iPodMusicPlayer] setVolume:1.0];
		}
		explosionSound.currentTime = 0;
		explosionSound.volume = 1.0;
		[explosionSound play];
	}

	// Finally, update the interface to show that the alarm's ringing.	
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
		if ([[[NSCalendar currentCalendar] locale] timeIs24HourFormat])
		{
			[dateFormatter setDateFormat:@"HH:mm"];
		} else {
			[dateFormatter setDateFormat:@"h:mma"];
		}
		NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
		
		if (alertView)
		{
			[alertView release];
		}
		alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"It's %@!", currentTime] 
															message:@"Hey, time to wake up!" 
														   delegate:self 
												  cancelButtonTitle:@"Stop" 
												  otherButtonTitles:@"Snooze", nil];
	
		[alertView show];
	} else {
		[mainDelegate showAlarmRingingView];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)
	{
		[self stopAlarm:self];
	} else {
		[self snoozeAlarm:self];
	}
}

- (void)playAndPauseiTunes:(id)sender
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// Let iTunes play for "PlayInterval" microseconds * one million, then stop iTunes.
	usleep([[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmPlayInterval] intValue]*1000000);
	
	MPMusicPlayerController *musicPlayerController = [MPMusicPlayerController applicationMusicPlayer];
	
	float originalVolume = musicPlayerController.volume;
	
	float rampVolume;
	for (rampVolume = musicPlayerController.volume; rampVolume >= 0; rampVolume -= .04) {
		[musicPlayerController setVolume:rampVolume];
		// pause 2/100th of a second (20,000 microseconds) between adjustments. 
		usleep(20000);
	}
	
	// If the alarm is still ringing, listen for 2 seconds, then stop listening.
	if (alarmIsRinging) {
		[self performSelectorOnMainThread:@selector(startReadingVolume:) withObject:self waitUntilDone:YES];
		// Pause iTunes for "PauseInterval" microseconds * one million, then start over the loop.
		usleep([[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmPauseInterval] intValue]*1000000);
		[self performSelectorOnMainThread:@selector(stopReadingVolume:) withObject:self waitUntilDone:YES];
	}
	
	// Fade the volume back in. (That DOESN'T mean iTunes is actually playing!)
	//int targetVolume = [[userDef objectForKey:@"iTunesVolume"] intValue];
//	int targetVolume = 1.0;
	for (rampVolume = musicPlayerController.volume; rampVolume <= originalVolume; rampVolume += .04) {
		[musicPlayerController setVolume:rampVolume];
		// pause 2/100th of a second (10,000 microseconds) between adjustments.
		usleep(20000);
	}
	
	[pool release];
	
	if (alarmIsRinging) {
		[self playAndPauseiTunes:self];
	}
}

- (NSDate *)dateAlarmWillGoOff
{
//	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
	NSDateComponents *components = [[NSCalendar currentCalendar] components:unitFlags fromDate:[NSDate date]];
	
	unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit |  NSSecondCalendarUnit;
	NSDateComponents *rawAlarmDateComponents = [[NSCalendar currentCalendar] components:unitFlags fromDate:[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmDate]];
	
	[components setHour:[rawAlarmDateComponents hour]];
	[components setMinute:[rawAlarmDateComponents minute]];
	[components setSecond:0];
	
	// This date is the alarm time, set for today.
	NSDate *alarmDate = [[NSCalendar currentCalendar] dateFromComponents:components];
	
	if ([alarmDate earlierDate:[NSDate date]] == alarmDate) {	// if it's already past that time today...
		// set it for the same time tomorrow.
		NSDateComponents *plusOneDay = [[[NSDateComponents alloc] init] autorelease];
		[plusOneDay setDay:1];
		
		alarmDate = [[NSCalendar currentCalendar] dateByAddingComponents:plusOneDay toDate:alarmDate options:0];
	}
	
//	[calendar release];
	//[[NSUserDefaults standardUserDefaults] setObject:alarmDate forKey:kAlarmDate];
	
	return alarmDate;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	if (player == explosionSound) {
		alarmSound.currentTime = 0;
		alarmSound.volume = 1.0;
		[alarmSound play];
	}
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
	NSLog(@"application did become active");
	if (alarmIsRinging)
	{
		NSLog(@"alarm is ringing...");
//		if (alertView.visible)
//		{
			NSLog(@"going to show the alert view again...");
			[alertView dismissWithClickedButtonIndex:0 animated:YES];
			[alertView show];
//		}
	}
}

#pragma mark Microphone methods
- (void)startReadingVolume:(id)sender
{
	[[SCListener sharedListener] listen];
	
	if (listenerTimer) {
		[listenerTimer invalidate];
	}
	
	listenerTimer = [[NSTimer scheduledTimerWithTimeInterval:.1
													  target:self 
													selector:@selector(processVolumeReading) 
													userInfo:nil 
													 repeats:YES] retain];
}

- (void)stopReadingVolume:(id)sender
{
	[listenerTimer invalidate];
	[[SCListener sharedListener] pause];
}

- (void)processVolumeReading
{
	float threshold = .10;
	float volumeLevel = [[SCListener sharedListener] averagePower];
	if (volumeLevel > threshold) {
		// stop the alarm...
		
		[self stopReadingVolume:self];
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:kVoiceFunction] intValue] == 0)
		{
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
				[alertView dismissWithClickedButtonIndex:1 animated:YES];
			}
			[self snoozeAlarm:self];

		} else if ([[[NSUserDefaults standardUserDefaults] objectForKey:kVoiceFunction] intValue] == 1)
		{
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
				[alertView dismissWithClickedButtonIndex:0 animated:YES];
			}
			[self stopAlarm:self];
		}
	}
}

- (void)timeZoneDidChange:(id)notification
{
	NSTimeZone *oldTimeZone = [NSTimeZone timeZoneWithName:[[NSUserDefaults standardUserDefaults] objectForKey:kOldTimeZone]];
	
	int gmtDifferenceForOldTimeZone = [oldTimeZone secondsFromGMT];
	int gmtDifferenceForNewTimeZone = [[NSTimeZone defaultTimeZone] secondsFromGMT];
	int differenceBetweenNewAndOld = gmtDifferenceForOldTimeZone - gmtDifferenceForNewTimeZone;
	
	if (differenceBetweenNewAndOld != 0)
	{
		NSDate *convertedDate = [[[AlarmController sharedAlarmController] dateAlarmWillGoOff] dateByAddingTimeInterval:differenceBetweenNewAndOld];
		[[NSUserDefaults standardUserDefaults] setObject:convertedDate forKey:kAlarmDate];
		[[AlarmController sharedAlarmController] setupAlarm:self];
	
//		oldTimeZone = [NSTimeZone defaultTimeZone];
		[[NSUserDefaults standardUserDefaults] setObject:[[NSTimeZone defaultTimeZone] name] forKey:kOldTimeZone];
	}

}

#pragma mark -
#pragma mark Singleton Pattern


+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (sharedAlarmController == nil) {
			sharedAlarmController = [super allocWithZone:zone];
			return sharedAlarmController;
		}
	}
	
	return nil;
}

- (id)copyWithZone:(NSZone *)zone {
	return self;
}


- (id)init {
	if ([super init] == nil)
		return nil;
		
	mainDelegate = (Sleep_Blaster_touchAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	// "warm up" the microphone for later.
	[[SCListener sharedListener] listen];
	[[SCListener sharedListener] pause];
	[[DeepSleepPreventer sharedDeepSleepPreventer] setAudioSessionForMediaPlayback];
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(applicationDidBecomeActive:) 
													 name:UIApplicationDidBecomeActiveNotification 
												   object:nil];
	}
	self.explosionSound = [[AVAudioPlayer alloc] initWithContentsOfURL:
					  [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"explosion" ofType:@"mp3"]]
															error:nil];
	self.explosionSound.delegate = self;
	
	self.alarmSound = [[AVAudioPlayer alloc] initWithContentsOfURL:
					  [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"alarm" ofType:@"mp3"]]
														error:nil];
	self.alarmSound.delegate = self;
	self.alarmSound.numberOfLoops = -1;
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(timeZoneDidChange:) 
												 name:NSSystemTimeZoneDidChangeNotification 
											   object:nil];
	
	[self timeZoneDidChange:nil];

	return self;
}

- (id)retain {
	return self;
}

- (unsigned)retainCount {
	return UINT_MAX;
}

- (void)release {
	// Do nothing.
}

- (id)autorelease {
	return self;
}

@end
