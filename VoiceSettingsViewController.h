//
//  VoiceSettingsViewController.h
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 2/25/10.
//  Copyright 2010 The Byte Factory. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeypadViewController.h"
#import "ShadowedLabel.h"

@interface VoiceSettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView *tableView;
	IBOutlet UISegmentedControl *segmentedControl;
	IBOutlet UIView *keypadView;
	
	ShadowedLabel *playIntervalLabel;
	ShadowedLabel *pauseIntervalLabel;
	KeypadViewController *keypadViewController;
	
	BOOL keypadIsShowing;
	NSString *currentlyEditingDefault;
}

- (IBAction)buttonSegmentTapped:(id)sender;
- (void)setButtonSegmentImages;
- (void)switchFlipped:(UISwitch *)sender;
- (void)toggleKeypad:(id)sender;
- (IBAction)enterDigit:(id)sender;
- (IBAction)clearDigits:(id)sender;

@end
