//
//  eXoFilesView.h
//  eXoApp
//
//  Created by Tran Hoai Son on 7/3/09.
//  Copyright 2009 home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessengerViewController.h"
#import "ChatWindowViewController_iPhone.h"

//Chat list view
@interface MessengerViewController_iPhone : MessengerViewController
{
    ChatWindowViewController_iPhone *chatWindow;   

}

@end