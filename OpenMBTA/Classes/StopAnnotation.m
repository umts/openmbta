//
//  StopAnnotation.m
//  OpenMBTA
//
//  Created by Daniel Choi on 10/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "StopAnnotation.h"


@implementation StopAnnotation
@synthesize coordinate, title, subtitle, stop_id, next_arrivals, isNextStop;

- (id) init {
    if (self = [super init]) {
        self.isNextStop = NO;
    }
    return self;
}
-(void)dealloc
{
    [title release];
    [subtitle release];
    [stop_id release];
    [next_arrivals release];
    [super dealloc];
}
@end
