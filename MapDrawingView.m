//
//  MapDrawingView.m
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 4/10/10.
//  Copyright 2010 The Byte Factory. All rights reserved.
//

#import "MapDrawingView.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MapLinesAnnotation.h"
#import "Constants.h"
#import "AlarmController.h"

@implementation MapDrawingView

@synthesize locations;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		locations = [[NSMutableArray array] retain];
//		points = [[NSMutableArray array] retain];
		
		drawImage = [[UIImageView alloc] initWithImage:nil];
		drawImage.frame = frame;
		[self addSubview:drawImage];
		self.opaque = NO;
		self.backgroundColor = [UIColor clearColor];
		mouseMoved = 0;
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"you touched it!");
	
	[self.locations removeAllObjects];
//	[points removeAllObjects];
	
	mouseSwiped = NO;
	UITouch *touch = [touches anyObject];
	
	if ([touch tapCount] == 2) {
		drawImage.image = nil;
		return;
	}
	
	lastPoint = [touch locationInView:self];	
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	mouseSwiped = YES;
	
	UITouch *touch = [touches anyObject];	
	CGPoint currentPoint = [touch locationInView:self];
	
	MKMapView *mapView = self.superview;

	CLLocationCoordinate2D latAndLon = [mapView convertPoint:currentPoint toCoordinateFromView:mapView];
	
	CLLocation *locationPoint = [[[CLLocation alloc] initWithLatitude:latAndLon.latitude longitude:latAndLon.longitude] autorelease];
	
	[locations addObject:locationPoint];
/*	[points addObject:NSStringFromCGPoint(currentPoint)];
	CGPoint pointsArray[points.count];
	for (int i = 0; i < points.count; i++)
	{
		pointsArray[i] = CGPointFromString([points objectAtIndex:i]);
	}
*/	
	UIGraphicsBeginImageContext(self.frame.size);
	[drawImage.image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
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
	
	mouseMoved++;
	
	if (mouseMoved == 10) {
		mouseMoved = 0;
	}
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	UITouch *touch = [touches anyObject];
	
	if ([touch tapCount] == 2) {
		drawImage.image = nil;
		return;
	}
	
	if(!mouseSwiped) {
		UIGraphicsBeginImageContext(self.frame.size);
		[drawImage.image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
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
	
	MKMapView *mapView = self.superview;
	[mapView addAnnotation:annotation];
	[delegate saveLocationPointsArrayToUserDefaults:locations];
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kAlarmOn];
	[[AlarmController sharedAlarmController] setupAlarm:self];
	
	[self clearAndHideCanvas];
}

- (void)clearAndHideCanvas
{
	drawImage.image = nil;
	self.hidden = YES;
	
	[[delegate drawButton] setBackgroundImage:[UIImage imageNamed:@"redDrawButton.png"] forState:UIControlStateNormal];
}	

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)dealloc {
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



@end
