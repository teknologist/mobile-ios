//
//  ActivityDetailViewController_iPad.h
//  eXo Platform
//
//  Created by Tran Hoai Son on 7/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActivityDetailViewController.h"

@class ActivityDetailExtraActionsCell;
@class ActivityDetailAdvancedInfoController_iPad;

@interface ActivityDetailViewController_iPad : ActivityDetailViewController 

@property (nonatomic, retain) ActivityDetailExtraActionsCell *extraActionsCell;
@property (nonatomic, retain) ActivityDetailAdvancedInfoController_iPad *advancedInfoController;

- (IBAction)likeDislike:(id)sender;

@end