//
//  AlarmRingingViewController.m
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 8/15/09.
//  Copyright 2009 The Byte Factory. All rights reserved.
//

#import "AlarmRingingViewController.h"
#import "AlarmController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "Constants.h"

@implementation AlarmRingingViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[UIApplication sharedApplication].statusBarHidden = YES;
	
	// Set the time on the clock thing and set it up to update itself.
	if (!clockTimer) {
		NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
		if ([[[NSCalendar currentCalendar] locale] timeIs24HourFormat])
		{
			[dateFormatter setDateFormat:@"HH:mm:ss"];
		} else {
			[dateFormatter setDateFormat:@"h:mma"];
		}
		NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];

		[self setSongTextAndAlbumArtwork:nil];
		[currentTimeField setText:currentTime];
		clockTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self
													selector:@selector(updateCurrentTimeField:)
													userInfo:nil repeats:YES];
		
		[[MPMusicPlayerController applicationMusicPlayer] beginGeneratingPlaybackNotifications];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(setSongTextAndAlbumArtwork:)
													 name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
												   object:[MPMusicPlayerController applicationMusicPlayer]];	
		
	}
}
	
- (void)setSongTextAndAlbumArtwork:(NSNotification *)theNotification
{
	songLabel.text = [[MPMusicPlayerController applicationMusicPlayer].nowPlayingItem valueForProperty:MPMediaItemPropertyTitle];
	artistLabel.text = [[MPMusicPlayerController applicationMusicPlayer].nowPlayingItem valueForProperty:MPMediaItemPropertyArtist];
	
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:kEnableDynamiteMode] boolValue])
	{
		artworkImageView.image = [UIImage imageNamed:@"dynamite.png"];
	} else {
		UIImage *artwork = [[[MPMusicPlayerController applicationMusicPlayer].nowPlayingItem valueForProperty:MPMediaItemPropertyArtwork] imageWithSize:artworkImageView.frame.size];
		if (artwork) {
			artworkImageView.image = artwork;
//			NSLog(@"there's artwork!");
		} else {
			artworkImageView.image = [UIImage imageNamed:@"NoArtwork.tif"];
//			NSLog(@"it can't find the artwork!");
		}
	}
}

- (void)updateCurrentTimeField:(NSTimer *)timer {
	// Make a string with the current time.
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"h:mma"];
	NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];

	if (![[currentTimeField text] isEqualToString:currentTime]) {
		[currentTimeField setText:currentTime];
		//NSLog(@"updated clock.");
	}
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (IBAction)offButtonTapped:(id)sender
{
	[[AlarmController sharedAlarmController] stopAlarm:self];
}

- (IBAction)snoozeButtonTapped:(id)sender
{
	[[AlarmController sharedAlarmController] snoozeAlarm:self];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	[UIApplication sharedApplication].statusBarHidden = NO;
}


- (void)dealloc {
    [super dealloc];
}


@end
