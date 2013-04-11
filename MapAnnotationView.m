//
//  MapAnnotationView.m
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 4/10/10.
//  Copyright 2010 The Byte Factory. All rights reserved.
//

#import "MapAnnotationView.h"
#import "MapLinesAnnotation.h"

// this is an internally used view to CSRouteView. The CSRouteView needs a subview that does not get clipped to always
// be positioned at the full frame size and origin of the map. This way the view can be smaller than the route, but it
// always draws in the internal subview, which is the size of the map view. 
@interface MapAnnotationViewInternal : UIView
{
	// route view which added this as a subview. 
	MapAnnotationView* _annotationView;
}
@property (nonatomic, retain) MapAnnotationView *annotationView;

@end


@implementation MapAnnotationViewInternal

@synthesize annotationView = _annotationView;

-(id) init
{
	self = [super init];
	self.backgroundColor = [UIColor clearColor];
	self.clipsToBounds = NO;
	
	return self;
}


-(void) drawRect:(CGRect) rect
{
	// only draw our lines if we're not in the middle of a transition and we 
	// acutally have some points to draw.
	MapLinesAnnotation *annotation = (MapLinesAnnotation *)self.annotationView.annotation;
	if(!self.hidden && annotation.points && annotation.points.count > 0)
	{
		CGContextRef context = UIGraphicsGetCurrentContext();
		
		//		if(nil == routeAnnotation.lineColor)
		//			routeAnnotation.lineColor = [UIColor blueColor]; // setting the property instead of the member variable will automatically reatin it.
		
		CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.6, 0.0, 0.2, 1.0);
		CGFloat lengths[1] = {4.0};
		CGContextSetLineDash(UIGraphicsGetCurrentContext(), 0, lengths, 1);
		CGContextSetLineJoin(UIGraphicsGetCurrentContext(), kCGLineJoinRound);
		CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 4.0);
		
		for(int i = 0; i < [annotation.points count]; i++)
		{
			CLLocation* location = [annotation.points objectAtIndex:i];
			CGPoint point = [self.annotationView.mapView convertCoordinate:location.coordinate toPointToView:self];
//			point.y += 40;
			
			if(i == 0) 
			{
				// move to the first point
				CGContextMoveToPoint(context, point.x, point.y);
			} else {
				CGContextAddLineToPoint(context, point.x, point.y);
			}
		}
		CGContextStrokePath(context);
	}
}

-(void) dealloc
{
	self.annotationView = nil;
	
	[super dealloc];
}

@end







@implementation MapAnnotationView

@synthesize mapView;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
		self.backgroundColor = [UIColor clearColor];
		
		// do not clip the bounds. We need the MapAnnotationViewInternal to be able to render the route, regardless of where the
		// actual annotation view is displayed. 
		self.clipsToBounds = NO;
		
		// create the internal annotation view that does the rendering of the route. 
		_internalAnnotationView = [[MapAnnotationViewInternal alloc] init];
		_internalAnnotationView.annotationView = self;
		
		[self addSubview:_internalAnnotationView];
    }
    return self;
}


- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
	
	self.backgroundColor = [UIColor clearColor];
	self.opaque = NO;
	self.clipsToBounds = NO;
	
//	CGRect rect = CGRectMake(annotation.coordinate.longitude-(annotation.span.longitude/2), CGFloat y, CGFloat width, CGFloat height)
	self.frame = CGRectMake(0, 0, 320, 480);
	
	// create the internal annotation view that does the rendering of the route. 
	_internalAnnotationView = [[MapAnnotationViewInternal alloc] init];
	_internalAnnotationView.annotationView = self;
	
	[self addSubview:_internalAnnotationView];

	
	return self;
}

- (void)regionChanged
{	
	// move the internal route view. 
	CGPoint origin = CGPointMake(0, 0);
	origin = [mapView convertPoint:origin toView:self];
	
	_internalAnnotationView.frame = CGRectMake(origin.x, origin.y, mapView.frame.size.width, mapView.frame.size.height);
	[_internalAnnotationView setNeedsDisplay];
}

-(void) setMapView:(MKMapView*)newMapView
{
	[mapView release];
	mapView = [newMapView retain];
	
	[self regionChanged];
}


@end
