//
//  MapDrawingViewController.h
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 5/4/10.
//  Copyright 2010 The Byte Factory. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MapDrawingViewController : UIViewController {
	
	CGPoint lastPoint;
	UIImageView *drawImage;
	BOOL mouseSwiped;		
	NSMutableArray *locations;
	id delegate;
}

@property (nonatomic, retain) NSMutableArray *locations;
@property (assign) id delegate;

- (void)clearAndHideCanvas;


@end
