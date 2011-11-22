//
//  ActivityLinkDetailMessageTableViewCell.h
//  eXo Platform
//
//  Created by Nguyen Khac Trung on 11/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityDetailMessageTableViewCell.h"

@interface ActivityLinkDetailMessageTableViewCell : ActivityDetailMessageTableViewCell{

    UILabel*               _lbComment;
    TTStyledTextLabel*     _htmlLinkMessage;
    
}
@property (retain, nonatomic) IBOutlet UILabel* lbComment;
- (void)configureCellForSpecificContentWithWidth:(CGFloat)fWidth;

@end