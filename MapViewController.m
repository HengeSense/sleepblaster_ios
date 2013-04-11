//
//  MapViewController.m
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 4/10/10.
//  Copyright 2010 The Byte Factory. All rights reserved.
//

#import "MapViewController.h"
#import "MapAnnotationView.h"
#import "MapLinesAnnotation.h"
#import <AudioToolbox/AudioToolbox.h>
#import "Constants.h"
#import "AlarmController.h"
#import "Sleep_Blaster_touchAppDelegate.h"

@implementation MapViewController

@synthesize mapView;
@synthesize locationManager;
@synthesize drawButton;
@synthesize drawingViewController;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{	
	if ([annotation class] == [MKUserLocation class])
	{
		return nil;
	}
	
    static NSString *AnnotationViewID = @"annotationViewID";
	
    MapAnnotationView *annotationView =
	(MapAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    if (annotationView == nil)
    {
		annotationView = [[[MapAnnotationView alloc] initWithFrame:CGRectMake(0, 0, mapView.frame.size.width, mapView.frame.size.height)] autorelease];
		
		annotationView.annotation = annotation;
		annotationView.mapView = mapView;
    }
    
    annotationView.annotation = annotation;
		
    return annotationView;
}

- (void)saveLocationPointsArrayToUserDefaults:(NSArray *)arrayOfLocations
{
	NSMutableArray *arrayOfNumbers = [NSMutableArray array];
	for (int i = 0; i < arrayOfLocations.count; i++)
	{
		NSNumber *latitude = [NSNumber numberWithDouble:((CLLocation *)[arrayOfLocations objectAtIndex:i]).coordinate.latitude];
		NSNumber *longitude = [NSNumber numberWithDouble:((CLLocation *)[arrayOfLocations objectAtIndex:i]).coordinate.longitude];
		
		[arrayOfNumbers addObject:latitude];
		[arrayOfNumbers addObject:longitude];
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:arrayOfNumbers forKey:kLocationPoints];
//	NSLog(@"Saved: %@", [[[NSUserDefaults standardUserDefaults] objectForKey:kLocationPoints] description]);
//	NSLog(@"saved %d numbers", arrayOfNumbers.count);
}

- (NSArray *)restoreLocationPointsArrayFromUserDefaults
{
	NSArray *arrayOfNumbers = [[NSUserDefaults standardUserDefaults] objectForKey:kLocationPoints];
	NSMutableArray *arrayOfLocations = [NSMutableArray array];
	
	for (int i = 0; i < arrayOfNumbers.count; i+=2)
	{
		CLLocation *location = [[CLLocation alloc] initWithLatitude:[[arrayOfNumbers objectAtIndex:i] doubleValue] 
																  longitude:[[arrayOfNumbers objectAtIndex:i+1] doubleValue]];
		[arrayOfLocations addObject:location];
		[location release];
	}
	
	return arrayOfLocations;
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
	float versionNumber = [[UIDevice currentDevice].systemVersion floatValue];
	
	
	//if (!((Sleep_Blaster_touchAppDelegate *)[[UIApplication sharedApplication] delegate]).backgroundSupported)
	if (versionNumber < 4 && UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
	{
		if (!animated) {
//			NSLog(@"not centered anymore");
			shouldFollowCurrentLocation = NO;
			[userLocationTimer invalidate];
			[currentLocationButton setBackgroundImage:[UIImage imageNamed:@"currentLocation.png"] forState:UIControlStateNormal];
		}
	} else {
		if (!centeredMapOnCurrentLocation) {
//			NSLog(@"not centered anymore");
			shouldFollowCurrentLocation = NO;
			[userLocationTimer invalidate];
			[currentLocationButton setBackgroundImage:[UIImage imageNamed:@"currentLocation.png"] forState:UIControlStateNormal];
		}
	}
	
	centeredMapOnCurrentLocation = NO;		

}

- (void)mapView:(MKMapView *)theMapView regionDidChangeAnimated:(BOOL)animated
{	
	// Tell each _map lines_ annotation view (although there's probably only one) that the region changed, so it knows to redraw itself.
	for (int i = 0; i < theMapView.annotations.count; i++)
	{
		NSObject* annotation = [theMapView.annotations objectAtIndex:i];
		if ([annotation class] == [MapLinesAnnotation class]) 
		{
			[[theMapView viewForAnnotation:annotation] regionChanged];
		}
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];

	self.locationManager = [[[CLLocationManager alloc] init] autorelease];
	[locationManager retain];
	self.locationManager.delegate = self;
	
	NSArray *locations = [self restoreLocationPointsArrayFromUserDefaults];
	if ([locations count] > 0)
	{
		MapLinesAnnotation *annotation = [[[MapLinesAnnotation alloc] initWithPoints:[locations mutableCopy]] autorelease];
		[mapView addAnnotation:annotation];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(willResignActive:)
												 name:UIApplicationWillResignActiveNotification
											   object:[NSUserDefaults standardUserDefaults]];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(didBecomeActive:)
												 name:UIApplicationDidBecomeActiveNotification
											   object:[NSUserDefaults standardUserDefaults]];
	shouldFollowCurrentLocation = NO;
	centeredMapOnCurrentLocation = NO;
	//withinCloseProximity = NO;
	usingSignificantChangesOnly = NO;
}

- (void)willResignActive:(NSNotification *)notification
{
//	if (!withinCloseProximity) {
		self.mapView.showsUserLocation = NO;
//		[locationManager stopUpdatingLocation];
//	}
}

- (void)didBecomeActive:(NSNotification *)notification
{
//	[locationManager startUpdatingLocation];		
	self.mapView.showsUserLocation = YES;
}

- (void)startTrackingLocation
{
	usingSignificantChangesOnly = NO;
	[self.locationManager startUpdatingLocation];
}

- (void)stopTrackingLocation
{
	[self.locationManager stopUpdatingLocation];
	
	if ([CLLocationManager respondsToSelector:@selector(significantLocationChangeMonitoringAvailable)] &&
		[CLLocationManager significantLocationChangeMonitoringAvailable])
	{		
		[self.locationManager stopMonitoringSignificantLocationChanges];
	}
	usingSignificantChangesOnly = NO;
}

/*- (void)monitorForLineRegion
{
	NSLog(@"gonna try to monitor the region!");
	
	if ([CLLocationManager regionMonitoringAvailable])
	{
		CLLocationCoordinate2D coordinate;
		MKCoordinateSpan span;
		for (int i = 0; i < mapView.annotations.count; i++)
		{
			NSObject <MKAnnotation> *annotation = [mapView.annotations objectAtIndex:i];
			if ([annotation class] == [MapLinesAnnotation class])
			{
				coordinate = annotation.coordinate;
				span = ((MapLinesAnnotation *)annotation).span;
			}
		}
		
		CLLocationDistance radius;
		if (span.latitudeDelta > span.longitudeDelta)
		{
			radius = span.latitudeDelta/2 * 111000;
		} else {
			radius = span.longitudeDelta/2 * 111000;
		}
		
		CLRegion *region = [CLRegion initCircularRegionWithCenter:coordinate radius:radius identifier:@"line"];
		[locationManager startMonitoringForRegion:region desiredAccuracy:kCLLocationAccuracyNearestTenMeters];	
		NSLog(@"just started monitoring for region!");
	}
}


- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
	NSLog(@"did enter region!");
	[locationManager startUpdatingLocation];
}
*/

- (void)viewWillAppear:(BOOL)animated
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		CGSize size = {320, 540};
		self.contentSizeForViewInPopover = size;
	}
}

- (void)viewDidAppear:(BOOL)animated
{
//	NSLog(@"map view did appear!");
	if (locationManager.locationServicesEnabled/* && [CLLocationManager significantLocationChangeMonitoringAvailable]*/)
	{
		[locationManager startUpdatingLocation];		
		self.mapView.showsUserLocation = YES;
	}
	
	if (![[[NSUserDefaults standardUserDefaults] objectForKey:kHasShownDrawingMessage] boolValue])
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Drawing on the map" message:@"Tap the red button to draw a line or a shape anywhere on the map that you would like to wake up. When you cross the line, the alarm will go off!"
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alert show];
		[alert release];	
		
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kHasShownDrawingMessage];
	}
}

- (void)viewDidDisappear:(BOOL)animated
{
	self.mapView.showsUserLocation = NO;
	if (![[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmOn] boolValue])
	{
		//[locationManager stopUpdatingLocation];
		[self stopTrackingLocation];
	}/* else if (!withinCloseProximity) {
		[locationManager stopUpdatingLocation];
	}
*/
}

- (IBAction)toggleDrawingView:(id)sender
{
	if (!self.drawingViewController)		// by adding the drawing view we automatically show it
	{
		[drawButton setBackgroundImage:[UIImage imageNamed:@"redDrawButtonPressed.png"] forState:UIControlStateNormal];
		for (int i = 0; i < mapView.annotations.count; i++)
		{
			NSObject <MKAnnotation> *annotation = [mapView.annotations objectAtIndex:i];
			if ([annotation class] == [MapLinesAnnotation class])
			{
				[mapView removeAnnotation:annotation];
			}
		}
		self.drawingViewController = [[MapDrawingViewController alloc] init];
		self.drawingViewController.delegate = self;
//		self.drawingViewController.view.frame = frame;
//		self.drawingViewController.view.backgroundColor = [UIColor blueColor];
//		self.drawingViewController.view = [[UIView alloc] initWithFrame:mapView.frame];
//		[self.mapView addSubview:drawingViewController.view];
		[self.view addSubview:drawingViewController.view];

	} else {
		
		if (self.drawingViewController.view.hidden)
		{
			self.drawingViewController.view.hidden = NO;
			[drawButton setBackgroundImage:[UIImage imageNamed:@"redDrawButtonPressed.png"] forState:UIControlStateNormal];
			
			for (int i = 0; i < mapView.annotations.count; i++)
			{
				NSObject <MKAnnotation> *annotation = [mapView.annotations objectAtIndex:i];
				if ([annotation class] == [MapLinesAnnotation class])
				{
					[mapView removeAnnotation:annotation];
				}
			}
		} else {
			[drawingViewController clearAndHideCanvas];
		}
	}
}

- (IBAction)centerOnCurrentLocation:(id)sender
{
	if (sender == currentLocationButton &&		// if the user clicked the button when it's already on, turn it off.
		shouldFollowCurrentLocation)
	{
		[currentLocationButton setBackgroundImage:[UIImage imageNamed:@"currentLocation.png"] forState:UIControlStateNormal];
		centeredMapOnCurrentLocation = NO;
		shouldFollowCurrentLocation = NO;
		[userLocationTimer invalidate];
		
	} else {		// otherwise,  the user is turning it on.
		[currentLocationButton setBackgroundImage:[UIImage imageNamed:@"currentLocationGlowing.png"] forState:UIControlStateNormal];
		centeredMapOnCurrentLocation = YES;
		shouldFollowCurrentLocation = YES;
		
//		MKCoordinateSpan span = MKCoordinateSpanMake(.004, .004);
//		MKCoordinateRegion region = MKCoordinateRegionMake(mapView.userLocation.location.coordinate, span);
//		[mapView setRegion:region animated:YES];
		
		userLocationTimer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(scheduledCenterOnCurrentLocation:) userInfo:nil repeats:YES];
		[userLocationTimer retain];
		
	//	[mapView setCenterCoordinate:mapView.userLocation.location.coordinate animated:YES];
	}
}

- (void)scheduledCenterOnCurrentLocation:(NSTimer *)timer
{
//	NSLog(@"scheduled center");
	if (!self.mapView.showsUserLocation)
	{
		centeredMapOnCurrentLocation = NO;
		shouldFollowCurrentLocation = NO;
		[userLocationTimer invalidate];
		
		return;
	}
	
	if (shouldFollowCurrentLocation)
	{
//		NSLog(@"should follow");
		centeredMapOnCurrentLocation = YES;
		
		MKCoordinateSpan span = MKCoordinateSpanMake(.004, .004);
		MKCoordinateRegion region = MKCoordinateRegionMake(mapView.userLocation.location.coordinate, span);
		[mapView setRegion:region animated:YES];
	
	}	
}

- (IBAction)centerOnLine:(id)sender
{
	CLLocationCoordinate2D coordinate;
	MKCoordinateSpan span;
	for (int i = 0; i < mapView.annotations.count; i++)
	{
		NSObject <MKAnnotation> *annotation = [mapView.annotations objectAtIndex:i];
		if ([annotation class] == [MapLinesAnnotation class])
		{
			coordinate = annotation.coordinate;
			span = ((MapLinesAnnotation *)annotation).span;
		}
	}
	
	if (span.latitudeDelta && span.longitudeDelta) {
		MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
		[mapView setRegion:region animated:YES];
	}
}

#define PI 3.141592653589793238462643

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	NSLog(@"updated location");

	if (![[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmOn] boolValue] ||
		[[[NSUserDefaults standardUserDefaults] objectForKey:kAlarmMode] intValue] != 1 ||
		!mapView.annotations.count)
	{
		return;
	}
	
	// loop through each annotation....
	for (int i = 0; i < mapView.annotations.count; i++)
	{
		NSObject* annotation = [mapView.annotations objectAtIndex:i];
		// ...and then check to make sure it's a MapLinesAnnotation.
		if ([annotation class] == [MapLinesAnnotation class])
		{
			if (((MapLinesAnnotation *)annotation).points.count)
			{
				BOOL notInProximityOfAnything = YES;
				
				for (int i = 0; i < ((MapLinesAnnotation *)annotation).points.count-1; i++)
				{
					CLLocation *location1 = [((MapLinesAnnotation *)annotation).points objectAtIndex:i];
					CLLocation *location2 = [((MapLinesAnnotation *)annotation).points objectAtIndex:i+1];

					// Create an arbitrary point somewhere above point1. 
					// We'll use this point to convert the geographical distance of the error bound into pixel distance.
					CLLocationCoordinate2D errorBoundLocation = location1.coordinate;
					CLLocationCoordinate2D proximityLocation = location1.coordinate;
					
					errorBoundLocation.latitude += .00090; // add .00090 degree to the latitude, or about 100 meters.
					proximityLocation.latitude += .07; // add .07 degree to the latitude, or about 8 kilometers.
					
					// Convert the geogrpahical points to pixel coordinates, because the distance between longitudes varies depending on where you are on the earth.
					CGPoint point1 = [mapView convertCoordinate:location1.coordinate toPointToView:mapView];
					CGPoint point2 = [mapView convertCoordinate:location2.coordinate toPointToView:mapView];
					CGPoint errorBoundPoint = [mapView convertCoordinate:errorBoundLocation toPointToView:mapView];
					CGPoint proximityPoint = [mapView convertCoordinate:proximityLocation toPointToView:mapView];
					CGPoint currentLocation = [mapView convertCoordinate:newLocation.coordinate toPointToView:mapView];

//					MKMapPoint point1 = MKMapPointForCoordinate(location1.coordinate);
//					MKMapPoint point2 = MKMapPointForCoordinate(location2.coordinate);
//					MKMapPoint errorBoundPoint = MKMapPointForCoordinate(errorBoundLocation);
//					MKMapPoint currentLocation = MKMapPointForCoordinate(newLocation.coordinate);
					
					double x = currentLocation.x;
//					double y = currentLocation.y;
					
					// Now convert everything to a cartesian coordinate system, with the origin being in the bottom left corner.
					double y = mapView.frame.size.height-currentLocation.y;
					point1.y = mapView.frame.size.height-point1.y;
					point2.y = (mapView.frame.size.height-point2.y);
					double errorBound = (mapView.frame.size.height-errorBoundPoint.y) - point1.y;
					double proximity = (mapView.frame.size.height-proximityPoint.y) - point1.y;
					
					// Define some math variables. We'll really only use x, y, m, b, and db in the final equation though.
					double dy = point2.y-point1.y;
					double dx = point2.x-point1.x;
					if (dx == 0)
						dx = .0000000000001;		// don't let dx equal zero, but instead set it to some number that's very close to zero.
					double m = dy/dx;
					double b = (point1.y-m*point1.x);
					double angle = (PI/2)-atan(m);
					double db = errorBound/sin(angle);
					double proximityDB = proximity/sin(angle);
					
					if (((point1.x - proximity) < x && x < (point2.x + proximity)) || ((point2.x - proximity) < x && x < (point1.x + proximity)))
					{
						if (fabs(m*x + b - y) < proximityDB)
						{
								// we're within proximity.
							
							if (((point1.x - errorBound) < x && x < (point2.x + errorBound)) || ((point2.x - errorBound) < x && x < (point1.x + errorBound)))
							{
								if (fabs(m*x + b - y) < db)
								{
									// we're on the line!
									
										
										[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kAlarmOn];
										[[AlarmController sharedAlarmController] setOffAlarm:nil];
										
									break;
								}
							}
							
							notInProximityOfAnything = NO;
							if ([CLLocationManager respondsToSelector:@selector(significantLocationChangeMonitoringAvailable)] &&
								[CLLocationManager significantLocationChangeMonitoringAvailable])
							{
	//							NSLog(@"it can use significant changes!");
								if (usingSignificantChangesOnly)
								{
									[locationManager stopMonitoringSignificantLocationChanges];
									[locationManager startUpdatingLocation];
									usingSignificantChangesOnly = NO;
									//withinCloseProximity = YES;
								}
							}
						}
					}
				}		// end of the loop here
				
				if (notInProximityOfAnything)
				{
					//withinCloseProximity = NO;
					if ([CLLocationManager respondsToSelector:@selector(significantLocationChangeMonitoringAvailable)] &&
						[CLLocationManager significantLocationChangeMonitoringAvailable])
					{
//						NSLog(@"it can use significant changes!");
						if (!usingSignificantChangesOnly && !self.mapView.showsUserLocation)
						{
	//						NSLog(@"switching to significant changes only...");
							[locationManager stopUpdatingLocation];
							[locationManager startMonitoringSignificantLocationChanges];
							usingSignificantChangesOnly = YES;
						}
					}
				}
			}
		}
	}
}

#define degreesToRadian(x) (M_PI * x / 180.0)

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
//    [super didReceiveMemoryWarning];
    
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
