//
//  ClockViewController.m
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 11/24/09.
//  Copyright 2009 The Byte Factory. All rights reserved.
//

#import "ClockViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "Constants.h"
#import <dlfcn.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SCListener.h"
#import "AlarmRingingViewController.h"
#import "AlarmController.h"
#import "Sleep_Blaster_touchAppDelegate.h"
#import "NSLocale+Misc.h"
#import "AlarmSettingsViewController.h"

#define degreesToRadian(x) (M_PI * x / 180.0)

@implementation ClockViewController

@synthesize timer;
@synthesize alarmPopoverController;
@synthesize sleepTimerPopoverController;
@synthesize rightSettingsButton;

BOOL alreadyFadedInClock = NO;
BOOL alarmPopoverWasVisibleBeforeRotation = NO;
BOOL sleepTimerPopoverWasVisibleBeforeRotation = NO;
UIInterfaceOrientation oldOrientation;

NSUInteger loadFonts()
{
	NSUInteger newFontCount = 0;
	NSBundle *frameworkBundle = [NSBundle bundleWithIdentifier:@"com.apple.GraphicsServices"];
	const char *frameworkPath = [[frameworkBundle executablePath] UTF8String];
	if (frameworkPath) {
		void *graphicsServices = dlopen(frameworkPath, RTLD_NOLOAD | RTLD_LAZY);
		if (graphicsServices) {
			BOOL (*GSFontAddFromFile)(const char *) = dlsym(graphicsServices, "GSFontAddFromFile");
			if (GSFontAddFromFile)
				for (NSString *fontFile in [[NSBundle mainBundle] pathsForResourcesOfType:@"ttf" inDirectory:nil])
					newFontCount += GSFontAddFromFile([fontFile UTF8String]);
		}
	}
	return newFontCount;
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


- (void)viewDidLoad {
    [super viewDidLoad];
	NSLog(@"clock view did load");
	
	
	CGRect rect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
	self.view.frame = rect;
	
	loadFonts();

	[self setFontsForLabels];
	[self setCurrentDateAndTimeLabels];
	[self positionSettingsButtons];
	
//	CGRect rect = rightSettingsButton.frame;
//	rect.origin.x = [UIScreen mainScreen].bounds.size.width - rect.size.width - 10.0;
//	rect.origin.y = [UIScreen mainScreen].bounds.size.height - rect.size.height - 10.0;
//	rightSettingsButton.frame = rect;
	
	self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self
													selector:@selector(updateClock:)
													userInfo:nil repeats:YES];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(userDefaultsChanged:)
												 name:NSUserDefaultsDidChangeNotification
											   object:[NSUserDefaults standardUserDefaults]];
	
	
	[[AlarmController sharedAlarmController] setupAlarm:self];
}

- (void)userDefaultsChanged:(NSNotification *)notification
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];

	if ([[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmOn] boolValue])
	{
		alarmBell.alpha = 1.0;
	} else {
		
		portraitAlarmBell.alpha = 0.0;
		alarmBell.alpha = 0.0;
		
	}
	
	[UIView commitAnimations];
}

/*- (void)didEnterBackground:(NSNotification *)notification
{
	if (self.timer)
	{
		[self.timer invalidate];
	}

	NSLog(@"did enter background!");
}

- (void)didBecomeActive:(NSNotification *)notification
{
	NSLog(@"did become active!");

	if (![timer isValid])
	{
		NSLog(@"revalidating the timer!");
		timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self
											   selector:@selector(updateClock:)
											   userInfo:nil repeats:YES];		
	} else {
		NSLog(@"it is valid already...");
	}
}
*/
- (void)viewWillAppear:(BOOL)animated
{	
	[super viewWillAppear:animated];
	
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmOn] boolValue])
	{
		portraitAlarmBell.alpha = 1.0;
		alarmBell.alpha = 1.0;
	} else {
		portraitAlarmBell.alpha = 0.0;
		alarmBell.alpha = 0.0;
	}

	/*if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation))
	{
		NSLog(@"it's portrait!");
	} else if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
	{
		NSLog(@"it's landscape!");
	} else if (!UIDeviceOrientationIsValidInterfaceOrientation([UIDevice currentDevice].orientation))
	{
		NSLog(@"it's not a valid orientation!");
	}*/
}

- (void)viewDidAppear:(BOOL)animated
{
	if (!alreadyFadedInClock)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:1.0];
		self.view.alpha = 1.0;
		[UIView commitAnimations];
		
		alreadyFadedInClock = YES;
	}
	
	NSString *deviceType = [UIDevice currentDevice].model;
	if([deviceType isEqualToString:@"iPhone"])
	{
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmOn] boolValue])
		{
			if (![[[NSUserDefaults standardUserDefaults] objectForKey:kHasShownBrightnessMessage] boolValue])
			{
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dimming the screen at night" message:@"You can dim the screen by double-tapping on it."
															   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
				[alert show];
				[alert release];
				
				[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kHasShownBrightnessMessage];			
			}
		}
	}
	
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	oldOrientation = self.interfaceOrientation;

	if (alarmPopoverController.popoverVisible)
	{
		if (alarmPopoverController.contentViewController.modalViewController)
		{
//			Sleep_Blaster_touchAppDelegate *mainDelegate = (Sleep_Blaster_touchAppDelegate *)[[UIApplication sharedApplication] delegate];
			[((MPMediaPickerController *)alarmPopoverController.contentViewController.modalViewController).delegate mediaPickerDidCancel:alarmPopoverController.contentViewController.modalViewController];
		}
		
		[alarmPopoverController dismissPopoverAnimated:YES];

		alarmPopoverWasVisibleBeforeRotation = YES;
	}
	
	[self.view setNeedsLayout];

}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	if (alarmPopoverWasVisibleBeforeRotation)
	{
		[alarmPopoverController presentPopoverFromRect:rightSettingsButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		alarmPopoverWasVisibleBeforeRotation = NO;
	}
}

- (void)positionSettingsButtons
{
	CGRect rightRect = rightSettingsButton.frame;
	if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) ||
		!UIDeviceOrientationIsValidInterfaceOrientation([UIDevice currentDevice].orientation))
	{
		rightRect.origin.x = [UIScreen mainScreen].bounds.size.width - rightRect.size.width - 10.0;
		rightRect.origin.y = [UIScreen mainScreen].bounds.size.height - rightRect.size.height - 10.0;
	} else {
		rightRect.origin.y = [UIScreen mainScreen].bounds.size.width - rightRect.size.width - 10.0;
		rightRect.origin.x = [UIScreen mainScreen].bounds.size.height - rightRect.size.height - 10.0;
		
	}
	rightSettingsButton.frame = rightRect;	
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	[self positionSettingsButtons];
}

- (void)setFontsForLabels
{
	
	UIFont *bigFont;
	UIFont *mediumFont;
	UIFont *smallFont;
	UIFont *smallerFont;
	
	UIColor *shadowColor = [UIColor colorWithRed:0.4 green:0.83 blue:0.9 alpha:0.7];
	hourLabel1.shadowColor = shadowColor;
	hourLabel2.shadowColor = shadowColor;
	minuteLabel1.shadowColor = shadowColor;
	minuteLabel2.shadowColor = shadowColor;
	colonLabel.shadowColor = shadowColor;
	secondLabel1.shadowColor = shadowColor;
	secondLabel2.shadowColor = shadowColor;
	
	[shadowColor release];
	shadowColor = [UIColor colorWithRed:0.29 green:0.75 blue:0.14 alpha:0.5];
	
	sunLabel.shadowColor = shadowColor;
	monLabel.shadowColor = shadowColor;
	tueLabel.shadowColor = shadowColor;
	wedLabel.shadowColor = shadowColor;
	thuLabel.shadowColor = shadowColor;
	friLabel.shadowColor = shadowColor;
	satLabel.shadowColor = shadowColor;
	amLabel.shadowColor = shadowColor;
	pmLabel.shadowColor = shadowColor;
	
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        // The device is an iPad running iPhone 3.2 or later.
		bigFont = [UIFont fontWithName:@"Digital-7" size:216.0];
		mediumFont = [UIFont fontWithName:@"Digital-7" size:108.0];
		smallFont = [UIFont fontWithName:@"Digital-7" size:42.0];
		smallerFont = [UIFont fontWithName:@"Digital-7" size:30.0];	
				
		
		hourLabel1.shadowBlur = 10.0;
		hourLabel2.shadowBlur = 10.0;		
		minuteLabel1.shadowBlur = 10.0;
		minuteLabel2.shadowBlur = 10.0;
		colonLabel.shadowBlur = 10.0;
		secondLabel1.shadowBlur = 10.0;
		secondLabel2.shadowBlur = 10.0;
			
    } else {
        // The device is an iPhone or iPod touch.
		bigFont = [UIFont fontWithName:@"Digital-7" size:93.0];
		mediumFont = [UIFont fontWithName:@"Digital-7" size:47.0];
		smallFont = [UIFont fontWithName:@"Digital-7" size:18.3];
		smallerFont = [UIFont fontWithName:@"Digital-7" size:13.0];		
    }

/*	portraitHourLabel1.font = bigFont;
	portraitHourLabel2.font = bigFont;
	portraitMinuteLabel1.font = bigFont;
	portraitMinuteLabel2.font = bigFont;
	portraitColonLabel.font = mediumFont;
	portraitSecondLabel1.font = mediumFont;
	portraitSecondLabel2.font = mediumFont;
	portraitSunLabel.font = smallerFont;
	portraitMonLabel.font = smallerFont;
	portraitTueLabel.font = smallerFont;
	portraitWedLabel.font = smallerFont;
	portraitThuLabel.font = smallerFont;
	portraitFriLabel.font = smallerFont;
	portraitSatLabel.font = smallerFont;
	portraitAmLabel.font = smallFont;
	portraitPmLabel.font = smallFont;	
*/

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        // The device is an iPad running iPhone 3.2 or later.
		bigFont = [UIFont fontWithName:@"Digital-7" size:288.0];
		mediumFont = [UIFont fontWithName:@"Digital-7" size:144.0];
		smallFont = [UIFont fontWithName:@"Digital-7" size:56];
		smallerFont = [UIFont fontWithName:@"Digital-7" size:40.0];				
    }
    else
#endif
    {
        // The device is an iPhone or iPod touch.
		bigFont = [UIFont fontWithName:@"Digital-7" size:144.0];
		mediumFont = [UIFont fontWithName:@"Digital-7" size:72.0];
		smallFont = [UIFont fontWithName:@"Digital-7" size:28.0];
		smallerFont = [UIFont fontWithName:@"Digital-7" size:20.0];
    }
	
	
	hourLabel1.font = bigFont;
	hourLabel2.font = bigFont;
	minuteLabel1.font = bigFont;
	minuteLabel2.font = bigFont;
	colonLabel.font = mediumFont;
	secondLabel1.font = mediumFont;
	secondLabel2.font = mediumFont;
	sunLabel.font = smallerFont;
	monLabel.font = smallerFont;
	tueLabel.font = smallerFont;
	wedLabel.font = smallerFont;
	thuLabel.font = smallerFont;
	friLabel.font = smallerFont;
	satLabel.font = smallerFont;
	amLabel.font = smallFont;
	pmLabel.font = smallFont;	
	
}

- (void)updateClock:(NSTimer *)theTimer
{
//	NSLog(@"update clock!");
	[self setCurrentDateAndTimeLabels];
}

- (void)setCurrentDateAndTimeLabels
{
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	
	if ([[[NSCalendar currentCalendar] locale] timeIs24HourFormat])
	{
		[dateFormatter setDateFormat:@"HH:mm:ss"];
	} else {
		[dateFormatter setDateFormat:@"h:mm:ss"];
	}
	
	NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
	
	// We'll go through this string backwards, and then check if the hour should be 1 or 2 digits.
	[portraitSecondLabel2 setText:[NSString stringWithFormat:@"%C", [currentTime characterAtIndex:[currentTime length]-1]]];
	[portraitSecondLabel1 setText:[NSString stringWithFormat:@"%C", [currentTime characterAtIndex:[currentTime length]-2]]];
	[portraitMinuteLabel2 setText:[NSString stringWithFormat:@"%C", [currentTime characterAtIndex:[currentTime length]-4]]];
	[portraitMinuteLabel1 setText:[NSString stringWithFormat:@"%C", [currentTime characterAtIndex:[currentTime length]-5]]];
	[portraitHourLabel2 setText:[NSString stringWithFormat:@"%C:", [currentTime characterAtIndex:[currentTime length]-7]]];

	[secondLabel2 setText:[NSString stringWithFormat:@"%C", [currentTime characterAtIndex:[currentTime length]-1]]];
	[secondLabel1 setText:[NSString stringWithFormat:@"%C", [currentTime characterAtIndex:[currentTime length]-2]]];
	[minuteLabel2 setText:[NSString stringWithFormat:@"%C", [currentTime characterAtIndex:[currentTime length]-4]]];
	[minuteLabel1 setText:[NSString stringWithFormat:@"%C", [currentTime characterAtIndex:[currentTime length]-5]]];
	[hourLabel2 setText:[NSString stringWithFormat:@"%C:", [currentTime characterAtIndex:[currentTime length]-7]]];
	if ([currentTime length] == 8) {
		[portraitHourLabel1 setText:[NSString stringWithFormat:@"%C", [currentTime characterAtIndex:0]]];
		[hourLabel1 setText:[NSString stringWithFormat:@"%C", [currentTime characterAtIndex:0]]];
	} else {
		[portraitHourLabel1 setText:@""];
		[hourLabel1 setText:@""];
	}

	NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[dateFormatter setLocale:usLocale];
	[usLocale release];
	[dateFormatter setDateFormat:@"e"];

	NSString *weekday = [dateFormatter stringFromDate:[NSDate date]];
	
//	portraitSunLabel.hidden = YES;
//	portraitMonLabel.hidden = YES;
//	portraitTueLabel.hidden = YES;
//	portraitWedLabel.hidden = YES;
//	portraitThuLabel.hidden = YES;
//	portraitFriLabel.hidden = YES;
//	portraitSatLabel.hidden = YES;

	sunLabel.hidden = YES;
	monLabel.hidden = YES;
	tueLabel.hidden = YES;
	wedLabel.hidden = YES;
	thuLabel.hidden = YES;
	friLabel.hidden = YES;
	satLabel.hidden = YES;
	
	if ([weekday isEqualToString:@"1"]) {
//		portraitSunLabel.hidden = NO;
		sunLabel.hidden = NO;
	} else if ([weekday isEqualToString:@"2"]) {
//		portraitMonLabel.hidden = NO;
		monLabel.hidden = NO;
	} else if ([weekday isEqualToString:@"3"]) {
//		portraitTueLabel.hidden = NO;
		tueLabel.hidden = NO;
	} else if ([weekday isEqualToString:@"4"]) {
//		portraitWedLabel.hidden = NO;
		wedLabel.hidden = NO;
	} else if ([weekday isEqualToString:@"5"]) {
//		portraitThuLabel.hidden = NO;
		thuLabel.hidden = NO;
	} else if ([weekday isEqualToString:@"6"]) {
//		portraitFriLabel.hidden = NO;
		friLabel.hidden = NO;
	} else if ([weekday isEqualToString:@"7"]) {
//		portraitSatLabel.hidden = NO;
		satLabel.hidden = NO;
	}

	[dateFormatter setDateFormat:@"a"];
	NSString *ampm = [dateFormatter stringFromDate:[NSDate date]];
	
//	portraitAmLabel.hidden = YES;
	amLabel.hidden = YES;
	
//	portraitPmLabel.hidden = YES;
	pmLabel.hidden = YES;
	
	if (![[[NSCalendar currentCalendar] locale] timeIs24HourFormat])
	{
		if ([ampm isEqualToString:@"AM"]) {
//			portraitAmLabel.hidden = NO;
			amLabel.hidden = NO;
		} else if ([ampm isEqualToString:@"PM"]) {
//			portraitPmLabel.hidden = NO;
			pmLabel.hidden = NO;
		}	
	}
}
/*
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	if ([viewController class] == [UINavigationController class])
	{ NSLog(@"navigation controller!");
	} else {
		NSLog(@"not a navigation controller");
	}
	NSLog(@"did show a view controller, resizing to %f, %f", viewController.view.frame.size.width, viewController.view.frame.size.height);
	[popoverController setPopoverContentSize:viewController.view.frame.size animated:NO];
}
*/
- (IBAction)infoButtonTapped:(id)sender
{
	Sleep_Blaster_touchAppDelegate *mainDelegate = (Sleep_Blaster_touchAppDelegate *)[[UIApplication sharedApplication] delegate];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        // The device is an iPad running iPhone 3.2 or later.
		if (!alarmPopoverController)
		{
//			alarmPopoverController = [[UIPopoverController alloc] initWithContentViewController:mainDelegate.alarmSettingsNavigationController];
			alarmPopoverController = [[UIPopoverController alloc] initWithContentViewController:mainDelegate.tabBarController];
			CGSize size = ((AlarmSettingsViewController *)[mainDelegate.alarmSettingsNavigationController.viewControllers objectAtIndex:0]).view.frame.size;
			size.height += 37.0;		// For some reason, only here, we have to add 37 pixels to the height. It has something to do with the navigation controller.
			size.width = 320.0;
			[alarmPopoverController setPopoverContentSize:size];
		}
		[alarmPopoverController presentPopoverFromRect:[sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        // The device is an iPhone or iPod touch.
		[mainDelegate flipToSettings];
    }
}

- (IBAction)sleepTimerButtonTapped:(id)sender
{
	Sleep_Blaster_touchAppDelegate *mainDelegate = (Sleep_Blaster_touchAppDelegate *)[[UIApplication sharedApplication] delegate];

	// The device is an iPad running iPhone 3.2 or later.
	if (!sleepTimerPopoverController)
	{
		sleepTimerPopoverController = [[UIPopoverController alloc] initWithContentViewController:mainDelegate.sleepTimerSettingsNavigationController];
		CGSize size = ((SleepTimerSettingsViewController *)[mainDelegate.sleepTimerSettingsNavigationController.viewControllers objectAtIndex:0]).view.frame.size;
		size.height += 37;		// For some reason, only here, we have to add 37 pixels to the height. It has something to do with the navigation controller.
		[sleepTimerPopoverController setPopoverContentSize:size];
	}

	[sleepTimerPopoverController presentPopoverFromRect:[sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	NSUInteger tapCount = [touch tapCount];
	switch (tapCount) {
		case 2:

			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:1.0];

			if (self.view.alpha == 1.0)
			{
				self.view.alpha = 0.25;
			} else {
				self.view.alpha = 1.0;
			}
			[UIView commitAnimations];
			
			break;
		default:
			break;
	}
}

// Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	 // Return YES for supported orientations
		
	 return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[alarmPopoverController release];
	[sleepTimerPopoverController release];
    [super dealloc];
}


@end
