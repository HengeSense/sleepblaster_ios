//
//  Randomizer.m
//  Sleep Blaster
//
//  Created by Eamon Ford on 10/14/06.
//  Copyright 2006 The Byte Factory. All rights reserved.
//

#import "Randomizer.h"


@implementation Randomizer

- (int)randomWithMax:(int)max
{
    return (random() % max) + 1;
}

- (id)init
{
	if (self = [super init]) {
		// Seed the random number generator with the time
		srandom(time(NULL));
	}
	return self;
}

@end
