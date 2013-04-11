//
//  SleepTimerSettingsViewController.m
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 1/29/10.
//  Copyright 2010 The Byte Factory. All rights reserved.
//

#import "SleepTimerSettingsViewController.h"
#import "Constants.h"
#import "Sleep_Blaster_touchAppDelegate.h"
#import "SleepTimerController.h"
#import "CustomUISwitch.h"
#import "AlarmSettingsViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "EmptyViewController.h"

#define SLEEP_TIMER_LABEL_TAG 1000

@implementation SleepTimerSettingsViewController

@synthesize musicCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		
		self.title = @"Sleep Timer";
		
		UIImage* anImage = [UIImage imageNamed:@"hourGlassIcon.png"];
		UITabBarItem* theItem = [[UITabBarItem alloc] initWithTitle:@"Sleep Timer" image:anImage tag:0];
		self.tabBarItem = theItem;
		[theItem release];
		
	}
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	[SleepTimerController sharedSleepTimerController].interfaceDelegate = self;

	[self setButtonSegmentImages];
	
	volumeSlider.backgroundColor = [UIColor clearColor];  
	UIImage *stetchLeftTrack = [[UIImage imageNamed:@"blueTrack.png"] stretchableImageWithLeftCapWidth:4.0 topCapHeight:0.0];
	UIImage *stetchRightTrack = [[UIImage imageNamed:@"whiteTrack.png"] stretchableImageWithLeftCapWidth:4.0 topCapHeight:0.0];
	[volumeSlider setThumbImage: [UIImage imageNamed:@"whiteSlide.png"] forState:UIControlStateNormal];
	[volumeSlider setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
	[volumeSlider setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
	
	volumeSlider.value = [MPMusicPlayerController iPodMusicPlayer].volume;
	[self volumeSliderMoved:volumeSlider];
	
    musicTableView.rowHeight = 60;
    musicTableView.backgroundColor = [UIColor clearColor];
    timerTableView.rowHeight = 60;
    timerTableView.backgroundColor = [UIColor clearColor];
	
	// Initialize the datepicker
	datePicker.countDownDuration = [[[NSUserDefaults standardUserDefaults] objectForKey:kSleepTimerSeconds] intValue];
	CGRect datePickerContainerViewFrame = datePickerContainerView.frame;
	datePickerContainerViewFrame.origin.y = self.view.frame.size.height;
	datePickerContainerView.frame = datePickerContainerViewFrame;		
	[self.view addSubview:datePickerContainerView];	
	datePickerIsShowing = NO;
	
	secondsLeftOnTimer = 0;
	
//	[[NSNotificationCenter defaultCenter] addObserver:self 
//											 selector:@selector(nowPlayingItemChanged:)
//												 name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
//											   object:[MPMusicPlayerController applicationMusicPlayer]];	
//	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(userDefaultsChanged:)
												 name:NSUserDefaultsDidChangeNotification
											   object:[NSUserDefaults standardUserDefaults]];	
}

- (void)setButtonSegmentImages
{
	int value = [[[NSUserDefaults standardUserDefaults] objectForKey:kSleepTimerFunction] intValue];
	if (value == 0)
	{
		[((UIButton *)[self.view viewWithTag:LEFT_BUTTON_SEGMENT]) setBackgroundImage:[UIImage imageNamed:@"segmentedControlMusicSelected.png"] 
															   forState:UIControlStateNormal];
		[((UIButton *)[self.view viewWithTag:RIGHT_BUTTON_SEGMENT]) setBackgroundImage:[UIImage imageNamed:@"segmentedControlOceanWavesDeselected.png"] 
																forState:UIControlStateNormal];
		
	} else if (value == 1 ) {
		[((UIButton *)[self.view viewWithTag:LEFT_BUTTON_SEGMENT]) setBackgroundImage:[UIImage imageNamed:@"segmentedControlMusicDeselected.png"] 
															   forState:UIControlStateNormal];
		[((UIButton *)[self.view viewWithTag:RIGHT_BUTTON_SEGMENT]) setBackgroundImage:[UIImage imageNamed:@"segmentedControlOceanWavesSelected.png"] 
																forState:UIControlStateNormal];
	}
}

- (IBAction)buttonSegmentTapped:(UIButton *)sender
{	
	if (sender.tag == LEFT_BUTTON_SEGMENT) 
	{
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSleepTimerFunction] intValue] != 0)
		{
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] 
													  forKey:kSleepTimerFunction];
			
	//		[musicTableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
			NSArray *indexPaths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:1 inSection:0], [NSIndexPath indexPathForRow:2 inSection:0], nil];
			[timerTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
		}
	} else if (sender.tag == RIGHT_BUTTON_SEGMENT) 
	{
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSleepTimerFunction] intValue] != 1)
		{
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] 
													  forKey:kSleepTimerFunction];

		//	[musicTableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
			
			NSArray *indexPaths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:1 inSection:0], [NSIndexPath indexPathForRow:2 inSection:0], nil];
			[timerTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];

		}
	}	
	[self setButtonSegmentImages];
}

- (void)nowPlayingItemChanged:(NSNotification *)notification
{
	NSLog(@"now playing item changed!");
	[self setSongArtworkAndLabels];
}

- (void)userDefaultsChanged:(NSNotification *)notification
{		
	[self setTimerString];
}

- (IBAction)setSleepTimerTime:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[sender countDownDuration]] forKey:kSleepTimerSeconds];
}

- (IBAction)toggleSleepTimer:(id)sender
{
	if ([SleepTimerController sharedSleepTimerController].sleepTimerIsOn)
	{
		[self hideArtworkContainerView];
		[[NSNotificationCenter defaultCenter] removeObserver:self 
														name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification 
													  object:[MPMusicPlayerController applicationMusicPlayer]];
		[[SleepTimerController sharedSleepTimerController] stopSleepTimer:nil];
		
//		self.title = @"Sleep Timer";
	} else {
		[[MPMusicPlayerController applicationMusicPlayer] beginGeneratingPlaybackNotifications];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(nowPlayingItemChanged:)
													 name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
												   object:[MPMusicPlayerController applicationMusicPlayer]];	
		
		[[SleepTimerController sharedSleepTimerController] startSleepTimer];
		
		secondsLeftOnTimer = [[[NSUserDefaults standardUserDefaults] objectForKey:kSleepTimerSeconds] intValue];
		[self updateTimerLabel:nil];
		[NSTimer scheduledTimerWithTimeInterval:1.0 
										 target:self 
									   selector:@selector(updateTimerLabel:)
									   userInfo:nil repeats:YES];
//		self.title = @"Sleep Timer";
		
		[self setSongArtworkAndLabels];
		[self showArtworkContainerView];
	}
}

- (void)updateTimerLabel:(NSTimer *)theTimer
{
	if (![SleepTimerController sharedSleepTimerController].sleepTimerIsOn)
	{
		[theTimer invalidate];
	}
	
	int hours = floor(secondsLeftOnTimer/3600);
	int minutes = floor((secondsLeftOnTimer-(hours*3600))/60);
	int seconds = (secondsLeftOnTimer-(hours*3600)-(minutes*60));
	NSString *timeString = [NSString stringWithFormat:@"%d:%02d:%02d", hours, minutes, seconds];
	
	timerLabel.text = timeString;
	
	secondsLeftOnTimer--;
}
							
- (void)showArtworkContainerView
{
	
	CGRect artworkContainerViewFrame = artworkContainerView.frame;

	if (!artworkContainerView.superview)		// add the artwork container view as a subview, IF it hasn't been added already.
	{
		artworkContainerViewFrame.origin.y = self.view.frame.size.height;
		artworkContainerView.frame = artworkContainerViewFrame;		
		[self.view addSubview:artworkContainerView];	
	}
	
	artworkContainerViewFrame.origin.y = self.view.frame.size.height - artworkContainerViewFrame.size.height;
//	artworkContainerViewFrame.origin.y = 0.0;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	artworkContainerView.frame = artworkContainerViewFrame;
	[UIView commitAnimations];	
}

- (void)hideArtworkContainerView
{
	CGRect artworkContainerViewFrame = artworkContainerView.frame;
	artworkContainerViewFrame.origin.y = self.view.frame.size.height;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	//artworkContainerView.transform = CGAffineTransformMakeTranslation(0, (artworkContainerView.frame.size.height));
	artworkContainerView.frame = artworkContainerViewFrame;
	[UIView commitAnimations];
	//	[artworkContainerView removeFromSuperview];	
}

- (void)setSongArtworkAndLabels
{	
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSleepTimerFunction] intValue] == 0)
	{
		previousButton.hidden = NO;
		nextButton.hidden = NO;
		
		songLabel.text = [[MPMusicPlayerController applicationMusicPlayer].nowPlayingItem valueForProperty:MPMediaItemPropertyTitle];
		artistLabel.text = [[MPMusicPlayerController applicationMusicPlayer].nowPlayingItem valueForProperty:MPMediaItemPropertyArtist];
		
		UIImage *artwork = [[[MPMusicPlayerController applicationMusicPlayer].nowPlayingItem valueForProperty:MPMediaItemPropertyArtwork] imageWithSize:artworkImageView.frame.size];
		if (artwork) {
			artworkImageView.image = artwork;
		} else {
			artworkImageView.image = [UIImage imageNamed:@"NoArtwork.tif"];
		}
	} else if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSleepTimerFunction] intValue] == 1) {
		previousButton.hidden = YES;
		nextButton.hidden = YES;

		songLabel.text = @"";
		artistLabel.text = @"";
		artworkImageView.image = [UIImage imageNamed:@"NoArtwork.tif"];		
	}
}

- (IBAction) chooseMusic: (id) sender {    
	
	MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAnyAudio];
	
	picker.delegate = self;
	picker.allowsPickingMultipleItems = YES;
	picker.prompt = NSLocalizedString (@"Add songs to fall asleep to", "Prompt in media item picker");
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		picker.modalPresentationStyle = UIModalPresentationCurrentContext;
	}
	// The media item picker uses the default UI style, so it needs a default-style
	//		status bar to match it visually
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault animated: YES];
	

	[self.tabBarController presentModalViewController:picker animated:YES];
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
//		Sleep_Blaster_touchAppDelegate *mainDelegate = (Sleep_Blaster_touchAppDelegate *)[[UIApplication sharedApplication] delegate];
		CGSize size = {320, 480};
		self.contentSizeForViewInPopover = size;
	}
	[picker release];
}

// Responds to the user tapping Done after choosing music.
- (void) mediaPicker:(MPMediaPickerController *) mediaPicker 
   didPickMediaItems:(MPMediaItemCollection *) mediaItemCollection 
{

	[self.tabBarController dismissModalViewControllerAnimated:YES];

	Sleep_Blaster_touchAppDelegate *mainDelegate = (Sleep_Blaster_touchAppDelegate *)[[UIApplication sharedApplication] delegate];

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		CGSize size = {320, 480};		
		self.contentSizeForViewInPopover = size;
		size.height += 37;
		[mainDelegate.clockViewController.alarmPopoverController setPopoverContentSize:size];
		[mainDelegate.clockViewController.alarmPopoverController dismissPopoverAnimated:NO];
		[mainDelegate.clockViewController.alarmPopoverController presentPopoverFromRect:mainDelegate.clockViewController.rightSettingsButton.frame inView:mainDelegate.clockViewController.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
	}	
	// Save the alarm songs collection to the user defaults...
	
	NSData *sleepTimerSongsData = [NSKeyedArchiver archivedDataWithRootObject:mediaItemCollection];
	[[NSUserDefaults standardUserDefaults] setObject:sleepTimerSongsData forKey:kSleepTimerSongsCollection];

	mainDelegate.sleepTimerSongsCollection = mediaItemCollection;
	
/*	NSString *musicString;
	if ([mediaItemCollection.items count] > 1) {
		musicString = [NSString stringWithFormat:@"%d songs", [mediaItemCollection.items count]];
	} else {
		musicString = [[mediaItemCollection.items objectAtIndex:0] valueForProperty:MPMediaItemPropertyTitle];
	}
	
	[self.musicCell.textLabel setText:musicString];
*/
	[self setLabelInMusicCell];
	
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque animated:YES];
	
}

// Responds to the user tapping done having chosen no music.
- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker {
	
	[self.tabBarController dismissModalViewControllerAnimated:YES];
	

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		Sleep_Blaster_touchAppDelegate *mainDelegate = (Sleep_Blaster_touchAppDelegate *)[[UIApplication sharedApplication] delegate];
		CGSize size = {320, 480};		
		self.contentSizeForViewInPopover = size;
		size.height += 37;
		[mainDelegate.clockViewController.alarmPopoverController setPopoverContentSize:size];
		[mainDelegate.clockViewController.alarmPopoverController dismissPopoverAnimated:NO];
		[mainDelegate.clockViewController.alarmPopoverController presentPopoverFromRect:mainDelegate.clockViewController.rightSettingsButton.frame inView:mainDelegate.clockViewController.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
	}
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque animated:YES];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

- (void)viewWillAppear:(BOOL)animated
{

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		CGSize size = {320, 480};
		self.contentSizeForViewInPopover = size;
	}
//	size.height += (37+44);		// For some reason, only here, we have to add 37 pixels to the height. It has something to do with the navigation controller.
//	Sleep_Blaster_touchAppDelegate *mainDelegate = (Sleep_Blaster_touchAppDelegate *)[[UIApplication sharedApplication] delegate];
//	[mainDelegate.clockViewController.alarmPopoverController setPopoverContentSize:size];
	
}

- (void)dealloc {
    [super dealloc];
}

- (void)switchFlipped:(UISwitch *)sender
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[sender isOn]] forKey:kSleepTimerMusicShuffle];
}

- (IBAction)doneButtonTapped:(id)sender
{
	Sleep_Blaster_touchAppDelegate *mainDelegate = (Sleep_Blaster_touchAppDelegate *)[[UIApplication sharedApplication] delegate];
	[mainDelegate flipToClockView:sender];
}

- (void)setLabelInMusicCell
{
	Sleep_Blaster_touchAppDelegate *mainDelegate = (Sleep_Blaster_touchAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSString *musicString = nil;
	
	if (mainDelegate.hasLoadedSleepTimerSongsCollection)		// if it's finished loading (whether there's any song data or not)...
	{
		if (!mainDelegate.sleepTimerSongsCollection) {
			musicString = @"Select songs";
		} else if (mainDelegate.sleepTimerSongsCollection.count > 1) {
			musicString = [NSString stringWithFormat:@"%d songs", mainDelegate.sleepTimerSongsCollection.items.count];
		} else if (mainDelegate.sleepTimerSongsCollection.count == 1) {
			musicString = [[mainDelegate.sleepTimerSongsCollection.items objectAtIndex:0] valueForProperty:MPMediaItemPropertyTitle];
		}
		[self.musicCell.textLabel setText:musicString];
	} else {		// otherwise, it hasn't finished loading yet.
		musicCell.textLabel.text = @"Loading songs...";
	}
}

- (void)setTimerString
{
	NSLog(@"setting timer string");
	
	int hours = floor([[[NSUserDefaults standardUserDefaults] objectForKey:kSleepTimerSeconds] intValue]/3600);
	int minutes = floor(([[[NSUserDefaults standardUserDefaults] objectForKey:kSleepTimerSeconds] intValue]-(hours*3600))/60);
	NSString *timerString = [NSString stringWithFormat:@"%dhr %dmin", hours, minutes];

//	int hoursTensDigit = floor(hours/10);
//	int hoursOnesDigit = hours-(hoursTensDigit*10);
//	int minutesTensDigit = floor(minutes/10);
//	int minutesOnesDigit = minutes-(minutesTensDigit*10);
	
	
	ShadowedLabel *blueLabel = (ShadowedLabel *)[self.view viewWithTag:SLEEP_TIMER_LABEL_TAG];
	blueLabel.text = timerString;
	
//	hourLabel1.text = hoursTensDigit > 0 ? [NSString stringWithFormat:@"%d", hoursTensDigit] : @"";
//	hourLabel2.text = [NSString stringWithFormat:@"%d", hoursOnesDigit];
//	minuteLabel1.text = [NSString stringWithFormat:@"%d", minutesTensDigit];
//	minuteLabel2.text = [NSString stringWithFormat:@"%d", minutesOnesDigit];
}


- (IBAction)toggleDatePicker:(id)sender
{ 
	CGRect frame = datePickerContainerView.frame;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];

	if (datePickerIsShowing)
	{
		frame.origin.y = self.view.frame.size.height;

	//	datePickerContainerView.transform = CGAffineTransformMakeTranslation(0, datePickerContainerView.frame.size.height+69);
		datePickerIsShowing = NO;
	} else {
		frame.origin.y = self.view.frame.size.height - frame.size.height;
		//datePickerContainerView.transform = CGAffineTransformMakeTranslation(0, -(datePickerContainerView.frame.size.height+69)); // Offset.
		datePickerIsShowing = YES;
	}
	
	datePickerContainerView.frame = frame;

	[UIView commitAnimations];
}

- (IBAction)previousSong:(id)sender
{
	[[MPMusicPlayerController applicationMusicPlayer] skipToPreviousItem];
}


- (IBAction)nextSong:(UISlider *)sender
{
	[[MPMusicPlayerController applicationMusicPlayer] skipToNextItem];
}

- (IBAction)volumeSliderMoved:(UISlider *)sender
{
	[SleepTimerController sharedSleepTimerController].volume = sender.value;
}

#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//	if (tableView == musicTableView) {
//		if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSleepTimerFunction] intValue] == 0) 
//		{
//			return 1;
//		} else {
//			return 0;
//		}
//	} else if (tableView == timerTableView) {
		return 1;
//	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSleepTimerFunction] intValue] == 0) {
		return 3;
	} else {
		return 1;
	}
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	cell.opaque = NO;
	cell.backgroundColor = [UIColor clearColor];
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  
{
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero] autorelease];
	
	cell.textLabel.backgroundColor = [UIColor clearColor];
	cell.textLabel.textColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];
	cell.textLabel.highlightedTextColor = [UIColor colorWithRed:.1 green:.1 blue:.1 alpha:1.0];
	cell.textLabel.shadowColor = [UIColor whiteColor];
	cell.textLabel.shadowOffset = CGSizeMake(0, 1);

//	if (theTableView == musicTableView) {
	switch ([indexPath row]) {
		case 0:		// this is for the music picker.
			
			[cell.textLabel setText:@"Timer"];
			
			UIImage *blackScreen = [UIImage imageNamed:@"blackScreen.png"];
			UIImageView *lcdImageView = [[UIImageView alloc] initWithFrame:CGRectMake(195.0, timerTableView.rowHeight/2-blackScreen.size.height/2, blackScreen.size.width, blackScreen.size.height)];
			[lcdImageView setImage:blackScreen];
			[cell.contentView addSubview:lcdImageView];			
			
//			hourLabel1 = [AlarmSettingsViewController createDigitLabel];
//			hourLabel1.frame = CGRectMake(6.0, 0.0, 10.0, 34.0);
//			[lcdImageView addSubview:hourLabel1];		
//			
//			hourLabel2 = [AlarmSettingsViewController createDigitLabel];
//			hourLabel2.frame = CGRectMake(15.0, 0.0, 10.0, 34.0);
//			[lcdImageView addSubview:hourLabel2];
//			
//			minuteLabel1 = [AlarmSettingsViewController createDigitLabel];
//			minuteLabel1.frame = CGRectMake(56.0, 0.0, 10.0, 34.0);
//			[lcdImageView addSubview:minuteLabel1];
//			
//			minuteLabel2 = [AlarmSettingsViewController createDigitLabel];
//			minuteLabel2.frame = CGRectMake(65.0, 0.0, 10.0, 34.0);
//			[lcdImageView addSubview:minuteLabel2];
//			
//			ShadowedLabel *hrLabel = [AlarmSettingsViewController createDigitLabel];
//			hrLabel.frame = CGRectMake(27.0, 0.0, 23.0, 34.0);
//			hrLabel.textAlignment = UITextAlignmentCenter;
//			hrLabel.text = @"hr";
//			[lcdImageView addSubview:hrLabel];
//			
//			ShadowedLabel *minLabel = [AlarmSettingsViewController createDigitLabel];
//			minLabel.frame = CGRectMake(77.0, 0.0, 27.0, 34.0);
//			minLabel.textAlignment = UITextAlignmentCenter;
//			minLabel.text = @"min";
//			[lcdImageView addSubview:minLabel];
//			
//			[self setTimerDigitLabels];
			
			ShadowedLabel *blueLabel = [[ShadowedLabel alloc] initWithFrame:CGRectMake(lcdImageView.frame.origin.x+lcdImageView.frame.size.width/2-100.0/2, (timerTableView.rowHeight/2)-(27.0/2), 100.0, 27.0)];
			blueLabel.textAlignment = UITextAlignmentCenter;
			blueLabel.font = [UIFont boldSystemFontOfSize:12.0];
			blueLabel.textColor = [UIColor colorWithRed:.72 green:.91 blue:1.0 alpha:1.0];
			blueLabel.shadowColor = [UIColor colorWithRed:0.0 green:.52 blue:1.0 alpha:.9];
			blueLabel.shadowBlur = 10.0;
			blueLabel.backgroundColor = [UIColor clearColor];
//			[blueLabel setText:[[[NSUserDefaults standardUserDefaults] objectForKey:kSleepTimerSeconds] stringValue]];
			blueLabel.tag = SLEEP_TIMER_LABEL_TAG;
			
			int hours = floor([[[NSUserDefaults standardUserDefaults] objectForKey:kSleepTimerSeconds] intValue]/3600);
			int minutes = floor(([[[NSUserDefaults standardUserDefaults] objectForKey:kSleepTimerSeconds] intValue]-(hours*3600))/60);
			NSString *timerString = [NSString stringWithFormat:@"%dhr %dmin", hours, minutes];
			blueLabel.text = timerString;
			
			[cell.contentView addSubview:blueLabel];
			
	//		[blueLabel release];
			
	//		[self setTimerString];

			break;
			
		case 1:		// this is for the music picker.
			self.musicCell = cell;
			
			[self setLabelInMusicCell];
			//[NSThread detachNewThreadSelector:@selector(setLabelInMusicCell) toTarget:self withObject:nil];
			
			UIImage *disclosure = [UIImage imageNamed:@"disclosure-iPad.png"];
			UIImageView *disclosureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(250.0, timerTableView.rowHeight/2-disclosure.size.height/2, disclosure.size.width, disclosure.size.height)];
			[disclosureImageView setImage:disclosure];
			[disclosureImageView setOpaque:NO];
			[cell.contentView addSubview:disclosureImageView];
			
			break;
			
		case 2:		// this is for the "shuffle switch.
			[cell.textLabel setText:@"Shuffle"];
			
			CustomUISwitch *shuffleSwitch = [AlarmSettingsViewController createSwitch];
			CGRect frame = shuffleSwitch.frame;
			frame.origin.y = timerTableView.rowHeight/2-frame.size.height/2;
			shuffleSwitch.frame = frame;
			
			[shuffleSwitch addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
			[shuffleSwitch setOn:[[[NSUserDefaults standardUserDefaults] objectForKey:kSleepTimerMusicShuffle] boolValue] animated:YES];
			
			[cell.contentView addSubview:shuffleSwitch];
			
			break;
		default:
			break;
	}
		
		UIImage *rowBackground;
		UIImage *selectionBackground;
		NSInteger row = [indexPath row];
		
//		NSString *backgroundImageName = [NSString stringWithFormat:@"section2Row%d.png", row];
//		NSString *selectedBackgroundImageName = [NSString stringWithFormat:@"section2Row%dSelected.png", row];
		
		if (row == 0)
		{		
			rowBackground = [UIImage imageNamed:@"lightRowTop.png"];
			selectionBackground = [UIImage imageNamed:@"lightRowTop.png"];
		} else {
			rowBackground = [UIImage imageNamed:@"lightRow.png"];
			selectionBackground = [UIImage imageNamed:@"lightRow.png"];
		}
	
//		rowBackground = [UIImage imageNamed:backgroundImageName];
//		selectionBackground = [UIImage imageNamed:selectedBackgroundImageName];
		
		UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
		UIImageView *selectedBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
		backgroundImageView.image = rowBackground;
		selectedBackgroundImageView.image = selectionBackground;
		
		[cell setBackgroundView:backgroundImageView];
		[cell setSelectedBackgroundView:selectedBackgroundImageView];
		
//	} else if (theTableView == timerTableView) {
//		[cell.textLabel setText:@"Timer"];
//		
//		UIImage *lcd = [UIImage imageNamed:@"sleepTimerMiniLCD.png"];
//		UIImageView *lcdImageView = [[UIImageView alloc] initWithFrame:CGRectMake(180.0, 6.0, lcd.size.width, lcd.size.height)];
//		[lcdImageView setImage:lcd];
//		[lcdImageView setOpaque:NO];
//				
//		hourLabel1 = [AlarmSettingsViewController createDigitLabel];
//		hourLabel1.frame = CGRectMake(6.0, 0.0, 10.0, 34.0);
//		[lcdImageView addSubview:hourLabel1];		
//
//		hourLabel2 = [AlarmSettingsViewController createDigitLabel];
//		hourLabel2.frame = CGRectMake(15.0, 0.0, 10.0, 34.0);
//		[lcdImageView addSubview:hourLabel2];
//
//		minuteLabel1 = [AlarmSettingsViewController createDigitLabel];
//		minuteLabel1.frame = CGRectMake(56.0, 0.0, 10.0, 34.0);
//		[lcdImageView addSubview:minuteLabel1];
//
//		minuteLabel2 = [AlarmSettingsViewController createDigitLabel];
//		minuteLabel2.frame = CGRectMake(65.0, 0.0, 10.0, 34.0);
//		[lcdImageView addSubview:minuteLabel2];
//		
//		ShadowedLabel *hrLabel = [AlarmSettingsViewController createDigitLabel];
//		hrLabel.frame = CGRectMake(27.0, 0.0, 23.0, 34.0);
//		hrLabel.textAlignment = UITextAlignmentCenter;
//		hrLabel.text = @"hr";
//		[lcdImageView addSubview:hrLabel];
//
//		ShadowedLabel *minLabel = [AlarmSettingsViewController createDigitLabel];
//		minLabel.frame = CGRectMake(77.0, 0.0, 27.0, 34.0);
//		minLabel.textAlignment = UITextAlignmentCenter;
//		minLabel.text = @"min";
//		[lcdImageView addSubview:minLabel];
//		
//		[self setTimerDigitLabels];
//		
//		[cell.contentView addSubview:lcdImageView];
//	
//		UIImage *rowBackground;
//		UIImage *selectionBackground;
//		
////		NSString *backgroundImageName = @"sleepTimerTableView.png";
////		NSString *selectedBackgroundImageName = @"sleepTimerTableViewSelected.png";
//		
////		rowBackground = [UIImage imageNamed:backgroundImageName];
////		selectionBackground = [UIImage imageNamed:selectedBackgroundImageName];
//		rowBackground = [UIImage imageNamed:@"lightRow.png"];
//		selectionBackground = [UIImage imageNamed:@"lightRow.png"];
//				
//		UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
//		UIImageView *selectedBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
//		backgroundImageView.image = rowBackground;
//		selectedBackgroundImageView.image = selectionBackground;
//		
//		[cell setBackgroundView:backgroundImageView];
//		[cell setSelectedBackgroundView:selectedBackgroundImageView];
//	}
	
	return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSIndexPath *)tableView:(UITableView *)aTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//	if (aTableView == musicTableView) {
		if (indexPath.row == 0) {
			[self toggleDatePicker:self];
		} else if (indexPath.row == 1) {
			// "Music" button tapped; bring up the music picker.
			[self chooseMusic:self];
		}
//	} else if (aTableView == timerTableView) {
//	}
    return indexPath;
}

@end
