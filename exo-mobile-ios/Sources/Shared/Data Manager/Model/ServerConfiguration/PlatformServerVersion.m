//
//  PlatformServerVersion.m
//  eXo Platform
//
//  Created by Stévan Le Meur on 26/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlatformServerVersion.h"


@implementation PlatformServerVersion

@synthesize  platformVersion=_platformVersion, platformRevision=_platformRevision, platformBuildNumber=_platformBuildNumber, isMobileCompliant=_isMobileCompliant, platformEdition=_platformEdition;


- (void) dealloc {
    [_platformVersion release]; _platformVersion = nil;
    [_platformRevision release]; _platformRevision = nil;
    [_platformBuildNumber release]; _platformBuildNumber = nil;
    [_isMobileCompliant release]; _isMobileCompliant = nil;
    [_platformEdition release]; _platformEdition = nil;
    [super dealloc];
}

@end
