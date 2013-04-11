//
//  KeypadViewController.m
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 7/14/10.
//  Copyright 2010 The Byte Factory. All rights reserved.
//

#import "KeypadViewController.h"


@implementation KeypadViewController

@synthesize delegate;

- (IBAction)clearDigits:(id)sender
{
	[delegate clearDigits:sender];
}

- (IBAction)enterDigit:(id)sender
{
	[delegate enterDigit:sender];
}

- (IBAction)doneButtonTapped:(id)sender
{
	[delegate toggleKeypad:sender];
}

- (void)viewDidAppear:(BOOL)animated
{
	CGRect frame = self.view.frame;
	frame.origin.y = 400;
	self.view.frame = frame;
	
	NSLog(@"y: %f", self.view.frame.origin.y);
	
}

- (void)viewDidLoad
{
	CGRect frame = self.view.frame;
	frame.origin.y = 400;
	self.view.frame = frame;
		
	NSLog(@"loaded the keypad");
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
