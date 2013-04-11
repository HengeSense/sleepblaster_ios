//
//  SleepTimerSettingsViewController.h
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 1/29/10.
//  Copyright 2010 The Byte Factory. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ShadowedLabel.h"

@interface SleepTimerSettingsViewController : UIViewController <MPMediaPickerControllerDelegate, UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UISegmentedControl *segmentedControl;
	IBOutlet UIDatePicker *datePicker;
	IBOutlet UITableView *musicTableView;
	IBOutlet UITableView *timerTableView;
	IBOutlet UIButton *button;
	IBOutlet UIView *datePickerContainerView;
	IBOutlet UIView *artworkContainerView;
	IBOutlet UIImageView *artworkImageView;
	IBOutlet UILabel *timerLabel;
	IBOutlet UILabel *songLabel;
	IBOutlet UILabel *artistLabel;
	IBOutlet UINavigationBar *navigationBar;
	IBOutlet UIButton *previousButton;
	IBOutlet UIButton *nextButton;
	IBOutlet UISlider *volumeSlider;
	
	BOOL datePickerIsShowing;
	UITableViewCell *musicCell;
	ShadowedLabel *hourLabel2;
	ShadowedLabel *hourLabel1;
	ShadowedLabel *minuteLabel1;
	ShadowedLabel *minuteLabel2;
	
	int secondsLeftOnTimer;
}

//- (void)segmentedControlTapped:(id)sender;
- (void)setTimerString;
- (void)setSongArtworkAndLabels;
- (void)setButtonSegmentImages;
- (IBAction)nextSong:(id)sender;
- (IBAction)previousSong:(id)sender;

- (IBAction)setSleepTimerTime:(id)sender;
- (IBAction)toggleSleepTimer:(id)sender;
- (IBAction)chooseMusic: (id) sender;
- (IBAction)doneButtonTapped:(id)sender;
- (IBAction)buttonSegmentTapped:(UIButton *)sender;
- (IBAction)volumeSliderMoved:(UISlider *)sender;

- (void)showArtworkContainerView;
- (void)hideArtworkContainerView;

- (void)updateTimerLabel:(NSTimer *)theTimer;
- (void)setLabelInMusicCell;

- (IBAction)toggleDatePicker:(id)sender;

@property (nonatomic, retain) UITableViewCell *musicCell;

@end
