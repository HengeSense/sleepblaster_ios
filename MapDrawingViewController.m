    //
//  MapDrawingViewController.m
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 5/4/10.
//  Copyright 2010 The Byte Factory. All rights reserved.
//

#import "MapDrawingViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MapLinesAnnotation.h"
#import "Constants.h"
#import "AlarmController.h"


@implementation MapDrawingViewController


@synthesize locations;
@synthesize delegate;

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
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
	
	locations = [[NSMutableArray array] retain];	

	CGRect frame = CGRectMake(0, 44, 320, 480-(20+44+50));
	self.view.frame = frame;
	self.view.opaque = NO;
	self.view.backgroundColor = [UIColor clearColor];

	drawImage = [[UIImageView alloc] initWithImage:nil];
	drawImage.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
	[self.view addSubview:drawImage];
//	mouseMoved = 0;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	[self.locations removeAllObjects];
	
	mouseSwiped = NO;
	UITouch *touch = [touches anyObject];
	
	lastPoint = [touch locationInView:self.view];	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	mouseSwiped = YES;
	
	UITouch *touch = [touches anyObject];	
	CGPoint currentPoint = [touch locationInView:self.view];
		
//	MKMapView *mapView = self.view.superview;
	
	CLLocationCoordinate2D latAndLon = [[delegate mapView] convertPoint:currentPoint toCoordinateFromView:self.view];
	
	CLLocation *locationPoint = [[[CLLocation alloc] initWithLatitude:latAndLon.latitude longitude:latAndLon.longitude] autorelease];
	
	[locations addObject:locationPoint];

	UIGraphicsBeginImageContext(self.view.frame.size);
	[drawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 4.0);
	CGFloat lengths[1] = {4.0};
	CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0, lengths, 1);
	CGContextSetLineJoin(UIGraphicsGetCurrentContext(), kCGLineJoinRound);
	CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.6, 0.0, 0.2, 1.0);
	CGContextBeginPath(UIGraphicsGetCurrentContext());
	CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
	CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
	CGContextStrokePath(UIGraphicsGetCurrentContext());
	drawImage.image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	lastPoint = currentPoint;
	
/*	mouseMoved++;
	
	if (mouseMoved == 10) {
		mouseMoved = 0;
	}
*/}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
//	UITouch *touch = [touches anyObject];
	
	if(!mouseSwiped) {
		UIGraphicsBeginImageContext(self.view.frame.size);
		[drawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
		CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 4.0);
		CGFloat lengths[1] = {4.0};
		CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0, lengths, 1);
		CGContextSetLineJoin(UIGraphicsGetCurrentContext(), kCGLineJoinRound);
		CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.6, 0.0, 0.2, 1.0);
		CGContextBeginPath(UIGraphicsGetCurrentContext());
		CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
		CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
		CGContextStrokePath(UIGraphicsGetCurrentContext());
		drawImage.image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	}
	
	MapLinesAnnotation *annotation = [[[MapLinesAnnotation alloc] initWithPoints:locations] autorelease];
	
//	MKMapView *mapView = self.view.superview;
	[[delegate mapView] addAnnotation:annotation];
	[delegate saveLocationPointsArrayToUserDefaults:locations];
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:kAlarmMode];

	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kAlarmOn];
	[[AlarmController sharedAlarmController] setupAlarm:self];
	
	[self clearAndHideCanvas];
}

- (void)clearAndHideCanvas
{
	drawImage.image = nil;
	self.view.hidden = YES;
	
	[[delegate drawButton] setBackgroundImage:[UIImage imageNamed:@"redDrawButton.png"] forState:UIControlStateNormal];
}	

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
