//
//  DeepSleepPreventer.h
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 10/22/09.
//  Copyright 2009 The Byte Factory. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVAudioPlayer;

@interface DeepSleepPreventer : NSObject {
	AVAudioPlayer *audioPlayer;
	NSTimer *preventSleepTimer;
	BOOL isPreventingSleep;
}

@property (nonatomic, retain) AVAudioPlayer *audioPlayer;
@property (nonatomic, retain) NSTimer *preventSleepTimer;
@property (nonatomic, assign) BOOL isPreventingSleep;

+ (DeepSleepPreventer *)sharedDeepSleepPreventer;

- (void)playPreventSleepSound;
- (void)setAudioSessionForMediaPlayback;
- (void)startPreventSleep;
- (void)stopPreventSleep;

@end
