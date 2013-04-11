//
//  TBFOceanWaveGenerator.h
//  Sleep Blaster
//
//  Created by Eamon Ford on 9/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface TBFOceanWaveGenerator : NSObject {
	AVAudioPlayer *pinkNoise;
	NSTimer *timer;
	BOOL shouldStop;
	BOOL silentMode;
	float newVolume;
}

+ (TBFOceanWaveGenerator *)sharedOceanWaveGenerator;

- (void)play;
- (void)stop;
- (void)goThroughOneWaveCycle;

@property (nonatomic) BOOL silentMode;

@end
