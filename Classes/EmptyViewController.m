    //
//  EmptyViewController.m
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 9/9/10.
//  Copyright 2010 The Byte Factory. All rights reserved.
//

#import "EmptyViewController.h"


@implementation EmptyViewController

- (id)init
{
	self = [super init];
	
	self.view = [[UIView alloc] initWithFrame:CGRectMake(-50, -50, 350, 500)];
	self.view.backgroundColor = [UIColor whiteColor];
	
	return self;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
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
