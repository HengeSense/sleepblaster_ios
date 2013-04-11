//
//  DeepSleepPreventer.m
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 10/22/09.
//  Copyright 2009 The Byte Factory. All rights reserved.
//

#import "DeepSleepPreventer.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

static DeepSleepPreventer *sharedDeepSleepPreventer = nil;

@implementation DeepSleepPreventer

@synthesize audioPlayer;
@synthesize preventSleepTimer;
@synthesize isPreventingSleep;

+ (DeepSleepPreventer *)sharedDeepSleepPreventer {
	@synchronized(self) {
		if (sharedDeepSleepPreventer == nil)
			[[self alloc] init];
	}
	
	return sharedDeepSleepPreventer;
}

- (id)init
{
    if ((self = [super init])) {
		
		isPreventingSleep = NO;
		
		// Set up sound file
	//	NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"pinkNoise" ofType:@"m4a"];
	//	NSURL *fileURL = [NSURL fileURLWithPath:soundFilePath];
		
		// Set up audio player with sound file
	//	self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
		self.audioPlayer = [[AVAudioPlayer alloc] initWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"silent" ofType:@"mp3"]] error:NULL];
		[audioPlayer retain];
		self.audioPlayer.numberOfLoops = -1;
		[self.audioPlayer prepareToPlay];
		
		// You may want to set this to 0.0 even if your sound file is silent.
		// I don't know exactly if this affects battery life, but it can't hurt.
		[self.audioPlayer setVolume:0.0];
	}
    return self;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (sharedDeepSleepPreventer == nil) {
			sharedDeepSleepPreventer = [super allocWithZone:zone];
			return sharedDeepSleepPreventer;
		}
	}
	
	return nil;
}

- (id)copyWithZone:(NSZone *)zone {
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


- (void)playPreventSleepSound {
	
	NSLog(@"playing the preventer sound");
//	self.audioPlayer.numberOfLoops = -1;
	[self.audioPlayer play];
}

- (void)setAudioSessionForMediaPlayback {
	
	// Activate audio session
	AudioSessionSetActive(true);
	// Set up audio session to prevent iPhone from deep sleeping while playing sounds
	UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
	AudioSessionSetProperty (
							 kAudioSessionProperty_AudioCategory,
							 sizeof (sessionCategory),
							 &sessionCategory
							 );
	UInt32 property = 1;
//	OSStatus error;
	AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(property), &property);
}

- (void)startPreventSleep {
	
	if (!isPreventingSleep)
	{
		[self setAudioSessionForMediaPlayback];
		
		// We need to play a sound at least every 10 seconds to keep the iPhone awake.
		// We create a new repeating timer, that begins firing now and then every ten seconds.
		// Every time it fires, it calls -playPreventSleepSound
	/*	self.preventSleepTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:0]
														  interval:10.0
															target:self
														  selector:@selector(playPreventSleepSound)
														  userInfo:nil
														   repeats:YES];
		
		// We add this timer to the current run loop
		NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
		[runLoop addTimer:self.preventSleepTimer forMode:NSDefaultRunLoopMode];
	*/
		[self playPreventSleepSound];
		
		isPreventingSleep = YES;
	}
}

- (void)stopPreventSleep {

//	self.audioPlayer.numberOfLoops = 0;
	
	[self.audioPlayer stop];
	isPreventingSleep = NO;

}

- (void)dealloc {
	// memory management
	[preventSleepTimer release];
	[audioPlayer release];
	[super dealloc];
}

@end
