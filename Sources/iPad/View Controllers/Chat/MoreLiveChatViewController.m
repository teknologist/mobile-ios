//
//  MoreLiveChat.m
//  eXoMobile
//
//  Created by Mai Thanh Xuyen on 9/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MoreLiveChatViewController.h"
#import "MessengerViewController_iPad.h"
#import "XMPPUser.h"
#import "LanguageHelper.h"

static NSString* kCellIdentifier = @"MyIdentifier";
#define kTagForCellSubviewTitleLabel 222
#define kTagForCellSubviewImageView 333

@implementation MoreLiveChatViewController

@synthesize arrLiveChat, _delegate, _popViewController;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil liveChat:(NSArray *)arr  delegate:(MainViewController *)delegate{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		arrLiveChat = [[NSArray alloc] initWithArray:arr];
		_delegate = delegate;
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
	[_btnCloseAllLiveChat setTitle:Localize(@"Close") forState:UIControlStateNormal];
    [super viewDidLoad];
}


-(IBAction)closeAllLiveChat
{
	[_popViewController dismissPopoverAnimated:YES];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	return 44;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString* tmpStr = @"";
	return tmpStr;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [arrLiveChat count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if(cell== nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kCellIdentifier] autorelease];
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17.0];
    }
    
	int chatIndex = [[arrLiveChat objectAtIndex:indexPath.row] intValue];
	MessengerUser* messengerUser = [[[_delegate getMessengerViewController] getArrChatUsers] objectAtIndex:chatIndex]; 
	NSString* tmpStr = [messengerUser._xmppUser address];
	NSRange r = [tmpStr rangeOfString:@"@"];
	if (r.length > 0) 
	{
		tmpStr = [tmpStr substringToIndex:r.location];
	}
	cell.textLabel.text = tmpStr;	
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[_delegate openChatWindows:[[arrLiveChat objectAtIndex:indexPath.row] intValue]];
	[_popViewController dismissPopoverAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    
    _delegate = nil;
    
    [_tblLiveChat release];
    _tblLiveChat = nil;
    
    [_btnCloseAllLiveChat release];
    _btnCloseAllLiveChat = nil;
    
    [arrLiveChat release];
    arrLiveChat = nil;
    
    [_popViewController release];
    _popViewController = nil;
    
    [super dealloc];
}


@end
