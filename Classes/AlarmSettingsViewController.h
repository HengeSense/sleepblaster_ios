//
//  SecondViewController.h
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 6/14/09.
//  Copyright 2009 The Byte Factory. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import <UIKit/UIKit.h>
#import "CustomUISwitch.h"
#import "ShadowedLabel.h"
#import "MapViewController.h"
#import "KeypadViewController.h"

@interface AlarmSettingsViewController : UIViewController <MPMediaPickerControllerDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate> {
	IBOutlet UIDatePicker *alarmDatePicker;
	IBOutlet UIView *alarmDatePickerContainerView;
	IBOutlet UITableView *tableView;
	IBOutlet UINavigationBar *navigationBar;
	IBOutlet UILabel *amountOfTimeLabel;
	CustomUISwitch *alarmSwitch;
	UITableViewCell *musicCell;
	KeypadViewController *keypadViewController;
//NSTimeZone *oldTimeZone;
	ShadowedLabel *hourLabel2;
	ShadowedLabel *hourLabel1;
	ShadowedLabel *minuteLabel1;
	ShadowedLabel *minuteLabel2;
	ShadowedLabel *ampmLabel;
	
	BOOL datePickerIsShowing;
}

- (void)toggleKeypad:(id)sender;
- (IBAction)enterDigit:(id)sender;
- (IBAction)clearDigits:(id)sender;

- (IBAction)buttonSegmentTapped:(UIButton *)sender;
- (IBAction)toggleDatePicker:(id)sender;
- (IBAction)setAlarmDateInDatePicker:(id)sender;
- (IBAction)chooseMusic:(id)sender;

- (void)setWakeupTimeLabel;
//- (void)alarmDidStartRinging;
- (void)setLabelInMusicCell;
- (void)setButtonSegmentImages;

- (NSString *) deviceModel;

- (IBAction)pushVoiceControls:(id)sender;
- (IBAction)pushMapView:(id)sender;

- (UIButton *) getDetailDiscolosureIndicatorForIndexPath: (NSIndexPath *) indexPath;
+ (CustomUISwitch *) createSwitch;
+ (UILabel *) createLabel;
+ (ShadowedLabel *)createDigitLabel;
//- (CGSize)requiredSizeForTableView;

@property (nonatomic, retain) UITableViewCell *musicCell;
@property (nonatomic, retain) KeypadViewController *keypadViewController;
@property (nonatomic, retain) UITableView *tableView;

@end
