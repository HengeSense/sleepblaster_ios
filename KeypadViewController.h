//
//  KeypadViewController.h
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 7/14/10.
//  Copyright 2010 The Byte Factory. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface KeypadViewController : UIViewController {
	
	id delegate;

}

@property (nonatomic, assign) id delegate;


- (IBAction)enterDigit:(id)sender;
- (IBAction)clearDigits:(id)sender;
- (IBAction)doneButtonTapped:(id)sender;

@end
