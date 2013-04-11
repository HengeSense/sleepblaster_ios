//
//  SleepTimerController.h
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 3/24/10.
//  Copyright 2010 The Byte Factory. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBFOceanWaveGenerator.h"


@interface SleepTimerController : NSObject {
	NSTimer *sleepTimer;
	TBFOceanWaveGenerator *oceanWaveGenerator;
	BOOL sleepTimerIsOn;
	id interfaceDelegate;
	float volumeBeforeFadout;
	float volume;
}

+ (SleepTimerController *)sharedSleepTimerController;
- (void)startSleepTimer;
- (void)stopSleepTimer:(NSTimer *)theTimer;

@property (assign) id interfaceDelegate;
@property BOOL sleepTimerIsOn;
@property float volume;

@end
