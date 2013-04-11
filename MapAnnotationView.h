//
//  MapAnnotationView.h
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 4/10/10.
//  Copyright 2010 The Byte Factory. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class MapAnnotationViewInternal;

@interface MapAnnotationView : MKAnnotationView {
	MKMapView *mapView;
	MapAnnotationViewInternal* _internalAnnotationView;

}

- (void)regionChanged;

@property (nonatomic, retain) MKMapView *mapView;

@end
