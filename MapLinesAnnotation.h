//
//  MapLinesAnnotation.h
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 4/10/10.
//  Copyright 2010 The Byte Factory. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapLinesAnnotation : NSObject <MKAnnotation> {
	NSMutableArray* points; 
	CLLocationCoordinate2D center;
	MKCoordinateSpan span;
}

- (id)initWithPoints:(NSArray *)thePoints;

@property (nonatomic, retain) NSMutableArray* points;
@property (assign) MKCoordinateSpan span;

@end
