//
//  MapDrawingView.h
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 4/10/10.
//  Copyright 2010 The Byte Factory. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapDrawingView : UIView {

	CGPoint lastPoint;
	
	UIImageView *drawImage;
	BOOL mouseSwiped;	
	int mouseMoved;
	
	NSMutableArray *locations;
//	NSMutableArray *points;
	id delegate;
}
@property (nonatomic, retain) NSMutableArray *locations;
@property (assign) id delegate;

- (void)clearAndHideCanvas;

@end
