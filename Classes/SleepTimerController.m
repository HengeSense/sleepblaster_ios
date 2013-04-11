//
//  SleepTimerController.m
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 3/24/10.
//  Copyright 2010 The Byte Factory. All rights reserved.
//

#import "SleepTimerController.h"
#import "Constants.h"
#import <MediaPlayer/MediaPlayer.h>
#import "Sleep_Blaster_touchAppDelegate.h"
#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/AudioServices.h>

static SleepTimerController *sharedSleepTimerController = nil;

@implementation SleepTimerController

@synthesize interfaceDelegate;
@synthesize sleepTimerIsOn;
@synthesize volume;

BOOL alreadyIsGeneratingNotifications = NO;


+ (SleepTimerController *)sharedSleepTimerController {
	@synchronized(self) {
		if (sharedSleepTimerController == nil)
			[[self alloc] init];
	}
	
	return sharedSleepTimerController;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (sharedSleepTimerController == nil) {
			sharedSleepTimerController = [super allocWithZone:zone];
			return sharedSleepTimerController;
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
			
	self.sleepTimerIsOn = NO;

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

- (void)dealloc {
	[super dealloc];
//	[oceanWaveGenerator release];
}

- (void)playbackStateDidChange:(NSNotification *)notification
{
//	NSLog(@"playback did change!");
	// If the user manually stops the music, let's stop the whole sleep timer so it's not just going without any music.
	if (sleepTimerIsOn &&
		[[[NSUserDefaults standardUserDefaults] objectForKey:kSleepTimerFunction] intValue] == 0 &&
		[MPMusicPlayerController iPodMusicPlayer].playbackState != MPMusicPlaybackStatePlaying)
	{
//		NSLog(@"it was playing, but it's not. stopping the sleep timer.");
		[[SleepTimerController sharedSleepTimerController] stopSleepTimer:nil];
	}
	
	// After the sleep timer ends (and has faded out), we have to set the volume back to what it was before it faded out.
	// We do this in a different method because if we set the volume right after stopping the music, sometimes it
	// sets the volume before the music is actually stopped.
	if ([MPMusicPlayerController iPodMusicPlayer].playbackState == MPMusicPlaybackStateStopped)
	{
		// if volumeBeforeFadout was set before the fadeout, and if the music player's volume hasn't already been
		// set on again by something else, then let's set it back to what it was before the fadeout.
		if (volumeBeforeFadout &&
			[MPMusicPlayerController iPodMusicPlayer].volume ) {
			[MPMusicPlayerController iPodMusicPlayer].volume = volumeBeforeFadout;
		}
	}
}

- (void)startSleepTimer
{
	if (!alreadyIsGeneratingNotifications)
	{
		alreadyIsGeneratingNotifications = YES;
		[[MPMusicPlayerController iPodMusicPlayer] beginGeneratingPlaybackNotifications];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(playbackStateDidChange:)
													 name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
												   object:[MPMusicPlayerController iPodMusicPlayer]];	
	}
	
	self.sleepTimerIsOn = YES;
	
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSleepTimerFunction] intValue] == 0)
	{
		MPMusicPlayerController *musicPlayerController = [MPMusicPlayerController iPodMusicPlayer];
		musicPlayerController.volume = self.volume;
		
		Sleep_Blaster_touchAppDelegate *mainDelegate = (Sleep_Blaster_touchAppDelegate *)[[UIApplication sharedApplication] delegate];
		[musicPlayerController setQueueWithItemCollection:mainDelegate.sleepTimerSongsCollection];
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSleepTimerMusicShuffle] boolValue]) {
			musicPlayerController.shuffleMode = MPMusicShuffleModeSongs;
		} else {
			musicPlayerController.shuffleMode = MPMusicShuffleModeOff;
		}
		
		[musicPlayerController play];
		
	} 
	else if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSleepTimerFunction] intValue] == 1)
	{
		[[TBFOceanWaveGenerator sharedOceanWaveGenerator] play];
	}

	sleepTimer = [NSTimer scheduledTimerWithTimeInterval:[[[NSUserDefaults standardUserDefaults] objectForKey:kSleepTimerSeconds] intValue] 
												  target:self 
												selector:@selector(stopSleepTimer:)
												userInfo:nil repeats:NO];
}

- (void)stopSleepTimer:(NSTimer *)timer
{
	if (sleepTimer) {
		[sleepTimer invalidate];
	}
	
	self.sleepTimerIsOn = NO;

	if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSleepTimerFunction] intValue] == 0)	
	{
		MPMusicPlayerController *musicPlayerController = [MPMusicPlayerController iPodMusicPlayer];		
		volumeBeforeFadout = musicPlayerController.volume;
		if (timer)		// gradually ramp the volume down, ONLY IF the timer naturally ran out of time.
		{
			float rampVolume;
			for (rampVolume = musicPlayerController.volume; rampVolume >= 0; rampVolume -= .01) {
				[musicPlayerController setVolume:rampVolume];
				// pause 32/100th of a second (320,000 microseconds) between adjustments. 
				usleep(320000);
			}
		}
		[musicPlayerController stop];
				
	} else if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSleepTimerFunction] intValue] == 1) {
		[[TBFOceanWaveGenerator sharedOceanWaveGenerator] stop];
	}
	
	if (self.interfaceDelegate) {
		[interfaceDelegate hideArtworkContainerView];
	}
	
	if (![[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmOn] boolValue]) {
		[[DeepSleepPreventer sharedDeepSleepPreventer] stopPreventSleep];
	}	
}

- (void)setVolume:(float)newVolume
{
	volume = newVolume;
	
	if (self.sleepTimerIsOn)
	{
		[MPMusicPlayerController iPodMusicPlayer].volume = volume;
	}
}

@end
