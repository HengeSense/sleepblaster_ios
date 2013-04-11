//
//  MapLinesAnnotation.m
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 4/10/10.
//  Copyright 2010 The Byte Factory. All rights reserved.
//

#import "MapLinesAnnotation.h"


@implementation MapLinesAnnotation

@synthesize points;
@synthesize coordinate = center;
@synthesize span;

- (id)initWithPoints:(NSArray *)thePoints
{
	self = [super init];
	
	points = [thePoints mutableCopy];
	
	// determine a logical center point for this route based on the middle of the lat/lon extents.
	double maxLat = -91;
	double minLat =  91;
	double maxLon = -181;
	double minLon =  181;
	
	for(CLLocation* currentLocation in points)
	{
		CLLocationCoordinate2D coordinate = currentLocation.coordinate;
		
		if(coordinate.latitude > maxLat)
			maxLat = coordinate.latitude;
		if(coordinate.latitude < minLat)
			minLat = coordinate.latitude;
		if(coordinate.longitude > maxLon)
			maxLon = coordinate.longitude;
		if(coordinate.longitude < minLon)
			minLon = coordinate.longitude; 
	}
	
	span.latitudeDelta = (maxLat + 90) - (minLat + 90);
	span.longitudeDelta = (maxLon + 180) - (minLon + 180);
	
	// the center point is the average of the max and mins
	center.latitude = minLat + span.latitudeDelta / 2;
	center.longitude = minLon + span.longitudeDelta / 2;
	
//	self.lineColor = [UIColor blueColor];
	NSLog(@"Found center of new Route Annotation at %lf, %lf", center.latitude, center.longitude);
	
	
	return self;
}

@end
