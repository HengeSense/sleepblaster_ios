//
//  AlarmRingingViewController.h
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 8/15/09.
//  Copyright 2009 The Byte Factory. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AlarmRingingViewController : UIViewController {

	IBOutlet UILabel *currentTimeField;
	IBOutlet UIImageView *artworkImageView;
	IBOutlet UILabel *songLabel;
	IBOutlet UILabel *artistLabel;

	NSTimer *clockTimer;
}

- (IBAction)offButtonTapped:(id)sender;
- (IBAction)snoozeButtonTapped:(id)sender;
- (void)setSongTextAndAlbumArtwork:(NSNotification *)theNotification;
@end
