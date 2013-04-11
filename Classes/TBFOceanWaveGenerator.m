//
//  TBFOceanWaveGenerator.m
//  Sleep Blaster
//
//  Created by Eamon Ford on 9/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "TBFOceanWaveGenerator.h"
#import "Randomizer.h"

static TBFOceanWaveGenerator *sharedOceanWaveGenerator = nil;

@implementation TBFOceanWaveGenerator

@synthesize silentMode;

+ (TBFOceanWaveGenerator *)sharedOceanWaveGenerator {
	@synchronized(self) {
		if (sharedOceanWaveGenerator == nil)
			[[self alloc] init];
	}
	
	return sharedOceanWaveGenerator;
}

- (id)init {
	if (self = [super init]) {
		shouldStop = NO;
		silentMode = NO;
		pinkNoise = [[AVAudioPlayer alloc] initWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pinkNoise" ofType:@"m4a"]] error:NULL];
		[pinkNoise retain];
		pinkNoise.numberOfLoops = -1;
	}
	return self;
}

- (void)play
{
	shouldStop = NO;
	
	// Fade in the volume.
	pinkNoise.volume = 0.0;
	
	[pinkNoise play];
	
	[self goThroughOneWaveCycle];
}

- (void)goThroughOneWaveCycle 
{
	Randomizer *randomizer = [[Randomizer alloc] init];
	newVolume = (float)([randomizer randomWithMax:90]+10) / 100;
	
	if (shouldStop) {
		newVolume = 0.0;
	}
		
	timer = [NSTimer scheduledTimerWithTimeInterval:0.05
													  target:self 
													selector:@selector(adjustVolumeOneIncrement:) 
													userInfo:nil 
													 repeats:YES];
}

- (void)stop
{
	// Fade out the volume. 
	shouldStop = YES;
	
	[self goThroughOneWaveCycle];
}

- (void)adjustVolumeOneIncrement:(NSTimer*)theTimer
{
	float volumeIncrement;
	if (newVolume < pinkNoise.volume) {
		volumeIncrement = -0.007;
	} else {
		volumeIncrement = 0.007;
	}
	
	float tempVolume = pinkNoise.volume+volumeIncrement;
	if (tempVolume > newVolume+0.007 || tempVolume < newVolume-0.007) { // give a little bit of leeway here
		pinkNoise.volume = tempVolume;
	} else { // we've reached the target volume
		[theTimer invalidate]; // stop adjusting the volume one increment
		if (shouldStop) {
			[pinkNoise stop]; // stop everything
		} else {
			[self goThroughOneWaveCycle]; // generate more waves
		}
	}
}

#pragma mark -
#pragma mark Singleton Pattern

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (sharedOceanWaveGenerator == nil) {
			sharedOceanWaveGenerator = [super allocWithZone:zone];
			return sharedOceanWaveGenerator;
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

@end
