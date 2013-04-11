//
//  FirstViewController.m
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 6/9/09.
//  Copyright The Byte Factory 2009. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "Constants.h"
#import "FirstViewController.h"
#import <dlfcn.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SCListener.h"
#import "AlarmRingingViewController.h"
#import "AlarmController.h"
#import "Sleep_Blaster_touchAppDelegate.h"

@implementation FirstViewController

@synthesize currentTimeLabel;
@synthesize currentDateLabel;
//@synthesize timer;

//BOOL alarmIsRinging = NO;


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
 NSUInteger loadFonts()
{
	NSUInteger newFontCount = 0;
	NSBundle *frameworkBundle = [NSBundle bundleWithIdentifier:@"com.apple.GraphicsServices"];
	const char *frameworkPath = [[frameworkBundle executablePath] UTF8String];
	if (frameworkPath) {
		void *graphicsServices = dlopen(frameworkPath, RTLD_NOLOAD | RTLD_LAZY);
		if (graphicsServices) {
			BOOL (*GSFontAddFromFile)(const char *) = dlsym(graphicsServices, "GSFontAddFromFile");
			if (GSFontAddFromFile)
				for (NSString *fontFile in [[NSBundle mainBundle] pathsForResourcesOfType:@"ttf" inDirectory:nil])
					newFontCount += GSFontAddFromFile([fontFile UTF8String]);
		}
	}
	return newFontCount;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	loadFonts();
	
	UIFont *bigFont = [UIFont fontWithName:@"Digital-7" size:80.0];
	UIFont *smallFont = [UIFont fontWithName:@"Digital-7" size:24.0];
	
	currentTimeLabel.font = bigFont;
	currentDateLabel.font = smallFont;
	
	[self setCurrentDateAndTimeLabels];
	
//	[AlarmController sharedAlarmController].alarmInterfaceDelegate = self;
	
	NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self
													selector:@selector(updateClock:)
													userInfo:nil repeats:YES];
	
	
//	[alarmOnSwitch setOn:[[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmOn] boolValue]];

	
	//AlarmRingingViewController *alarmRingingViewController = [[AlarmRingingViewController alloc] initWithNibName:@"AlarmRingingView" bundle:[NSBundle mainBundle]];
	

	[[AlarmController sharedAlarmController] setupAlarm:self];
}

- (void)viewDidAppear:(BOOL)animated
{
	
	[UIDevice currentDevice].proximityMonitoringEnabled = YES;

	// We're loading the alarm songs collection right after the app launched
	// so that we won't have to do it later, because it might take a few seconds. We're storing it
	// in the app delegate so that the SecondView can access it too.
//	Sleep_Blaster_touchAppDelegate *mainDelegate = (Sleep_Blaster_touchAppDelegate *)[[UIApplication sharedApplication] delegate];
//	mainDelegate.songsCollection = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:kSongsCollection]];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[UIDevice currentDevice].proximityMonitoringEnabled = NO;
}


- (void)updateClock:(NSTimer *)theTimer
{
	[self setCurrentDateAndTimeLabels];
}

- (void)setCurrentDateAndTimeLabels
{
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"h:mma"];
	NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
	[currentTimeLabel setText:currentTime];
	
	[dateFormatter setDateFormat:@"cccc, MMMM d"];
	NSString *currentDate = [dateFormatter stringFromDate:[NSDate date]];
	[currentDateLabel setText:currentDate];
	
}

/*
- (IBAction)setupAlarm:(id)sender
{	
//	if (timer) {
//		// Either the user is changing the alarm time, or the user is turning off the alarm.
//		// Either way, we need to disable the timer for now.
//		[timer invalidate];
//	}
	
	if ([sender class] == [UISwitch class]) {
		[self setAlarmOnValue:sender];
	}
	
	[[AlarmController sharedAlarmController] setupAlarm:self];
	
//	if (![[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmOn] boolValue]) {
//		return;
//	}
//	
//	NSDate *alarmDate = [[NSUserDefaults standardUserDefaults] objectForKey:kAlarmDate];
//	if (!alarmDate) {
//		return;
//	}
//	
//	//[[NSUserDefaults standardUserDefaults] setObject:alarmDate forKey:kAlarmDate];	// update the date in the alarmSettings dictionary with the REAL alarm time/date.
//	
//	timer = [[[NSTimer alloc] initWithFireDate:alarmDate
//									  interval:0
//										target:self
//									  selector:@selector(timerDidFire:)
//									  userInfo:nil
//									   repeats:NO] retain];
//	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
//	
//	NSLog(@"You will wake up at %@", alarmDate);
}
*/

//- (IBAction)setAlarmOnValue:(UISwitch *)sender
//{
//	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:sender.on] forKey:kAlarmOn];	
//	[[AlarmController sharedAlarmController] setupAlarm:self];
//}

/*- (IBAction)stopAlarm:(id)sender
{
//	if (usingAlarmMode == ITUNES) {
	[[MPMusicPlayerController applicationMusicPlayer] stop];
//	} else if (usingAlarmMode == DYNAMITE) {
//		[explosion stop];
//		[alarmSound stop];
//		[self toggleBlastWindow];
//	}
	
//	[self toggleAlarmRingingView];

//	alarmIsRinging = NO;
	
	// If the alarm is set to go off on weekdays, we need to set the timer again.
	[self setupAlarm:self];
}*/



//- (void)timerDidFire:(NSTimer *)theTimer
//{
////	NSLog(@"the timer is firing!");
////
////	alarmIsRinging = YES;
////	
//////	if ([sleepTimerView superview]) {	// if the sleep timer is going on...
//////		[self stopSleepTimer:self];		// stop it before ringing the alarm.
//////	}
////		
//////	// If it's set for one date, turn it off now.
//////	if ([[alarmSettings objectForKey:@"AlarmDays"] count] == 0) {
////		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kAlarmOn];
//		[alarmOnSwitch setOn:NO animated:YES];
//	
////	}
//		
////	// Set the system volume.
////	NSMutableString *scriptSource = [NSMutableString stringWithFormat:@"set volume %d\n", [[userDef objectForKey:@"SystemVolume"] intValue]];
////	NSAppleScript *setSysetmVolume = [[[NSAppleScript alloc] initWithSource:scriptSource] autorelease];
////	NSDictionary *error = [NSDictionary dictionary];
////	[setSysetmVolume executeAndReturnError:&error];
//	
//		
//	//if ([[alarmSettings objectForKey:@"WakeupMode"] intValue] == 0) {	// if it's set for iTunes...
//		//usingAlarmMode = ITUNES;
//		
//		//[HUDView setDisplayMode:ITUNES];
//		
//		//iTunesTrack *track = [self getiTunesTrackFromSettingsFor:SLEEP_BLASTER];
//		
//		//	Fade in the iTunes volume for the amount of time set.
//		//[NSThread detachNewThreadSelector:@selector(graduallyIncreaseiTunesVolumeForSeconds:) toTarget:self 
//		//					withObject:[userDef objectForKey:@"TimeToIncreaseAlarmVolume"]];
//		//[track playOnce:NO];
//		
////		MPMusicPlayerController *musicPlayerController = [MPMusicPlayerController applicationMusicPlayer];
////		MPMediaItemCollection *mediaItemCollection = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"songs"]];
////
////		[musicPlayerController setVolume:1.0];
////		[musicPlayerController setQueueWithItemCollection:mediaItemCollection];
////		[musicPlayerController play];
////	
////		// Only enable voice controls if it's using iTunes, and not Dynamite.
//////		if ([[userDef objectForKey:@"SpeechControlsEnabled"] boolValue] == YES &&
//////			[[userDef objectForKey:@"TimeToIncreaseAlarmVolume"] intValue] == 0) {
////
////	
////	if ([[[NSUserDefaults standardUserDefaults] objectForKey:kEnableVoiceControls] boolValue]) {
////			[NSThread detachNewThreadSelector:@selector(playAndPauseiTunes:) toTarget:self withObject:nil];
////		}
//
//	
//	
//	//	} else {	// otherwise, use dynamite.
////		usingAlarmMode = DYNAMITE;
////		[HUDView setDisplayMode:DYNAMITE];
////		[self toggleBlastWindow];
//		
////		[explosion play];
////	}
//	
//	// Finally, update the interface to show that the alarm's ringing.	
//	//[self toggleAlarmRingingView];
//	
//	//AlarmRingingViewController *ringingController = [[AlarmRingingViewController alloc] initWithNibName:@"AlarmRingingView" bundle:<#(NSBundle *)nibBundleOrNil#>
//}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}


#pragma mark iTunes Stuff

//- (void)playAndPauseiTunes:(id)sender
//{
//	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//		
//	// Let iTunes play for 2 microseconds * one million, then stop iTunes.
//	//usleep([[userDef objectForKey:@"AlarmPlayInterval"] intValue]*1000000);
//	usleep(2*1000000);
//	
//	MPMusicPlayerController *musicPlayerController = [MPMusicPlayerController applicationMusicPlayer];
//	
//	float rampVolume;
//	for (rampVolume = musicPlayerController.volume; rampVolume >= 0; rampVolume -= .04) {
//		[musicPlayerController setVolume:rampVolume];
//		/* pause 2/100th of a second (20,000 microseconds) between adjustments. */
//		usleep(20000);
//	}
//	
//	// If the alarm is still ringing, listen for 2 seconds, then stop listening.
//	if (alarmIsRinging) {
//		[self performSelectorOnMainThread:@selector(startReadingVolume:) withObject:self waitUntilDone:YES];
//		//usleep([[userDef objectForKey:@"AlarmPauseInterval"] intValue]*1000000);
//		usleep(2*1000000);
//		[self performSelectorOnMainThread:@selector(stopReadingVolume:) withObject:self waitUntilDone:YES];
//	}
//
//	// Fade the volume back in. (That DOESN'T mean iTunes is actually playing!)
//	//int targetVolume = [[userDef objectForKey:@"iTunesVolume"] intValue];
//	int targetVolume = 1.0;
//	for (rampVolume = musicPlayerController.volume; rampVolume <= targetVolume; rampVolume += .04) {
//		[musicPlayerController setVolume:rampVolume];
//		/* pause 2/100th of a second (10,000 microseconds) between adjustments. */
//		usleep(20000);
//	}
//	
//	[pool release];
//	
//	if (alarmIsRinging) {
//		[self playAndPauseiTunes:self];
//	}
//}

/*- (void)startReadingVolume:(id)sender
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

//- (void)processVolumeReading:(double)volumeLevel
- (void)processVolumeReading
{
	NSLog(@"%f", [[SCListener sharedListener] averagePower]);
	float threshold = .15;
	float volumeLevel = [[SCListener sharedListener] averagePower];
	if (volumeLevel > threshold) {
		// stop the alarm...
		[self stopAlarm:self];
	}
//	} else {
//		[self performSelectorOnMainThread:@selector(stopReadingVolume:) withObject:self waitUntilDone:YES];
//		//[musicPlayerController play];
//	}
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
