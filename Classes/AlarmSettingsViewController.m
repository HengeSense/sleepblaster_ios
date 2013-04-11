//
//  SecondViewController.m
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 6/14/09.
//  Copyright 2009 The Byte Factory. All rights reserved.
//

#import "AlarmController.h"
#import "AlarmSettingsViewController.h"
#import "Constants.h"
#import "Sleep_Blaster_touchAppDelegate.h"
#import "VoiceSettingsViewController.h"
#import "BlackSegmentedControl.h"
#import <AudioToolbox/AudioToolbox.h>
#import "NSLocale+Misc.h"
#import "ShadowedLabel.h"

#define kViewTag				1		// for tagging our embedded controls for removal at cell recycle time
#define kAlarmSwitch 101
#define kVoiceSwitch 102
#define kShuffleSwitch 103
#define kDynamiteSwitch 104
#define kShowMapCell 105
#define kAlarmModeSegmentedControl 105
#define VC_OFFINDICATORIMAGE_TAG 1000
#define VC_ONINDICATORIMAGE_TAG 1001
#define SNOOZE_TIME_LABEL_TAG 1002
#define ALARM_TIME_LABEL_TAG 1003
#define DYNAMITE_CELL 1004
#define WEIRD_HEIGHT_OFFSET_FOR_SOME_REASON 37

//static int kModeSectionIndex = 0;
//static int kAlarmSettingsSectionIndex = 1;
//static int kMusicSettingsSectionIndex = 2;

@implementation AlarmSettingsViewController

BOOL keypadIsShowing = NO;
BOOL indicatorLightWasOn = NO;

@synthesize musicCell;
@synthesize keypadViewController;
@synthesize tableView;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		
		self.title = @"Alarm Clock";
		
		UIImage* anImage = [UIImage imageNamed:@"clockIcon.png"];
		UITabBarItem* theItem = [[UITabBarItem alloc] initWithTitle:@"Alarm Clock" image:anImage tag:0];
		self.tabBarItem = theItem;
		[theItem release];
	}
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
//	CGSize size = {320, 540};
//	size.height += 37;		// For some reason, only here, we have to add 37 pixels to the height. It has something to do with the navigation controller.
//	Sleep_Blaster_touchAppDelegate *mainDelegate = (Sleep_Blaster_touchAppDelegate *)[[UIApplication sharedApplication] delegate];
//	[mainDelegate.clockViewController.alarmPopoverController setPopoverContentSize:size];
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(timeZoneDidChange:) 
												 name:NSSystemTimeZoneDidChangeNotification 
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(userDefaultsChanged:)
												 name:NSUserDefaultsDidChangeNotification
											   object:[NSUserDefaults standardUserDefaults]];
	
		
	
//	[AlarmController sharedAlarmController].alarmInterfaceDelegate = self;	
	
	//
    // Change the properties of the imageView and tableView (these could be set
    // in interface builder instead).
    //
	    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

//	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//	{
//		tableView.rowHeight = 60;
/*	} else {
		tableView.rowHeight = 50;
	}*/
    tableView.backgroundColor = [UIColor clearColor];
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		// The device is an iPad running iPhone 3.2 or later.
		[tableView setBackgroundView:nil];
		[tableView setBackgroundView:[[[UIView alloc] init] autorelease]];
	}	

	
	// Initialize the datepicker

	[alarmDatePicker setDate:[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmDate] animated:NO];
	CGRect alarmDatePickerContainerViewFrame = alarmDatePickerContainerView.frame;
	alarmDatePickerContainerViewFrame.origin.y = self.view.frame.size.height;
	alarmDatePickerContainerView.frame = alarmDatePickerContainerViewFrame;		
	[self.view addSubview:alarmDatePickerContainerView];
	
	datePickerIsShowing = NO;
	alarmDatePickerContainerView.hidden = YES;
	navigationBar.barStyle = UIBarStyleBlack;
	navigationBar.translucent = YES;
	
//	self.contentSizeForViewInPopover = [self requiredSizeForTableView];
}


- (void)timeZoneDidChange:(id)notification
{
	alarmDatePicker.timeZone = [NSTimeZone defaultTimeZone];
	[self setWakeupTimeLabel];
}

- (IBAction)toggleDatePicker:(id)sender
{ 
// 	Sleep_Blaster_touchAppDelegate *mainDelegate = (Sleep_Blaster_touchAppDelegate *)[[UIApplication sharedApplication] delegate];
//	CGSize size = mainDelegate.alarmSettingsNavigationController.view.frame.size;
	
	if (datePickerIsShowing)
	{
		CGRect originalFrame = alarmDatePickerContainerView.frame;
		CGRect newFrame = originalFrame;
		newFrame.origin.y = self.view.frame.size.height;
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
//		alarmDatePickerContainerView.transform = CGAffineTransformMakeTranslation(0, alarmDatePickerContainerView.frame.size.height+69);
		alarmDatePickerContainerView.frame = newFrame;
		[UIView commitAnimations];
		
		datePickerIsShowing = NO;
	} else {

		alarmDatePickerContainerView.hidden = NO;

		NSDate *alarmDate = [[AlarmController sharedAlarmController] dateAlarmWillGoOff];
		int hoursUntilWakeup = floor([alarmDate timeIntervalSinceNow]/3600);
		int minutesUntilWakeup = floor(([alarmDate timeIntervalSinceNow]-hoursUntilWakeup*3600)/60);
		NSString *amountOfTimeString = [NSString stringWithFormat:@"In %d hours and %d minutes", hoursUntilWakeup, minutesUntilWakeup];
		amountOfTimeLabel.text = amountOfTimeString;
		
//		alarmDatePicker.timeZone = [NSTimeZone localTimeZone];
//		NSLog([[NSTimeZone localTimeZone] description]);
		alarmDatePicker.date = alarmDate;

		CGRect originalFrame = alarmDatePickerContainerView.frame;
		CGRect newFrame = originalFrame;
		newFrame.origin.y = self.view.frame.size.height - originalFrame.size.height;
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
//		alarmDatePickerContainerView.transform = CGAffineTransformMakeTranslation(0, -(alarmDatePickerContainerView.frame.size.height+69));
		alarmDatePickerContainerView.frame = newFrame;
		[UIView commitAnimations];
		
		datePickerIsShowing = YES;
	}
}

- (IBAction)setAlarmDateInDatePicker:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setObject:[sender date] forKey:kAlarmDate];
	[[AlarmController sharedAlarmController] setupAlarm:self];
	
/*	NSDate *alarmDate = [[AlarmController sharedAlarmController] dateAlarmWillGoOff];
	int hoursUntilWakeup = floor([alarmDate timeIntervalSinceNow]/3600);
	int minutesUntilWakeup = floor(([alarmDate timeIntervalSinceNow]-hoursUntilWakeup*3600)/60);
	NSString *amountOfTimeString = [NSString stringWithFormat:@"In %d hours and %d minutes", hoursUntilWakeup, minutesUntilWakeup];
	amountOfTimeLabel.text = amountOfTimeString;
*/
	[self setWakeupTimeLabel];
}

- (void)setWakeupTimeLabel
{
	NSDate *alarmDate = [[AlarmController sharedAlarmController] dateAlarmWillGoOff];
	int hoursUntilWakeup = floor([alarmDate timeIntervalSinceNow]/3600);
	int minutesUntilWakeup = floor(([alarmDate timeIntervalSinceNow]-hoursUntilWakeup*3600)/60);
	NSString *amountOfTimeString = [NSString stringWithFormat:@"In %d hours and %d minutes", hoursUntilWakeup, minutesUntilWakeup];
	amountOfTimeLabel.text = amountOfTimeString;
}	
	

/*- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		[self.tabBarController dismissModalViewControllerAnimated:YES];
		Sleep_Blaster_touchAppDelegate *mainDelegate = (Sleep_Blaster_touchAppDelegate *)[[UIApplication sharedApplication] delegate];
		
		CGSize size = {320, 480};
		self.contentSizeForViewInPopover = size;
		size.height += 37;
		[mainDelegate.clockViewController.alarmPopoverController setPopoverContentSize:size];
		[mainDelegate.clockViewController.alarmPopoverController dismissPopoverAnimated:NO];
		[mainDelegate.clockViewController.alarmPopoverController presentPopoverFromRect:mainDelegate.clockViewController.rightSettingsButton.frame inView:mainDelegate.clockViewController.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
		
	}
}
*/
- (IBAction) chooseMusic: (id) sender {    

	MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAnyAudio];
	
	picker.delegate = self;
	picker.allowsPickingMultipleItems = YES;
	picker.prompt = NSLocalizedString (@"Add songs to wake up to", "Prompt in media item picker");
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
		CGSize size = {320, 480};
		self.contentSizeForViewInPopover = size;
	}
	
	[picker release];
}

// Responds to the user tapping Done after choosing music.
- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection 
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
	NSData *alarmSongsData = [NSKeyedArchiver archivedDataWithRootObject:mediaItemCollection];
	[[NSUserDefaults standardUserDefaults] setObject:alarmSongsData forKey:kAlarmSongsCollection];

	mainDelegate.alarmSongsCollection = mediaItemCollection;

	[self setLabelInMusicCell];
	
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque animated:YES];
}

// Responds to the user tapping done having chosen no music.
- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker {
	
	[self.tabBarController dismissModalViewControllerAnimated: YES];
	
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
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque animated:YES];
}

- (void)switchFlipped:(UISwitch *)sender
{
	switch (sender.tag) {
		case kAlarmSwitch:
		{	
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[sender isOn]] forKey:kAlarmOn];
			[[AlarmController sharedAlarmController] setupAlarm:self];
			
			break;
		}	
		case kShuffleSwitch:
		{
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[sender isOn]] forKey:kAlarmMusicShuffle];
			break;
		}	
		case kVoiceSwitch:
		{
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[sender isOn]] forKey:kEnableVoiceControls];
			break;
		}
		case kDynamiteSwitch:
		{
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[sender isOn]] forKey:kEnableDynamiteMode];
			// Hide/show the music settings section, depending on whether Dynamite Mode was turned on or off.
	
			UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
			UIImageView *selectedBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];

			if ([sender isOn]) {
				//[tableView deleteSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
				
				NSArray *indexPaths = [NSArray arrayWithObjects:
										[NSIndexPath indexPathForRow:7 inSection:0], 
										[NSIndexPath indexPathForRow:8 inSection:0], 
										[NSIndexPath indexPathForRow:9 inSection:0], 
										nil];
				[tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];				
				
			} else {
				//[tableView insertSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
				
				NSArray *indexPaths = [NSArray arrayWithObjects:
										[NSIndexPath indexPathForRow:7 inSection:0], 
										[NSIndexPath indexPathForRow:8 inSection:0], 
										[NSIndexPath indexPathForRow:9 inSection:0], 
										nil];
				[tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
			
				backgroundImageView.image = [UIImage imageNamed:@"lightRow.png"];
				selectedBackgroundImageView.image = [UIImage imageNamed:@"lightRow.png"];
				
				[tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:9 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];

			}
		
			UITableViewCell *dynamiteCell = (UITableViewCell *)[self.view viewWithTag:DYNAMITE_CELL];
			dynamiteCell.backgroundView = backgroundImageView;
			dynamiteCell.selectedBackgroundView = selectedBackgroundImageView;
			

			
			
	//		[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:6 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
	//		[tableView reloadData];
			
			break;
		}
		default:
			break;
	}
}

/*- (CGSize)requiredSizeForTableView
{
	CGSize size = tableView.frame.size;
	int sections = [self numberOfSectionsInTableView:tableView];
	int totalRows = 0;
	for (int i = 0; i < sections; i++)
	{
		totalRows += [self tableView:tableView numberOfRowsInSection:i];
	}
	
	size.height = tableView.rowHeight*(totalRows+sections-1);
	NSLog(@"should now be %f", size.height);
	return size;
	
//	self.contentSizeForViewInPopover = rect.size;	
}*/

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
//	CGRect viewFrame = self.view.frame;
//	viewFrame.origin.y = 100.0;
//	self.view.frame = viewFrame;
	[tableView reloadData];

//	CGSize size = {320, 480};
	//Sleep_Blaster_touchAppDelegate *mainDelegate = (Sleep_Blaster_touchAppDelegate *)[[UIApplication sharedApplication] delegate];
	//CGSize size = ((AlarmSettingsViewController *)[mainDelegate.alarmSettingsNavigationController.viewControllers objectAtIndex:0]).view.frame.size;

//	self.contentSizeForViewInPopover = [self requiredSizeForTableView];
//	Sleep_Blaster_touchAppDelegate *mainDelegate = (Sleep_Blaster_touchAppDelegate *)[[UIApplication sharedApplication] delegate];
//	mainDelegate.clockViewController.alarmPopoverController.popoverContentSize = self.view.frame.size;
//	self.contentSizeForViewInPopover = self.view.frame.size;
	
	[super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	if (keypadViewController)
	{
		if (keypadIsShowing)
		{
			// Get ready to move the keypadView out of visibility.
			CGRect keypadViewFrame = keypadViewController.view.frame;
			keypadViewFrame.origin.y += (KEYPAD_HEIGHT_MINUS_SHADOW + BOTTOMBAR_HEIGHT);
			
			// Get ready to move the main view back down to fill the screen again.
			CGRect mainViewFrame = self.view.frame;
			mainViewFrame.origin.y += (KEYPAD_HEIGHT_MINUS_SHADOW - 60);
			
			self.view.frame = mainViewFrame;
			keypadViewController.view.frame = keypadViewFrame;
			[keypadViewController.view removeFromSuperview];			
			
			
			keypadIsShowing = NO;		
		}
	}
}

- (void)dealloc {
    [super dealloc];
}

- (void)setLabelInMusicCell
{
	Sleep_Blaster_touchAppDelegate *mainDelegate = (Sleep_Blaster_touchAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSString *musicString = nil;

	if (mainDelegate.hasLoadedAlarmSongsCollection)		// if it's finished loading (whether there's any song data or not)...
	{
		if (!mainDelegate.alarmSongsCollection) {
			musicString = @"Select songs";
		} else if (mainDelegate.alarmSongsCollection.count > 1) {
				musicString = [NSString stringWithFormat:@"%d songs", mainDelegate.alarmSongsCollection.items.count];
		} else if (mainDelegate.alarmSongsCollection.count == 1) {
				musicString = [[mainDelegate.alarmSongsCollection.items objectAtIndex:0] valueForProperty:MPMediaItemPropertyTitle];
		}
		[self.musicCell.textLabel setText:musicString];
	} else {		// otherwise, it hasn't finished loading yet.
		musicCell.textLabel.text = @"Loading songs...";
	}
}

+ (CustomUISwitch *)createSwitch
{
	CGRect frame = CGRectMake(198.0, 9.0, 84.0, 27.0);
	CustomUISwitch *theSwitch;
	
//	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//	{
//		// The device is an iPad running iPhone 3.2 or later.
		theSwitch = [[[CustomUISwitch alloc] initWithFrame:frame lighter:YES] autorelease];
//	} else {
//		theSwitch = [[[CustomUISwitch alloc] initWithFrame:frame lighter:NO] autorelease];
//	}
	
	// in case the parent view draws with a custom color or gradient, use a transparent color
	theSwitch.backgroundColor = [UIColor clearColor];
	
//	[theSwitch setAccessibilityLabel:NSLocalizedString(@"StandardSwitch", @"")];
	
	theSwitch.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
    return theSwitch;
}

+ (UILabel *)createLabel
{
	CGRect frame = CGRectMake(198.0, 9.0, 94.0, 26.0);
	UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
	label.backgroundColor = [UIColor clearColor];
	label.textAlignment = UITextAlignmentRight;
//	label.highlightedTextColor = [UIColor whiteColor];
	label.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
	label.textColor = [UIColor colorWithRed:0.243 green:0.306 blue:0.435 alpha:1.0];

	label.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
    return label;
}

+ (ShadowedLabel *)createDigitLabel
{
	ShadowedLabel *label = [[[ShadowedLabel alloc] initWithFrame:CGRectZero] autorelease];
	[label setShadowBlur:.1];		// can't set the shadow blur to 0.0, because then it will show up as !shadowBlur and will default to 5.0.
	label.textAlignment = UITextAlignmentRight;
	label.font = [UIFont fontWithName:@"Digital-7" size:20.0];
	label.textColor = [UIColor colorWithRed:.40 green:.85 blue:1 alpha:1];
	label.backgroundColor = [UIColor clearColor];
	
	return label;
}

- (void)setAlarmDigitLabels
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	if ([[[NSCalendar currentCalendar] locale] timeIs24HourFormat])
	{
		[dateFormatter setDateFormat:@"HH:mm"];
	} else {
		[dateFormatter setDateFormat:@"h:mm a"];
	}
	NSString *currentTime = [dateFormatter stringFromDate:[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmDate]];
	
	UILabel *alarmTimeLabel = (UILabel *)[self.view viewWithTag:ALARM_TIME_LABEL_TAG];
	alarmTimeLabel.text = currentTime;
}

- (void)userDefaultsChanged:(NSNotification *)notification
{
//	NSLog(@"defaults changed!");
	
	[self setAlarmDigitLabels];
	
/*	UIImageView *indicatorImageView = (UIImageView *)[self.view viewWithTag:VC_OFFINDICATORIMAGE_TAG];		
	
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:kEnableVoiceControls] boolValue]) {
		[indicatorImageView setImage:[UIImage imageNamed:@"indicatorLightOn.png"]];
	} else {
		[indicatorImageView setImage:[UIImage imageNamed:@"indicatorLightOff-iPad.png"]];
	}
*/
	if (((NSArray *)[[NSUserDefaults standardUserDefaults] objectForKey:kLocationPoints]).count > 0)
	{
		[((UITableViewCell *)[self.view viewWithTag:kShowMapCell]).textLabel setText:@"Show on Map"];
	} else {
		[((UITableViewCell *)[self.view viewWithTag:kShowMapCell]).textLabel setText:@"Set Place"];
	}
	
	UILabel *snoozeTimeLabel = (UILabel *)[self.view viewWithTag:SNOOZE_TIME_LABEL_TAG];	
	[snoozeTimeLabel setText:[[[NSUserDefaults standardUserDefaults] objectForKey:kSnoozeMinutes] stringValue]];
}

- (IBAction)pushVoiceControls:(id)sender
{		
//	Sleep_Blaster_touchAppDelegate *mainDelegate = (Sleep_Blaster_touchAppDelegate *)[[UIApplication sharedApplication] delegate];

	VoiceSettingsViewController *controller;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		controller = [[VoiceSettingsViewController alloc] initWithNibName:@"VoiceSettingsView-iPad" bundle:nil];
	} else {
		controller = [[VoiceSettingsViewController alloc] initWithNibName:@"VoiceSettingsView" bundle:nil];
		controller.hidesBottomBarWhenPushed = YES;
	}
	[[self navigationController] pushViewController:controller animated:YES];
	[controller release];
}

- (IBAction)pushMapView:(id)sender
{
	Sleep_Blaster_touchAppDelegate *mainDelegate = (Sleep_Blaster_touchAppDelegate *)[[UIApplication sharedApplication] delegate];
	mainDelegate.mapViewController.hidesBottomBarWhenPushed = YES;
	[[self navigationController] pushViewController:mainDelegate.mapViewController animated:YES];
}

- (void)setButtonSegmentImages
{
	int value = [[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmMode] intValue];
	if (value == 0)
	{
		[((UIButton *)[self.view viewWithTag:LEFT_BUTTON_SEGMENT]) setBackgroundImage:[UIImage imageNamed:@"segmentedControlTimeSelected.png"] 
															   forState:UIControlStateNormal];
		[((UIButton *)[self.view viewWithTag:RIGHT_BUTTON_SEGMENT]) setBackgroundImage:[UIImage imageNamed:@"segmentedControlPlaceDeselected.png"] 
																forState:UIControlStateNormal];
	} else if (value == 1 ) {
		[((UIButton *)[self.view viewWithTag:LEFT_BUTTON_SEGMENT]) setBackgroundImage:[UIImage imageNamed:@"segmentedControlTimeDeselected.png"] 
															   forState:UIControlStateNormal];
		[((UIButton *)[self.view viewWithTag:RIGHT_BUTTON_SEGMENT]) setBackgroundImage:[UIImage imageNamed:@"segmentedControlPlaceSelected.png"] 
																forState:UIControlStateNormal];
	}
}

- (IBAction)buttonSegmentTapped:(UIButton *)sender
{	
	if (sender.tag == LEFT_BUTTON_SEGMENT) 
	{
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] 
												  forKey:kAlarmMode];
		
	} else if (sender.tag == RIGHT_BUTTON_SEGMENT) {

		NSString *deviceModel = [self deviceModel];
//		NSLog(deviceModel);
				
//		if ([[UIDevice currentDevice].model isEqualToString:@"iPhone"] &&
//			![deviceModel isEqualToString:@"iPhone1,1"]) {
	
		
		CLLocationManager *locationManager = [[CLLocationManager alloc] init];
//		NSLog(@"%f", ((double)[[locationManager location] verticalAccuracy]));
			if (([[UIDevice currentDevice].model isEqualToString:@"iPhone"] && ![deviceModel isEqualToString:@"iPhone1,1"]) ||
				/*((double)[[locationManager location] verticalAccuracy]) != 0*/
				UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		{

			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] 
													  forKey:kAlarmMode];
		
		} else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GPS Required" 
															message:@"To use the map feature, you must have a GPS-enabled device." 
														   delegate:self 
												  cancelButtonTitle:@"OK" 
												  otherButtonTitles:nil, nil];
			[alert show];
			[alert release];
		}
		[locationManager release];
	}
	
	
	// This line automatically updates the images of the segmented control.
	[tableView reloadData];	
	// And this line gives it a smoother transition when it's changing the "alarm time" cell to the "show map" cell.
	[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]]		
					 withRowAnimation:UITableViewRowAnimationFade];
	
	[self setButtonSegmentImages];
	
	[[AlarmController sharedAlarmController] setupAlarm:self];
}

- (NSString *) deviceModel{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *answer = malloc(size);
    sysctlbyname("hw.machine", answer, &size, NULL, 0);
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    free(answer);
    return results;
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
//	referenceToPopoverController.popoverContentSize = viewController.view.frame.size;
	
	
	UIImageView *offIndicatorImageView = (UIImageView *)[self.view viewWithTag:VC_OFFINDICATORIMAGE_TAG];		
	UIImageView *onIndicatorImageView = (UIImageView *)[self.view viewWithTag:VC_ONINDICATORIMAGE_TAG];		

	if ([[[NSUserDefaults standardUserDefaults] objectForKey:kEnableVoiceControls] boolValue]) {
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:1.0];
		
		offIndicatorImageView.alpha = 0.0;
		onIndicatorImageView.alpha = 1.0;

		[UIView commitAnimations];
		
		indicatorLightWasOn = YES;

	} else {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:1.0];

		offIndicatorImageView.alpha = 1.0;
		onIndicatorImageView.alpha = 0.0;

		[UIView commitAnimations];
		
		indicatorLightWasOn = NO;
	}
}

#pragma mark keypad functions

- (void)toggleKeypad:(id)sender
{
	if (keypadIsShowing)
	{
		// Get ready to move the keypadView out of visibility.
		CGRect keypadViewFrame = self.keypadViewController.view.frame;
//		keypadViewFrame.origin.y += (KEYPAD_HEIGHT_MINUS_SHADOW + BOTTOMBAR_HEIGHT);
		keypadViewFrame.origin.y = self.view.frame.size.height;
		
		// Get ready to move the main view back down to fill the screen again.
		CGRect mainViewFrame = self.view.frame;
		mainViewFrame.origin.y += (KEYPAD_HEIGHT_MINUS_SHADOW - 60);
		
		[UIView beginAnimations:@"keypad" context:NULL];
		[UIView setAnimationDuration:1.0];
		
		self.view.frame = mainViewFrame;
		self.keypadViewController.view.frame = keypadViewFrame;
		
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
		[UIView commitAnimations];
				
		keypadIsShowing = NO;
	} else {
		// Add the keypadView as a subview, and stick it below the very bottom of the screen.
		if (!self.keypadViewController) {
			self.keypadViewController = [[[KeypadViewController alloc] initWithNibName:@"KeypadView" bundle:nil] retain];
			self.keypadViewController.delegate = self;
		}
		[self.view.superview addSubview:self.keypadViewController.view];

		CGRect keypadViewFrame = self.keypadViewController.view.frame;
		keypadViewFrame.size.height = 230;
//		keypadViewFrame.origin.y = (480) - MENUBAR_HEIGHT - 20;		// height of the screen minus the height of the menubar and the shadow
		keypadViewFrame.origin.y = self.view.frame.size.height;
		self.keypadViewController.view.frame = keypadViewFrame;
		
		// Get ready to move the keypadView into visibility.
//		keypadViewFrame.origin.y -= (KEYPAD_HEIGHT_MINUS_SHADOW + BOTTOMBAR_HEIGHT);
		keypadViewFrame.origin.y = self.view.frame.size.height - keypadViewFrame.size.height;
		
		// Get ready to move the main view up to make room for the keypadView.
		CGRect mainViewFrame = self.view.frame;
		mainViewFrame.origin.y -= (KEYPAD_HEIGHT_MINUS_SHADOW - 60);	// let the keyboard "catch up" an additional 80 pixels
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:1.0];
		
		self.view.frame = mainViewFrame;
		self.keypadViewController.view.frame = keypadViewFrame;
		
		[UIView commitAnimations];
		
		
		keypadIsShowing = YES;
	}
}

		 
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	if ([animationID isEqualToString:@"keypad"])
	{
		[self.keypadViewController.view removeFromSuperview];
	}
}

- (IBAction)enterDigit:(id)sender
{
	int originalNumber = [[[NSUserDefaults standardUserDefaults] objectForKey:kSnoozeMinutes] intValue];
	
	int newNumber = originalNumber * 10 + ((UIButton *)sender).tag;
	if (newNumber >= 99) {
		newNumber = ((UIButton *)sender).tag;		// don't let it be more than two digits
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:newNumber] forKey:kSnoozeMinutes];
}

- (IBAction)clearDigits:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:kSnoozeMinutes];
}

#pragma mark UITableViewDelegate

/*- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//	{
//		return 60.0;
//	} else {
		if (section == kModeSectionIndex)
		{
			return 80.0;
		} else {
			return 60.0;
		}
//	}
}*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 0)
	{
		return 100.0;
	} else {
		return 60.0;
	}
}

/*- (UIView *)tableView:(UITableView *)theTableView viewForHeaderInSection:(NSInteger)section
{
	if (section == kModeSectionIndex)
	{
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		{
			// The device is an iPad running iPhone 3.2 or later.
			return nil;
		}
		else
#endif
		{
			// The device is an iPhone or iPod touch.
			UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 80.0)] autorelease];
			
			UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10.0, tableView.frame.size.width, 20.0)];
			label.text = @"Wake me up at a certain...";
			label.textAlignment = UITextAlignmentCenter;
			label.backgroundColor = [UIColor clearColor];
			label.textColor = [UIColor colorWithRed:.1 green:.1 blue:.1 alpha:1.0];
			label.shadowColor = [UIColor whiteColor];
			label.shadowOffset = CGSizeMake(0, 1);
			[view addSubview:label];
			[label release];	
			
			UIButton *timeButtonSegment = [UIButton buttonWithType:UIButtonTypeCustom];
			timeButtonSegment.frame = CGRectMake(tableView.frame.size.width/2 - 103.0, label.frame.size.height+label.frame.origin.y+10.0, 103.0, 40.0);
			timeButtonSegment.tag = LEFT_BUTTON_SEGMENT;
			[timeButtonSegment addTarget:self action:@selector(buttonSegmentTapped:) forControlEvents:UIControlEventTouchUpInside];
			
			UIButton *placeButtonSegment = [UIButton buttonWithType:UIButtonTypeCustom];
			placeButtonSegment.frame = CGRectMake(tableView.frame.size.width/2, label.frame.size.height+label.frame.origin.y+10.0, 103.0, 40.0);
			placeButtonSegment.tag = RIGHT_BUTTON_SEGMENT;
			[placeButtonSegment addTarget:self action:@selector(buttonSegmentTapped:) forControlEvents:UIControlEventTouchUpInside];
			
			int value = [[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmMode] intValue];
			if (value == 0)
			{
				[timeButtonSegment setBackgroundImage:[UIImage imageNamed:@"segmentedControlTimeSelected.png"] 
											 forState:UIControlStateNormal];
				[placeButtonSegment setBackgroundImage:[UIImage imageNamed:@"segmentedControlPlaceDeselected.png"] 
											  forState:UIControlStateNormal];
			} else if (value == 1 ) {
				[timeButtonSegment setBackgroundImage:[UIImage imageNamed:@"segmentedControlTimeDeselected.png"] 
											 forState:UIControlStateNormal];
				[placeButtonSegment setBackgroundImage:[UIImage imageNamed:@"segmentedControlPlaceSelected.png"] 
											  forState:UIControlStateNormal];
			}
			
			[view addSubview:timeButtonSegment];
			[view addSubview:placeButtonSegment];
			
			return view;			
		}
		
		
	} else {
		
//		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//		{
			UIImage *rowBackground = [UIImage imageNamed:@"lightRow.png"];		
			UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 10.0, rowBackground.size.width, 60.0)];
			backgroundImageView.image = rowBackground;
			
			return backgroundImageView;
			
//		} else {
//			theTableView.sectionHeaderHeight = 40;
//			UILabel *headerLabel = [[[ShadowedLabel alloc] initWithFrame:CGRectMake(0, 40, 300, 40)] autorelease];
//			headerLabel.text = [self tableView:tableView titleForHeaderInSection:section];
//			headerLabel.textColor = [UIColor colorWithRed:.69 green:.90 blue:.98 alpha:1];
//			headerLabel.font = [UIFont boldSystemFontOfSize:14];
//			headerLabel.backgroundColor = [UIColor clearColor];
//			headerLabel.textAlignment = UITextAlignmentCenter;
//
//			return headerLabel;
//		}
		
	}
}
*/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
{
//	if ([[[NSUserDefaults standardUserDefaults] objectForKey:kEnableDynamiteMode] boolValue]) {
//		return 2;
//	} else {
//		return 3;
//	}
	
	return 1;

}

/*- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == kAlarmSettingsSectionIndex) {
		return @"ALARM SETTINGS";
	} else if (section == kMusicSettingsSectionIndex) {
		return @"MUSIC SETTINGS";
	} else if (section == kModeSectionIndex) {
		return @"";
	}
}
*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
/*	if (section == kAlarmSettingsSectionIndex) {
		return 4;
	} else if (section == kMusicSettingsSectionIndex) {
		return 2;
	} else if (section == kModeSectionIndex) {
		return 1;
	}
 */
	
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:kEnableDynamiteMode] boolValue]) 
	{
		return 7;
	} else {
		return 10;
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
	cell.textLabel.textColor = [UIColor colorWithRed:.1 green:.1 blue:.1 alpha:1.0];
	cell.textLabel.highlightedTextColor = [UIColor colorWithRed:.1 green:.1 blue:.1 alpha:1.0];
	cell.textLabel.shadowColor = [UIColor whiteColor];
	cell.textLabel.shadowOffset = CGSizeMake(0, 1);

		
		switch ([indexPath row]) {
				
			case 0: {
				
//				if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
//				{
					// The device is an iPhone or iPod touch.
					UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 80.0)] autorelease];
					
					UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10.0, tableView.frame.size.width, 20.0)];
					label.text = @"Wake me up at a certain...";
					label.textAlignment = UITextAlignmentCenter;
					label.backgroundColor = [UIColor clearColor];
					label.textColor = [UIColor colorWithRed:.1 green:.1 blue:.1 alpha:1.0];
					label.shadowColor = [UIColor whiteColor];
					label.shadowOffset = CGSizeMake(0, 1);
					[view addSubview:label];
					[label release];	
					
					UIButton *timeButtonSegment = [UIButton buttonWithType:UIButtonTypeCustom];
					timeButtonSegment.frame = CGRectMake(tableView.frame.size.width/2 - 103.0, label.frame.size.height+label.frame.origin.y+10.0, 103.0, 40.0);
					timeButtonSegment.tag = LEFT_BUTTON_SEGMENT;
					[timeButtonSegment addTarget:self action:@selector(buttonSegmentTapped:) forControlEvents:UIControlEventTouchUpInside];
					
					UIButton *placeButtonSegment = [UIButton buttonWithType:UIButtonTypeCustom];
					placeButtonSegment.frame = CGRectMake(tableView.frame.size.width/2, label.frame.size.height+label.frame.origin.y+10.0, 103.0, 40.0);
					placeButtonSegment.tag = RIGHT_BUTTON_SEGMENT;
					[placeButtonSegment addTarget:self action:@selector(buttonSegmentTapped:) forControlEvents:UIControlEventTouchUpInside];
					
					int value = [[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmMode] intValue];
					if (value == 0)
					{
						[timeButtonSegment setBackgroundImage:[UIImage imageNamed:@"segmentedControlTimeSelected.png"] 
													 forState:UIControlStateNormal];
						[placeButtonSegment setBackgroundImage:[UIImage imageNamed:@"segmentedControlPlaceDeselected.png"] 
													  forState:UIControlStateNormal];
					} else if (value == 1 ) {
						[timeButtonSegment setBackgroundImage:[UIImage imageNamed:@"segmentedControlTimeDeselected.png"] 
													 forState:UIControlStateNormal];
						[placeButtonSegment setBackgroundImage:[UIImage imageNamed:@"segmentedControlPlaceSelected.png"] 
													  forState:UIControlStateNormal];
					}
					
					[view addSubview:timeButtonSegment];
					[view addSubview:placeButtonSegment];
					
					[cell.contentView addSubview:view];
//				}
				
				break;
				
			}
				
			case 1: {
				if ([[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmMode] intValue] == 0)
				{
					[cell.textLabel setText:@"Alarm Time"];
					
					//			UIImage *lcd = [UIImage imageNamed:@"alarmMiniLCD.png"];
					//			// CAUSES A CRASHER WHEN YOU RELEASE THIS AT ANY TIME FOR SOME REASON
					//			UIImageView *lcdImageView = [[UIImageView alloc] initWithFrame:CGRectMake(200.0, (tableView.rowHeight/2)-(lcd.size.height/2), lcd.size.width, lcd.size.height)];
					//			[lcdImageView setImage:lcd];
					//			[lcdImageView setOpaque:NO];
					
					UIImage *blackScreen = [UIImage imageNamed:@"blackScreen.png"];
					UIImageView *lcdImageView = [[UIImageView alloc] initWithFrame:CGRectMake(195.0, ([self tableView:tableView heightForRowAtIndexPath:indexPath]/2)-(blackScreen.size.height/2), blackScreen.size.width, blackScreen.size.height)];
					[lcdImageView setImage:blackScreen];			
					[cell.contentView addSubview:lcdImageView];	
					
					//			hourLabel1 = [AlarmSettingsViewController createDigitLabel];
					//			hourLabel1.frame = CGRectMake(11.0, 0.0, 10.0, 34.0);
					//			[lcdImageView addSubview:hourLabel1];		
					//			
					//			hourLabel2 = [AlarmSettingsViewController createDigitLabel];
					//			hourLabel2.frame = CGRectMake(21.0, 0.0, 10.0, 34.0);
					//			[lcdImageView addSubview:hourLabel2];
					//			
					//			ShadowedLabel *colonLabel = [AlarmSettingsViewController createDigitLabel];
					//			colonLabel.frame = CGRectMake(30.0, 0.0, 5.0, 34.0);
					//			colonLabel.text = @":";
					//			[lcdImageView addSubview:colonLabel];
					//			
					//			minuteLabel1 = [AlarmSettingsViewController createDigitLabel];
					//			minuteLabel1.frame = CGRectMake(34.0, 0.0, 10.0, 34.0);
					//			[lcdImageView addSubview:minuteLabel1];
					//			
					//			minuteLabel2 = [AlarmSettingsViewController createDigitLabel];
					//			minuteLabel2.frame = CGRectMake(44.0, 0.0, 10.0, 34.0);
					//			[lcdImageView addSubview:minuteLabel2];
					//			
					//			ampmLabel = [AlarmSettingsViewController createDigitLabel];
					//			ampmLabel.frame = CGRectMake(55.0, 0.0, 20.0, 34.0);
					//			[lcdImageView addSubview:ampmLabel];
					
					NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
					if ([[[NSCalendar currentCalendar] locale] timeIs24HourFormat])
					{
						[dateFormatter setDateFormat:@"HH:mm"];
					} else {
						[dateFormatter setDateFormat:@"h:mm a"];
					}
					NSString *currentTime = [dateFormatter stringFromDate:[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmDate]];
					
					ShadowedLabel *alarmTimeLabel = [[ShadowedLabel alloc] initWithFrame:CGRectMake(lcdImageView.frame.origin.x+lcdImageView.frame.size.width/2-100.0/2, ([self tableView:tableView heightForRowAtIndexPath:indexPath]/2)-(27.0/2), 100.0, 27.0)];
					alarmTimeLabel.textAlignment = UITextAlignmentCenter;
					alarmTimeLabel.font = [UIFont boldSystemFontOfSize:12.0];
					alarmTimeLabel.textColor = [UIColor colorWithRed:.72 green:.91 blue:1.0 alpha:1.0];
					alarmTimeLabel.shadowColor = [UIColor colorWithRed:0.0 green:.52 blue:1.0 alpha:.9];
					alarmTimeLabel.shadowBlur = 10.0;
					alarmTimeLabel.backgroundColor = [UIColor clearColor];
					[alarmTimeLabel setText:currentTime];
					alarmTimeLabel.tag = ALARM_TIME_LABEL_TAG;
					[cell.contentView addSubview:alarmTimeLabel];
					[alarmTimeLabel release];
					
					//	[self setAlarmDigitLabels];
					
					[dateFormatter release];
					
					//			[lcdImageView release];
					//		[lcd release];
					
				} else if ([[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmMode] intValue] == 1)
				{
					cell.tag = kShowMapCell;
					if (((NSArray *)[[NSUserDefaults standardUserDefaults] objectForKey:kLocationPoints]).count > 0)
					{
						[cell.textLabel setText:@"Show on Map"];
					} else {
						[cell.textLabel setText:@"Set Place"];
					}
					
					
					UIImage *disclosure = [UIImage imageNamed:@"disclosure-iPad.png"];
					UIImageView *disclosureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(250.0, ([self tableView:tableView heightForRowAtIndexPath:indexPath]/2)-(disclosure.size.height/2), disclosure.size.width, disclosure.size.height)];
					[disclosureImageView setImage:disclosure];
					[disclosureImageView setOpaque:NO];
					[cell.contentView addSubview:disclosureImageView];
					
					[disclosureImageView release];
					//		[disclosure release];
				}
				
				break;
			}

			case 3:	{	// this is for the "alarm on" switch.
				
				[cell.textLabel setText:@"Alarm On"];
				
				alarmSwitch = [AlarmSettingsViewController createSwitch];
				CGRect newRect = alarmSwitch.frame;
				newRect.origin.y = ([self tableView:tableView heightForRowAtIndexPath:indexPath]/2)-(newRect.size.height/2);
				alarmSwitch.frame = newRect;
				
				[alarmSwitch addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
				[alarmSwitch setOn:[[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmOn] boolValue] animated:YES];
				alarmSwitch.tag = kAlarmSwitch;
				[cell.contentView addSubview:alarmSwitch];
				
				break;
			}					
			case 4:		{
				// this is for the voice controls switch.
				
				[cell.textLabel setText:@"Voice Controls"];
				
				UIImage *offIndicatorImage;
				UIImage *onIndicatorImage;
				
//				if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//				{
					offIndicatorImage = [UIImage imageNamed:@"indicatorLightOff-iPad.png"];
					onIndicatorImage = [UIImage imageNamed:@"indicatorLightOn-iPad.png"];
//				} else {
//					offIndicatorImage = [UIImage imageNamed:@"indicatorLightOff.png"];
//					onIndicatorImage = [UIImage imageNamed:@"indicatorLightOn.png"];
//				}
				
				UIImageView *offIndicatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(190.0, ([self tableView:tableView heightForRowAtIndexPath:indexPath]/2)-(offIndicatorImage.size.height/2), offIndicatorImage.size.width, offIndicatorImage.size.height)];
				offIndicatorImageView.tag = VC_OFFINDICATORIMAGE_TAG;
				[offIndicatorImageView setOpaque:NO];				
				[offIndicatorImageView setImage:offIndicatorImage];
				
				UIImageView *onIndicatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(190.0, ([self tableView:tableView heightForRowAtIndexPath:indexPath]/2)-(onIndicatorImage.size.height/2), onIndicatorImage.size.width, onIndicatorImage.size.height)];
				onIndicatorImageView.tag = VC_ONINDICATORIMAGE_TAG;
				[onIndicatorImageView setOpaque:NO];				
				[onIndicatorImageView setImage:onIndicatorImage];
				
				//if ([[[NSUserDefaults standardUserDefaults] objectForKey:kEnableVoiceControls] boolValue]) {
				if (indicatorLightWasOn) {
				//	indicatorImage = [UIImage imageNamed:@"indicatorLightOn-iPad.png"];
					offIndicatorImageView.alpha = 0.0;
					onIndicatorImageView.alpha = 1.0;
				} else {
				//	indicatorImage = [UIImage imageNamed:@"indicatorLightOff-iPad.png"];
					offIndicatorImageView.alpha = 1.0;
					onIndicatorImageView.alpha = 0.0;
				}
				
				[cell.contentView addSubview:offIndicatorImageView];				
				[cell.contentView addSubview:onIndicatorImageView];
				[offIndicatorImageView release];
				[onIndicatorImageView release];
								
				UIImage *disclosure;
	//			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//				{
					disclosure = [UIImage imageNamed:@"disclosure-iPad.png"];
//				} else {
//					disclosure = [UIImage imageNamed:@"disclosure.png"];
//				}					
				UIImageView *disclosureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(250.0, ([self tableView:tableView heightForRowAtIndexPath:indexPath]/2)-(disclosure.size.height/2), disclosure.size.width, disclosure.size.height)];
				[disclosureImageView setImage:disclosure];
				[disclosureImageView setOpaque:NO];
				[cell.contentView addSubview:disclosureImageView];
				
				[disclosureImageView release];
				
				break;
			}
			case 5:		// this is for the Snooze setting.
			{
				[cell.textLabel setText:@"Snooze Minutes"];
				
				UIImage *blackScreen = [UIImage imageNamed:@"blackScreen.png"];
				UIImageView *borderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(195.0, ([self tableView:tableView heightForRowAtIndexPath:indexPath]/2)-(blackScreen.size.height/2), blackScreen.size.width, blackScreen.size.height)];
				[borderImageView setImage:blackScreen];
				[cell.contentView addSubview:borderImageView];
								
				ShadowedLabel *snoozeTimeLabel = [[ShadowedLabel alloc] initWithFrame:CGRectMake(borderImageView.frame.origin.x+borderImageView.frame.size.width/2-100.0/2, ([self tableView:tableView heightForRowAtIndexPath:indexPath]/2)-(27.0/2), 100.0, 27.0)];
				snoozeTimeLabel.textAlignment = UITextAlignmentCenter;
				snoozeTimeLabel.font = [UIFont boldSystemFontOfSize:12.0];
				snoozeTimeLabel.textColor = [UIColor colorWithRed:.72 green:.91 blue:1.0 alpha:1.0];
				snoozeTimeLabel.shadowColor = [UIColor colorWithRed:0.0 green:.52 blue:1.0 alpha:.9];
				snoozeTimeLabel.shadowBlur = 10.0;
				snoozeTimeLabel.backgroundColor = [UIColor clearColor];
				[snoozeTimeLabel setText:[[[NSUserDefaults standardUserDefaults] objectForKey:kSnoozeMinutes] stringValue]];
				snoozeTimeLabel.tag = SNOOZE_TIME_LABEL_TAG;
				[cell.contentView addSubview:snoozeTimeLabel];
				
				[snoozeTimeLabel release];
				[borderImageView release];
				
				break;
			}
			case 6:		// this is for the Dynamite Mode switch.
			{
				[cell.textLabel setText:@"Dynamite Mode!"];
				cell.tag = DYNAMITE_CELL;
				
				CustomUISwitch *dynamiteSwitch = [AlarmSettingsViewController createSwitch];
				CGRect newRect = dynamiteSwitch.frame;
				newRect.origin.y = ([self tableView:tableView heightForRowAtIndexPath:indexPath]/2)-(newRect.size.height/2);
				dynamiteSwitch.frame = newRect;
				
				[dynamiteSwitch addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
				
				[dynamiteSwitch setOn:[[[NSUserDefaults standardUserDefaults] objectForKey:kEnableDynamiteMode] boolValue] animated:YES];
				dynamiteSwitch.tag = kDynamiteSwitch;
				
				[cell.contentView addSubview:dynamiteSwitch];
				

				break;
			}
		
			case 8:	
			{
				// this is for the music picker.
				self.musicCell = cell;
				[self setLabelInMusicCell];
				
				UIImage *disclosure;
				//			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
				//				{
				disclosure = [UIImage imageNamed:@"disclosure-iPad.png"];
				//				} else {
				//					disclosure = [UIImage imageNamed:@"disclosure.png"];
				//				}					
				UIImageView *disclosureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(250.0, ([self tableView:tableView heightForRowAtIndexPath:indexPath]/2)-(disclosure.size.height/2), disclosure.size.width, disclosure.size.height)];
				[disclosureImageView setImage:disclosure];
				[disclosureImageView setOpaque:NO];
				[cell.contentView addSubview:disclosureImageView];
				
				[disclosureImageView release];
				//		[disclosure release];
				
				break;
			}
				
			case 9:		// this is for the "shuffle switch.
			{
				[cell.textLabel setText:@"Shuffle"];
				
				CustomUISwitch *shuffleSwitch = [AlarmSettingsViewController createSwitch];
				CGRect newRect = shuffleSwitch.frame;
				newRect.origin.y = ([self tableView:tableView heightForRowAtIndexPath:indexPath]/2)-(newRect.size.height/2);
				shuffleSwitch.frame = newRect;
				
				[shuffleSwitch addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
				[shuffleSwitch setOn:[[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmMusicShuffle] boolValue] animated:YES];
				shuffleSwitch.tag = kShuffleSwitch;
				
				[cell.contentView addSubview:shuffleSwitch];
				
				break;
			}
				
			default:
				break;
				
				
		}

	UIImage *rowBackground;
	UIImage *selectionBackground;
	NSInteger row = [indexPath row];
//	NSInteger section = [indexPath section];

	NSString *backgroundImageName = @"";
	NSString *selectedBackgroundImageName = @"";

/*	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
*/		
	if (row < [self tableView:tableView numberOfRowsInSection:0]-1)
	{
		if (row == 1)
		{
			backgroundImageName = @"lightRowTop.png";
			selectedBackgroundImageName = @"lightRowTop.png";
		} else if (row != 0)
		{
			backgroundImageName = @"lightRow.png";
			selectedBackgroundImageName = @"lightRow.png";
		}
	}
	rowBackground = [UIImage imageNamed:backgroundImageName];
	selectionBackground = [UIImage imageNamed:selectedBackgroundImageName];

	UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	UIImageView *selectedBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	backgroundImageView.image = rowBackground;
	selectedBackgroundImageView.image = selectionBackground;
	
	cell.backgroundView = backgroundImageView;
	cell.selectedBackgroundView = selectedBackgroundImageView;
	
	[backgroundImageView release];
	[selectedBackgroundImageView release];
	
//	[rowBackground release];
//	[selectionBackground release];
	
	return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSIndexPath *)tableView:(UITableView *)aTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	switch (indexPath.row) {
			
		case 1:
		{
			if ([[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmMode] intValue] == 0) {
				// "Alarm Time" tapped; bring up the datepicker to set the alarm time.
				[self toggleDatePicker:self];
			} else if ([[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmMode] intValue] == 1) {
				[self pushMapView:self];
			}		
			break;
		}
		case 4:
		{
			// "Voice Controls" button tapped; go the the voice settings screen.		
			
			UInt32 inputAvailableSize = sizeof(UInt32);
			UInt32 inputAvailable;
			AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable, &inputAvailableSize, &inputAvailable);
			if (inputAvailable)
			{
				[self pushVoiceControls:self];
			} else {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Voice Controls not available" 
																message:@"You must have a microphone connected to use Voice Controls." 
															   delegate:self 
													  cancelButtonTitle:@"OK" 
													  otherButtonTitles:nil, nil];
				[alert show];
				[alert release];
			}
			break;
		}
			
		case 5:
		{
			[self toggleKeypad:[tableView cellForRowAtIndexPath:indexPath]];
			break;
		}
		case 8:
		{
			// "Music" button tapped; bring up the music picker.
			[self chooseMusic:self];
			break;
		}
			
			
		default:
			break;
	}

    return indexPath;
}

- (UIButton *) getDetailDiscolosureIndicatorForIndexPath: (NSIndexPath *) indexPath  
{  
    UIButton *button = [UIButton buttonWithType: UIButtonTypeDetailDisclosure];  
    button.frame = CGRectMake(320.0 - 44.0, 0.0, 44.0, 44.0);  
    [button addTarget:self action:@selector(AddMusicOrShowMusic:) forControlEvents:UIControlEventTouchUpInside];  
    return button;  
}    

- (void) detailDiscolosureIndicatorSelected: (UIButton *) sender  
{  
    //  
    // Obtain a reference to the selected cell  
    //  
	
    //  
    // Do something like render a detailed view  
    //  
}  


/*- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//NSInteger row = [indexPath row];
	
	// create a UIButton (UIButtonTypeDetailDisclosure)
	UIButton *detailDisclosureButtonType = [[UIButton buttonWithType:UIButtonTypeDetailDisclosure] retain];
	detailDisclosureButtonType.frame = CGRectMake(0.0, 0.0, 25.0, 25.0);
	[detailDisclosureButtonType setTitle:@"Detail Disclosure" forState:UIControlStateNormal];
	detailDisclosureButtonType.backgroundColor = [UIColor clearColor];
	[detailDisclosureButtonType addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];	
	
	UITableViewCell *cell = [self obtainTableCellForRow:0];

	// this cell hosts the rounded button
	((DisplayCell *)cell).nameLabel.text = @"Detail Disclosure";
	((DisplayCell *)cell).view = detailDisclosureButtonType;
		

	
	switch (indexPath.section)
	{
		case kUIGrayButton_Section:
		{
			if (row == 0)
			{
				// this cell hosts the gray button
				((DisplayCell *)cell).nameLabel.text = @"Background Image";
				((DisplayCell *)cell).view = grayButton;
			}
			else
			{
				// this cell hosts the info on where to find the code
				((SourceCell *)cell).sourceLabel.text = @"ButtonsViewController.m - createGrayButton";
			}
			break;
		}
			
		case kUIImageButton_Section:
		{
			if (row == 0)
			{
				// this cell hosts the button with image
				((DisplayCell *)cell).nameLabel.text = @"Button with Image";
				((DisplayCell *)cell).view = imageButton;
			}
			else
			{
				// this cell hosts the info on where to find the code
				((SourceCell *)cell).sourceLabel.text = @"ButtonsViewController.m - createImageButton";
			}
			break;
		}
			
		case kUIRoundRectButton_Section:
		{
			if (row == 0)
			{
				// this cell hosts the rounded button
				((DisplayCell *)cell).nameLabel.text = @"Rounded Button";
				((DisplayCell *)cell).view = roundedButtonType;
			}
			else
			{
				// this cell hosts the info on where to find the code
				((SourceCell *)cell).sourceLabel.text = @"ButtonsViewController.m - createRoundedButton";
			}
			break;
		}
			
		case kUIDetailDisclosureButton_Section:
		{
			if (row == 0)
			{
				// this cell hosts the rounded button
				((DisplayCell *)cell).nameLabel.text = @"Detail Disclosure";
				((DisplayCell *)cell).view = detailDisclosureButtonType;
			}
			else
			{
				// this cell hosts the info on where to find the code
				((SourceCell *)cell).sourceLabel.text = @"ButtonsViewController.m - createDetailDisclosureButton";
			}
			break;
		}
			
		case kUIInfoLightButton_Section:
		{
			if (row == 0)
			{
				// this cell hosts the rounded button
				((DisplayCell *)cell).nameLabel.text = @"Info Light";
				((DisplayCell *)cell).view = infoLightButtonType;
			}
			else
			{
				// this cell hosts the info on where to find the code
				((SourceCell *)cell).sourceLabel.text = @"ButtonsViewController.m - createInfoLightButton";
			}
			break;
		}
			
		case kUIInfoDarkButton_Section:
		{
			if (row == 0)
			{
				// this cell hosts the rounded button
				((DisplayCell *)cell).nameLabel.text = @"Info Dark";
				((DisplayCell *)cell).view = infoDarkButtonType;
			}
			else
			{
				// this cell hosts the info on where to find the code
				((SourceCell *)cell).sourceLabel.text = @"ButtonsViewController.m - createInfoDarkButton";
			}
			break;
		}
			
		case kUIContactAddButton_Section:
		{
			if (row == 0)
			{
				// this cell hosts the rounded button
				((DisplayCell *)cell).nameLabel.text = @"Contact Add";
				((DisplayCell *)cell).view = contactAddButtonType;
			}
			else
			{
				// this cell hosts the info on where to find the code
				((SourceCell *)cell).sourceLabel.text = @"ButtonsViewController.m - createContactAddButton";
			}
			break;
		}		
	}

	return cell;
}*/

/*- (UITableViewCell *)obtainTableCellForRow:(NSInteger)row
{
	UITableViewCell *cell = nil;
	
	if (row == 0)
		cell = [tableView dequeueReusableCellWithIdentifier:kDisplayCell_ID];
	else if (row == 1)
		cell = [tableView dequeueReusableCellWithIdentifier:kSourceCell_ID];
	
	if (cell == nil)
	{
		if (row == 0)
			cell = [[[DisplayCell alloc] initWithFrame:CGRectZero reuseIdentifier:kDisplayCell_ID] autorelease];
		else if (row == 1)
			cell = [[[SourceCell alloc] initWithFrame:CGRectZero reuseIdentifier:kSourceCell_ID] autorelease];
	}
	
	return [tableView dequeueReusableCellWithIdentifier:kDisplayCell_ID];
}*/

@end
