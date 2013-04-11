//
//  VoiceSettingsViewController.m
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 2/25/10.
//  Copyright 2010 The Byte Factory. All rights reserved.
//

#import "VoiceSettingsViewController.h"
#import "Constants.h"
#import "AlarmSettingsViewController.h"
#import "CustomUISwitch.h"
#import "Sleep_Blaster_touchAppDelegate.h"

@implementation VoiceSettingsViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (void)viewWillAppear:(BOOL)animated
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		CGSize size = {320, 540};
		self.contentSizeForViewInPopover = size;
	}
	[super viewWillAppear:animated];
}

- (void)viewDidLoad 
{
	[super viewDidLoad];
	
	keypadIsShowing = NO;
	
	[self setTitle:@"Voice Controls"];
	
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.rowHeight = 60;
    tableView.backgroundColor = [UIColor clearColor];
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		// The device is an iPad running iPhone 3.2 or later.
		[tableView setBackgroundView:nil];
		[tableView setBackgroundView:[[[UIView alloc] init] autorelease]];
	}	
	
	[self setButtonSegmentImages];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(userDefaultsChanged:)
												 name:NSUserDefaultsDidChangeNotification
											   object:[NSUserDefaults standardUserDefaults]];
}

- (void)setButtonSegmentImages
{
	int value = [[[NSUserDefaults standardUserDefaults] objectForKey:kVoiceFunction] intValue];
	if (value == 0)
	{
		[((UIButton *)[self.view viewWithTag:LEFT_BUTTON_SEGMENT]) setBackgroundImage:[UIImage imageNamed:@"segmentedControlSnoozeSelected.png"] 
															   forState:UIControlStateNormal];
		[((UIButton *)[self.view viewWithTag:RIGHT_BUTTON_SEGMENT]) setBackgroundImage:[UIImage imageNamed:@"segmentedControlStop.png"] 
															   forState:UIControlStateNormal];
		
	} else if (value == 1 ) {
		[((UIButton *)[self.view viewWithTag:LEFT_BUTTON_SEGMENT]) setBackgroundImage:[UIImage imageNamed:@"segmentedControlSnooze.png"] 
															   forState:UIControlStateNormal];
		[((UIButton *)[self.view viewWithTag:RIGHT_BUTTON_SEGMENT]) setBackgroundImage:[UIImage imageNamed:@"segmentedControlStopSelected.png"] 
																forState:UIControlStateNormal];
	}
}

- (IBAction)buttonSegmentTapped:(UIButton *)sender
{		
	if (sender.tag == LEFT_BUTTON_SEGMENT) 
	{
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] 
												  forKey:kVoiceFunction];
	} else if (sender.tag == RIGHT_BUTTON_SEGMENT) 
	{
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] 
												  forKey:kVoiceFunction];
	}	
	
	[self setButtonSegmentImages];
}

- (void)dealloc {
    [super dealloc];
}

- (void)switchFlipped:(UISwitch *)sender
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[sender isOn]] forKey:kEnableVoiceControls];
}

- (void)toggleKeypad:(id)sender
{
	if (keypadIsShowing)
	{
		// Get ready to move the keypadView out of visibility.
		CGRect keypadViewFrame = keypadViewController.view.frame;
	//	keypadViewFrame.origin.y += (KEYPAD_HEIGHT_MINUS_SHADOW + BOTTOMBAR_HEIGHT);
		keypadViewFrame.origin.y = self.view.frame.size.height;

		// Get ready to move the main view back down to fill the screen again.
		CGRect mainViewFrame = self.view.frame;
		mainViewFrame.origin.y += (KEYPAD_HEIGHT_MINUS_SHADOW - 75);

		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:1.0];
		
		self.view.frame = mainViewFrame;
		keypadViewController.view.frame = keypadViewFrame;
		
		[UIView commitAnimations];
		
		//[keypadView removeFromSuperview];		
		
		keypadIsShowing = NO;
	} else {
		// Add the keypadView as a subview, and stick it below the very bottom of the screen.
		if (!keypadViewController) {
			keypadViewController = [[[KeypadViewController alloc] initWithNibName:@"KeypadView" bundle:nil] retain];
			keypadViewController.delegate = self;
			
			[self.view.superview addSubview:keypadViewController.view];
		}
		
		CGRect keypadViewFrame = keypadViewController.view.frame;
//		keypadViewFrame.origin.y = 480 - MENUBAR_HEIGHT - 20;		// height of the screen minus the height of the menubar and the shadow
		keypadViewFrame.origin.y = self.view.frame.size.height;
		keypadViewController.view.frame = keypadViewFrame;

		// Get ready to move the keypadView into visibility.
//		keypadViewFrame.origin.y -= (KEYPAD_HEIGHT_MINUS_SHADOW + BOTTOMBAR_HEIGHT);
		keypadViewFrame.origin.y = self.view.frame.size.height - keypadViewFrame.size.height;
	
		// Get ready to move the main view up to make room for the keypadView.
		CGRect mainViewFrame = self.view.frame;
		mainViewFrame.origin.y -= (KEYPAD_HEIGHT_MINUS_SHADOW - 75);	// let the keyboard "catch up" an additional 80 pixels

		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:1.0];
		
		self.view.frame = mainViewFrame;
		keypadViewController.view.frame = keypadViewFrame;
		
		[UIView commitAnimations];
		
		keypadIsShowing = YES;
		
		if ([sender class] == [UITableViewCell class]) {
			if ([tableView indexPathForCell:sender].row == 1) {		// the sender was the "play interval" cell
				currentlyEditingDefault = kAlarmPlayInterval;
			} else if ([tableView indexPathForCell:sender].row == 2) {	// the sender was the "pause interval" cell
				currentlyEditingDefault = kAlarmPauseInterval;
			}		
		}
	}
}

- (IBAction)enterDigit:(id)sender
{
	int originalNumber = [[[NSUserDefaults standardUserDefaults] objectForKey:currentlyEditingDefault] intValue];
	
	int newNumber = originalNumber * 10 + ((UIButton *)sender).tag;
	if (newNumber >= 99) {
		newNumber = ((UIButton *)sender).tag;		// don't let it be more than two digits
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:newNumber] forKey:currentlyEditingDefault];
}

- (IBAction)clearDigits:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:currentlyEditingDefault];
}

- (void)userDefaultsChanged:(NSNotification *)notification
{		
	[playIntervalLabel setText:[[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmPlayInterval] stringValue]];
	[pauseIntervalLabel setText:[[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmPauseInterval] stringValue]];
}

#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;	
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 3;
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

//	CGRect borderFrame;
//	NSString *numberString;
	
	if ([indexPath row] == 0) {
		[cell.textLabel setText:@"Voice Controls"];
		
		CustomUISwitch *onSwitch = [AlarmSettingsViewController createSwitch];
		CGRect newRect = onSwitch.frame;
		newRect.origin.y = (tableView.rowHeight/2)-(newRect.size.height/2);
		onSwitch.frame = newRect;
		
		[onSwitch addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
		[onSwitch setOn:[[[NSUserDefaults standardUserDefaults] objectForKey:kEnableVoiceControls] boolValue] animated:YES];
		
		[cell.contentView addSubview:onSwitch];
		
	} else if ([indexPath row] == 1) {
		
		[cell.textLabel setText:@"Seconds to play"];
		
//		UIImageView *borderImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(250.0, (tableView.rowHeight/2)-(27.0/2), 26.0, 27.0)] autorelease];
//		[borderImageView setImage:[UIImage imageNamed:@"numberWell.png"]];
//		[cell.contentView addSubview:borderImageView];

		UIImage *blackScreen = [UIImage imageNamed:@"blackScreen.png"];
		UIImageView *borderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(195.0, (tableView.rowHeight/2)-(blackScreen.size.height/2), blackScreen.size.width, blackScreen.size.height)];
		[borderImageView setImage:blackScreen];
		[cell.contentView addSubview:borderImageView];
		
//		playIntervalLabel = [[[UILabel alloc] initWithFrame:CGRectMake(250.0, (tableView.rowHeight/2)-(27.0/2), 26.0, 27.0)] autorelease];
//		playIntervalLabel.textAlignment = UITextAlignmentCenter;
//		playIntervalLabel.font = [UIFont boldSystemFontOfSize:14.0];
//		playIntervalLabel.textColor = [UIColor colorWithRed:.69 green:.90 blue:.98 alpha:1];
//		playIntervalLabel.backgroundColor = [UIColor clearColor];
//		[playIntervalLabel setText:[[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmPlayInterval] stringValue]];
//		[cell.contentView addSubview:playIntervalLabel];
			
		playIntervalLabel = [[ShadowedLabel alloc] initWithFrame:CGRectMake(borderImageView.frame.origin.x+borderImageView.frame.size.width/2-100.0/2, (tableView.rowHeight/2)-(27.0/2), 100.0, 27.0)];
		playIntervalLabel.textAlignment = UITextAlignmentCenter;
		playIntervalLabel.font = [UIFont boldSystemFontOfSize:12.0];
		playIntervalLabel.textColor = [UIColor colorWithRed:.72 green:.91 blue:1.0 alpha:1.0];
		playIntervalLabel.shadowColor = [UIColor colorWithRed:0.0 green:.52 blue:1.0 alpha:.9];
		playIntervalLabel.shadowBlur = 10.0;
		playIntervalLabel.backgroundColor = [UIColor clearColor];
		[playIntervalLabel setText:[[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmPlayInterval] stringValue]];
		[cell.contentView addSubview:playIntervalLabel];
		
		[playIntervalLabel release];
		[borderImageView release];		
		
	} else if ([indexPath row] == 2) {
		[cell.textLabel setText:@"Seconds to pause"];
		
//		UIImageView *borderImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(250.0, 9.0, 26.0, 27.0)] autorelease];
//		[borderImageView setImage:[UIImage imageNamed:@"numberWell.png"]];
//		[cell.contentView addSubview:borderImageView];
		
		UIImage *blackScreen = [UIImage imageNamed:@"blackScreen.png"];
		UIImageView *borderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(195.0, (tableView.rowHeight/2)-(blackScreen.size.height/2), blackScreen.size.width, blackScreen.size.height)];
		[borderImageView setImage:blackScreen];
		[cell.contentView addSubview:borderImageView];
		
//		pauseIntervalLabel = [[[UILabel alloc] initWithFrame:CGRectMake(250.0, 9.0, 26.0, 27.0)] autorelease];
//		pauseIntervalLabel.textAlignment = UITextAlignmentCenter;
//		pauseIntervalLabel.font = [UIFont boldSystemFontOfSize:14.0];
//		pauseIntervalLabel.textColor = [UIColor colorWithRed:.69 green:.90 blue:.98 alpha:1];
//		pauseIntervalLabel.backgroundColor = [UIColor clearColor];
//		[pauseIntervalLabel setText:[[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmPauseInterval] stringValue]];
//		[cell.contentView addSubview:pauseIntervalLabel];
		
		pauseIntervalLabel = [[ShadowedLabel alloc] initWithFrame:CGRectMake(borderImageView.frame.origin.x+borderImageView.frame.size.width/2-100.0/2, (tableView.rowHeight/2)-(27.0/2), 100.0, 27.0)];
		pauseIntervalLabel.textAlignment = UITextAlignmentCenter;
		pauseIntervalLabel.font = [UIFont boldSystemFontOfSize:12.0];
		pauseIntervalLabel.textColor = [UIColor colorWithRed:.72 green:.91 blue:1.0 alpha:1.0];
		pauseIntervalLabel.shadowColor = [UIColor colorWithRed:0.0 green:.52 blue:1.0 alpha:.9];
		pauseIntervalLabel.shadowBlur = 10.0;
		pauseIntervalLabel.backgroundColor = [UIColor clearColor];
		[pauseIntervalLabel setText:[[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmPauseInterval] stringValue]];
		[cell.contentView addSubview:pauseIntervalLabel];
		
	}
	
	UIImage *rowBackground;
	UIImage *selectionBackground;
	NSInteger row = [indexPath row];
//	NSInteger section = [indexPath section];

//	NSString *backgroundImageName = @"";
//	NSString *selectedBackgroundImageName = @"";
//
//	if (!(section == tableView.numberOfSections-1 && row == [tableView numberOfRowsInSection:section]-1))
//	{
//		backgroundImageName = @"lightRow.png";
//		selectedBackgroundImageName = @"lightRow.png";
//	}
		
	if (row == 0)
	{
		rowBackground = [UIImage imageNamed:@"lightRowTop.png"];
		selectionBackground = [UIImage imageNamed:@"lightRowTop.png"];
	} else {
		rowBackground = [UIImage imageNamed:@"lightRow.png"];
		selectionBackground = [UIImage imageNamed:@"lightRow.png"];
	}
	
//	NSString *backgroundImageName = [NSString stringWithFormat:@"vcTableRow%d.png", row];
//	NSString *selectedBackgroundImageName = [NSString stringWithFormat:@"vcTableRow%dSelected.png", row];
	
//	rowBackground = [UIImage imageNamed:backgroundImageName];
//	selectionBackground = [UIImage imageNamed:selectedBackgroundImageName];
	
	UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 250, 50)];
	UIImageView *selectedBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 250, 50)];
	backgroundImageView.image = rowBackground;
	selectedBackgroundImageView.image = selectionBackground;
	
	[cell setBackgroundView:backgroundImageView];
	[cell setSelectedBackgroundView:selectedBackgroundImageView];
	
	return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSIndexPath *)tableView:(UITableView *)aTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 1 || indexPath.row == 2) {
		[self toggleKeypad:[tableView cellForRowAtIndexPath:indexPath]];
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

@end
