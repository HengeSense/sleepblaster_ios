//
//  HUDView.m
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 10/1/09.
//  Copyright 2009 The Byte Factory. All rights reserved.
//

#import "HUDView.h"
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>

@implementation HUDView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect {	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetRGBFillColor(context, 0.0,0.0,0.0,1.0);
	CGContextFillRect(context, rect);
	
	
//	if ([displayMode isEqualToString:@"iTunes"]) {	// if it's really truly positively using iTunes...
//		iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
//		
//		currentTrackPersistentID = [[[[iTunes currentTrack] persistentID] mutableCopy] retain];
//		NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshArtworkIfNeeded:) userInfo:nil repeats:YES];
//		
//		iTunesTrack *track = [iTunes currentTrack];
		MPMediaItemArtwork *mediaItemArtwork = [[MPMusicPlayerController applicationMusicPlayer].nowPlayingItem valueForProperty:MPMediaItemPropertyArtwork];
											
		
		// Now for the album art...
		//NSImage *artwork;
		CGSize originalSize = mediaItemArtwork.bounds.size;
		CGSize artworkSize;
		artworkSize.width = 320.0;
		artworkSize.height = artworkSize.width*originalSize.height/originalSize.width;
	
		UIImage *artworkImage = [mediaItemArtwork imageWithSize:artworkSize];
//		if ([[track artworks] count]) {
		if (artworkImage) {
//			artwork = [[[track artworks] objectAtIndex:0] data];
		} else {
//			artwork = [NSImage imageNamed:@"NoArtwork"];
		}
	
		[artworkImage drawAtPoint:CGPointMake(0,0)];

		// first we have to set up the colors for the gradient fill.
		CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
		CGFloat colors[] =
		{
			0.0, 0.0, 0.0, 0.00,
			0.0, 0.0, 0.0, .25,
			0.0, 0.0, 0.0, .50,
			0.0, 0.0, 0.0, .75,
			0.0, 0.0, 0.0, 1.00,
		};
		CGGradientRef gradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));
		CGColorSpaceRelease(rgb);
		
		// now we can actually create the shape and fill it
		
		CGPoint start, end;
		
	//	CGContextSetRGBFillColor(context, 0, 0, 0.6, 0.1);
//		CGContextFillEllipseInRect(context, CGRectMake(0.0, 0.0, 100.0, 100.0));
//		CGContextStrokeEllipseInRect(context, CGRectMake(0.0, 0.0, 100.0, 100.0));
		
		// Gradient
		CGRect myrect = CGRectMake(0.0, artworkSize.height-25.0, self.frame.size.width, 35.0);
		CGContextSaveGState(context);
		CGContextClipToRect(context, myrect);
		start = CGPointMake(myrect.origin.x, myrect.origin.y + myrect.size.height * 0.25);
		end = CGPointMake(myrect.origin.x, myrect.origin.y + myrect.size.height * 0.75);
		CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation);
		CGContextRestoreGState(context);
	
//		NSImage *scaledArtwork = [[[NSImage alloc] initWithSize:NSMakeSize(400, 400)] autorelease];
//		
//		NSAffineTransform *at = [NSAffineTransform transform];
//		[artwork setScalesWhenResized:YES];
//		float heightFactor = 400.0/[artwork size].height;
//		float widthFactor = 400.0/[artwork size].width;
//		float scale;
//		if(heightFactor > widthFactor){
//			scale = widthFactor;
//		} else {
//			scale = heightFactor;
//		}
//		
//		[at scaleBy:scale];
//		
//		[scaledArtwork lockFocus];
//		[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationLow];
//		[artwork setSize:[at transformSize:[artwork size]]];
//		[artwork compositeToPoint:NSMakePoint((400-[artwork size].width)/2 , (400-[artwork size].height)/2) operation:NSCompositeCopy];
//		[scaledArtwork unlockFocus];
//		
//		NSPoint backgroundCenter;
//		backgroundCenter.x = [self bounds].size.width / 2;
//		backgroundCenter.y = [self bounds].size.height / 2;
//		
//		NSPoint drawPoint = backgroundCenter;
//		drawPoint.x -= [artwork size].width / 2;
//		drawPoint.y -= [artwork size].height / 2;
//		
//		[scaledArtwork drawAtPoint:drawPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:0.3];	
//		
//	} else if ([displayMode isEqualToString:@"Dynamite"]) {
//		// Draw the dynamite graphic.
//		NSImage *dynamite = [NSImage imageNamed:@"dynamite"];
//		
//		NSPoint backgroundCenter;
//		backgroundCenter.x = [self bounds].size.width / 2;
//		backgroundCenter.y = [self bounds].size.height / 2;
//		
//		NSPoint drawPoint = backgroundCenter;
//		drawPoint.x -= [dynamite size].width / 2;
//		drawPoint.y -= [dynamite size].height / 2;
//		
//		[dynamite drawAtPoint:drawPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:0.3];			
//		
//	}
}


- (void)dealloc {
    [super dealloc];
}


@end
