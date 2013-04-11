//
//  NSLocale+Misc.m
//  Sleep Blaster touch
//
//  Created by Eamon Ford on 7/14/10.
//  Copyright 2010 The Byte Factory. All rights reserved.
//

#import "NSLocale+Misc.h"


@implementation NSLocale (Misc)

- (BOOL)timeIs24HourFormat {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSRange amRange = [dateString rangeOfString:[formatter AMSymbol]];
    NSRange pmRange = [dateString rangeOfString:[formatter PMSymbol]];
    BOOL is24Hour = amRange.location == NSNotFound && pmRange.location == NSNotFound;
    [formatter release];
    return is24Hour;
}

@end
