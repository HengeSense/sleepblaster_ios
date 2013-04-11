//
//  MapViewController.h
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 4/10/10.
//  Copyright 2010 The Byte Factory. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MapDrawingViewController.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate> {

	IBOutlet MKMapView *mapView;
	IBOutlet UIButton *drawButton;
	IBOutlet UIButton *currentLocationButton;
	CLLocationManager *locationManager;
	MapDrawingViewController *drawingViewController;
	BOOL centeredMapOnCurrentLocation;
	BOOL shouldFollowCurrentLocation;
	BOOL withinCloseProximity;
	BOOL usingSignificantChangesOnly;
	NSTimer *userLocationTimer;
}

- (IBAction)toggleDrawingView:(id)sender;
- (IBAction)centerOnCurrentLocation:(id)sender;
- (IBAction)centerOnLine:(id)sender;
- (void)saveLocationPointsArrayToUserDefaults:(NSArray *)array;
- (NSArray *)restoreLocationPointsArrayFromUserDefaults;
//- (void)monitorForLineRegion;

- (void)startTrackingLocation;
- (void)stopTrackingLocation;

@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) MapDrawingViewController *drawingViewController;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) IBOutlet UIButton *drawButton;

@end
