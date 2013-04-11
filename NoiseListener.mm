//
/*

    File: SpeakHereController.mm
Abstract: n/a
 Version: 2.2

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
Inc. ("Apple") in consideration of your agreement to the following
terms, and your use, installation, modification or redistribution of
this Apple software constitutes acceptance of these terms.  If you do
not agree with these terms, please do not use, install, modify or
redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following
text and disclaimers in all such redistributions of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may
be used to endorse or promote products derived from the Apple Software
without specific prior written permission from Apple.  Except as
expressly stated in this notice, no other rights or licenses, express or
implied, are granted by Apple herein, including but not limited to any
patent rights that may be infringed by your derivative works or by other
works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2009 Apple Inc. All Rights Reserved.


*/

#import "NoiseListener.h"


@implementation NoiseListener

//@synthesize player;
@synthesize recorder;
@synthesize delegate;

//@synthesize btn_record;
//@synthesize btn_play;
//@synthesize fileDescription;
//@synthesize lvlMeter_in;
//@synthesize playbackWasInterrupted;

//char *OSTypeToStr(char *buf, OSType t)
//{
//	char *p = buf;
//	char str[4], *q = str;
//	*(UInt32 *)str = CFSwapInt32(t);
//	for (int i = 0; i < 4; ++i) {
//		if (isprint(*q) && *q != '\\')
//			*p++ = *q++;
//		else {
//			sprintf(p, "\\x%02x", *q++);
//			p += 4;
//		}
//	}
//	*p = '\0';
//	return buf;
//}
//
//-(void)setFileDescriptionForFormat: (CAStreamBasicDescription)format withName:(NSString*)name
//{
//	char buf[5];
//	const char *dataFormat = OSTypeToStr(buf, format.mFormatID);
//	NSString* description = [[NSString alloc] initWithFormat:@"(%d ch. %s @ %g Hz)", format.NumberChannels(), dataFormat, format.mSampleRate, nil];
//	fileDescription.text = description;
//	[description release];	
//}

#pragma mark Playback routines

//-(void)stopPlayQueue
//{
//	player->StopQueue();
//	[lvlMeter_in setAq: nil];
//	btn_record.enabled = YES;
//}

//- (void)stopRecord
//{
//	// Disconnect our level meter from the audio queue
//	[lvlMeter_in setAq: nil];
//	
//	recorder->StopRecord();
//	
//	// dispose the previous playback queue
//	player->DisposeQueue(true);
//
//	// now create a new queue for the recorded file
//	recordFilePath = (CFStringRef)[NSTemporaryDirectory() stringByAppendingPathComponent: @"recordedFile.caf"];
//	player->CreateQueueForFile(recordFilePath);
//		
//	// Set the button's state back to "record"
//	btn_record.title = @"Record";
//	btn_play.enabled = YES;
//}

//- (IBAction)play:(id)sender
//{
//	if (player->IsRunning())
//		[self stopPlayQueue];
//	
//	else
//	{		
//		OSStatus result = player->StartQueue(false);
//		if (result == noErr)
//			[[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueResumed" object:self];
//	}
//}

- (IBAction)startListening:(id)sender
{	
	NSLog(@"about to start listening...");
//	if (recorder->IsRunning()) // If we are currently recording, stop and save the file.
//	{
//	}
//	else // If we're not recording, start.
//	{		
		// Start the recorder
		recorder->StartRecord(CFSTR("recordedFile.caf"));
				
		// Hook the level meter up to the Audio Queue for the recorder
		[self setAq: recorder->Queue()];
//	} 
}

- (IBAction)stopListening:(id)sender
{
	NSLog(@"about to stop listening...");
	if (_updateTimer) {
		[_updateTimer invalidate];
	}
}

- (void)setAq:(AudioQueueRef)v
{	
//	if ((_aq == NULL) && (v != NULL))
//	{
		if (_updateTimer) {
			[_updateTimer invalidate];
		}
		
		_updateTimer = [[NSTimer 
						scheduledTimerWithTimeInterval:.1
						target:self 
						selector:@selector(_refresh) 
						userInfo:nil 
						repeats:YES] retain];
//	}
	//	} else if ((_aq != NULL) && (v == NULL)) {
	//		_peakFalloffLastFire = CFAbsoluteTimeGetCurrent();
	//	}
	
	_aq = v;
	
	if (_aq)
	{
		try {
			UInt32 val = 1;
			XThrowIfError(AudioQueueSetProperty(_aq, kAudioQueueProperty_EnableLevelMetering, &val, sizeof(UInt32)), "couldn't enable metering");
			
			// now check the number of channels in the new queue, we will need to reallocate if this has changed
			CAStreamBasicDescription queueFormat;
			UInt32 data_sz = sizeof(queueFormat);
			XThrowIfError(AudioQueueGetProperty(_aq, kAudioQueueProperty_StreamDescription, &queueFormat, &data_sz), "couldn't get stream description");
			
			if (queueFormat.NumberChannels() != [_channelNumbers count])
			{
				NSArray *chan_array;
				if (queueFormat.NumberChannels() < 2)
					chan_array = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:0], nil];
				else
					chan_array = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:1], nil];
				
				//[self setChannelNumbers:chan_array];
				[chan_array retain];
				[_channelNumbers release];
				_channelNumbers = chan_array;
				
				[chan_array release];
				
				_chan_lvls = (AudioQueueLevelMeterState*)realloc(_chan_lvls, queueFormat.NumberChannels() * sizeof(AudioQueueLevelMeterState));
			}
		}
		catch (CAXException e) {
			char buf[256];
			fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
		}
	}
}

- (void)_refresh
{
	//	BOOL success = NO;
	
	// if we have no queue, but still have levels, gradually bring them down
	//	if (_aq == NULL)
	//	{
	//		CGFloat maxLvl = -1.;
	//		CFAbsoluteTime thisFire = CFAbsoluteTimeGetCurrent();
	//		// calculate how much time passed since the last draw
	//		CFAbsoluteTime timePassed = thisFire - _peakFalloffLastFire;
	//		for (LevelMeter *thisMeter in _subLevelMeters)
	//		{
	//			CGFloat newPeak, newLevel;
	//			newLevel = thisMeter.level - timePassed * kLevelFalloffPerSec;
	//			if (newLevel < 0.) newLevel = 0.;
	//			thisMeter.level = newLevel;
	//			if (_showsPeaks)
	//			{
	//				newPeak = thisMeter.peakLevel - timePassed * kPeakFalloffPerSec;
	//				if (newPeak < 0.) newPeak = 0.;
	//				thisMeter.peakLevel = newPeak;
	//				if (newPeak > maxLvl) maxLvl = newPeak;
	//			}
	//			else if (newLevel > maxLvl) maxLvl = newLevel;
	//			
	//			[thisMeter setNeedsDisplay];
	//		}
	//		// stop the timer when the last level has hit 0
	//		if (maxLvl <= 0.)
	//		{
	//			[_updateTimer invalidate];
	//			_updateTimer = nil;
	//		}
	//		
	//		_peakFalloffLastFire = thisFire;
	//		success = YES;
	//	} else {
	
	UInt32 data_sz = sizeof(AudioQueueLevelMeterState) * [_channelNumbers count];
	OSErr status = AudioQueueGetProperty(_aq, kAudioQueueProperty_CurrentLevelMeter, _chan_lvls, &data_sz);
	//if (status != noErr) goto bail;

	for (int i=0; i<[_channelNumbers count]; i++)
	{
		NSInteger channelIdx = [(NSNumber *)[_channelNumbers objectAtIndex:i] intValue];
		//LevelMeter *channelView = [_subLevelMeters objectAtIndex:channelIdx];
		
		//if (channelIdx >= [_channelNumbers count]) goto bail;
		//if (channelIdx > 127) goto bail;
		
		if (_chan_lvls) 
		{
			// There seems to be a bug with passing a float to processVolumeReading:, but passing a double works fine.
			double volumeLevel = (double)_chan_lvls[channelIdx].mAveragePower;
			
			//[delegate processVolumeReading:[NSNumber numberWithFloat:volumeLevel]];
			[NSThread detachNewThreadSelector:@selector(processVolumeReading:) toTarget:delegate withObject:[NSNumber numberWithFloat:volumeLevel]];

		}
	}
	//	}
	
	//bail:
	//	
	//	if (!success)
	//	{
	//		for (LevelMeter *thisMeter in _subLevelMeters) { thisMeter.level = 0.; [thisMeter setNeedsDisplay]; }
	//		printf("ERROR: metering failed\n");
	//	}
}

#pragma mark AudioSession listeners
void interruptionListener(	void *	inClientData,
							UInt32	inInterruptionState)
{
//	SpeakHereController *THIS = (SpeakHereController*)inClientData;
//	if (inInterruptionState == kAudioSessionBeginInterruption)
//	{
//		if (THIS->recorder->IsRunning()) {
//			[THIS stopRecord];
//		}
//		else if (THIS->player->IsRunning()) {
//			//the queue will stop itself on an interruption, we just need to update the AI
//			[[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueStopped" object:THIS];
//			THIS->playbackWasInterrupted = YES;
//		}
//	}
//	else if ((inInterruptionState == kAudioSessionEndInterruption) && THIS->playbackWasInterrupted)
//	{
//		printf("Resuming queue\n");
//		// we were playing back when we were interrupted, so reset and resume now
//		THIS->player->StartQueue(true);
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueResumed" object:THIS];
//		THIS->playbackWasInterrupted = NO;
//	}
}

void propListener(	void *                  inClientData,
					AudioSessionPropertyID	inID,
					UInt32                  inDataSize,
					const void *            inData)
{
//	SpeakHereController *THIS = (SpeakHereController*)inClientData;
//	if (inID == kAudioSessionProperty_AudioRouteChange)
//	{
//		CFDictionaryRef routeDictionary = (CFDictionaryRef)inData;			
//		//CFShow(routeDictionary);
//		CFNumberRef reason = (CFNumberRef)CFDictionaryGetValue(routeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
//		SInt32 reasonVal;
//		CFNumberGetValue(reason, kCFNumberSInt32Type, &reasonVal);
//		if (reasonVal != kAudioSessionRouteChangeReason_CategoryChange)
//		{
//			/*CFStringRef oldRoute = (CFStringRef)CFDictionaryGetValue(routeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_OldRoute));
//			if (oldRoute)	
//			{
//				printf("old route:\n");
//				CFShow(oldRoute);
//			}
//			else 
//				printf("ERROR GETTING OLD AUDIO ROUTE!\n");
//			
//			CFStringRef newRoute;
//			UInt32 size; size = sizeof(CFStringRef);
//			OSStatus error = AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &newRoute);
//			if (error) printf("ERROR GETTING NEW AUDIO ROUTE! %d\n", error);
//			else
//			{
//				printf("new route:\n");
//				CFShow(newRoute);
//			}*/
//
//			if (reasonVal == kAudioSessionRouteChangeReason_OldDeviceUnavailable)
//			{			
//				if (THIS->player->IsRunning()) {
//					[THIS stopPlayQueue];
//				}		
//			}
//
//			// stop the queue if we had a non-policy route change
//			if (THIS->recorder->IsRunning()) {
//				[THIS stopRecord];
//			}
//		}	
//	}
//	else if (inID == kAudioSessionProperty_AudioInputAvailable)
//	{
//		if (inDataSize == sizeof(UInt32)) {
//			UInt32 isAvailable = *(UInt32*)inData;
//			// disable recording if input is not available
//			THIS->btn_record.enabled = (isAvailable > 0) ? YES : NO;
//		}
//	}
}
				
#pragma mark Initialization routines
- (void)awakeFromNib
{		
	_channelNumbers = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:0], nil];
	_chan_lvls = (AudioQueueLevelMeterState*)malloc(sizeof(AudioQueueLevelMeterState) * [_channelNumbers count]);

	// Allocate our singleton instance for the recorder & player object
	recorder = new AQRecorder();
//	player = new AQPlayer();
		
	OSStatus error = AudioSessionInitialize(NULL, NULL, interruptionListener, self);
	if (error) {
		printf("ERROR INITIALIZING AUDIO SESSION! %d\n", error);
	} else {
	OSStatus error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, propListener, self);
		if (error) printf("ERROR ADDING AUDIO SESSION PROP LISTENER! %d\n", error);
		UInt32 inputAvailable = 0;
		UInt32 size = sizeof(inputAvailable);
		
		// we do not want to allow recording if input is not available
		error = AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable, &size, &inputAvailable);
		if (error) printf("ERROR GETTING INPUT AVAILABILITY! %d\n", error);
//		btn_record.enabled = (inputAvailable) ? YES : NO;
		
		// we also need to listen to see if input availability changes
		error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioInputAvailable, propListener, self);
		if (error) printf("ERROR ADDING AUDIO SESSION PROP LISTENER! %d\n", error);
	}
	
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackQueueStopped:) name:@"playbackQueueStopped" object:nil];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackQueueResumed:) name:@"playbackQueueResumed" object:nil];
//
//	UIColor *bgColor = [[UIColor alloc] initWithRed:.39 green:.44 blue:.57 alpha:.5];
//	[lvlMeter_in setBackgroundColor:bgColor];
//	[lvlMeter_in setBorderColor:bgColor];
//	[bgColor release];
	
	// disable the play button since we have no recording to play yet
//	btn_play.enabled = NO;
//	playbackWasInterrupted = NO;
}

# pragma mark Notification routines
//- (void)playbackQueueStopped:(NSNotification *)note
//{
//	btn_play.title = @"Play";
//	[lvlMeter_in setAq: nil];
//	btn_record.enabled = YES;
//}
//
//- (void)playbackQueueResumed:(NSNotification *)note
//{
//	btn_play.title = @"Stop";
//	btn_record.enabled = NO;
//	[lvlMeter_in setAq: player->Queue()];
//}

#pragma mark Cleanup
- (void)dealloc
{
//	[btn_record release];
//	[btn_play release];
//	[fileDescription release];
//	[lvlMeter_in release];
	
//	delete player;
	delete recorder;
	
	[super dealloc];
}


@end
