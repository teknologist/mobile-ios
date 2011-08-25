//
//  DashboardViewController_iPhone.m
//  eXo Platform
//
//  Created by Tran Hoai Son on 4/22/11.
//  Copyright 2011 home. All rights reserved.
//

#import "DashboardViewController_iPhone.h"

#import "DashboardProxy.h"
#import "Gadget_iPad.h"
#import "Gadget_iPhone.h"
#import "GadgetDisplayViewController.h"
#import "CustomBackgroundForCell_iPhone.h"
#import "LanguageHelper.h"


//Constants Definitions
#define kTagForCellSubviewTitleLabel 22
#define kTagForCellSubviewDescriptionLabel 33
#define kTagForCellSubviewImageView 44

@implementation DashboardViewController_iPhone

@synthesize _arrTabs;

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) 
//    {
//        self.title = @"Dashboard";
//    }
//    return self;
//}
//
//- (void)dealloc 
//{
//    [super dealloc];
//}
//
//- (void)loadView 
//{
//    [super loadView];
//}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        //TODO localize that
        self.title = Localize(@"Dashboard");
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //Set the background Color of the view
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgGlobal.png"]];
    
    _tblGadgets.backgroundView = backgroundView;
    
    
    [_arrTabs removeLastObject];
    _arrTabs = [[DashboardProxy sharedInstance] getItemsInDashboard];
    
    [_tblGadgets reloadData];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    BOOL b = NO;
    if((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight))
    {
        b = YES;
    }    
    return b;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    int n = [_arrTabs count]; 
    return n;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	return 60;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *str = [[_arrTabs objectAtIndex:section] _strDbItemName];
    return str;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	int n = [[[_arrTabs objectAtIndex:section] _arrGadgetsInItem] count];
	return n;
}



// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
	static NSString* kCellIdentifier = @"Cell";
	
    //We dequeue a cell
	CustomBackgroundForCell_iPhone *cell = (CustomBackgroundForCell_iPhone *)[tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    //Check if we found a cell
    if (cell==nil) 
    {
         
        //Not found, so create a new one
        cell = [[[CustomBackgroundForCell_iPhone alloc] initWithFrame:CGRectZero reuseIdentifier:kCellIdentifier] autorelease];
        
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
        //Add subviews only one time, and use the propertie 'Tag' of UIView to retrieve them
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(75.0, 5.0, 180.0, 20.0)];
        titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0];
        titleLabel.backgroundColor = [UIColor clearColor];
        //define the tag for the titleLabel
        titleLabel.tag = kTagForCellSubviewTitleLabel; 
        [cell addSubview:titleLabel];
        //release the titleLabel because cell retain it now
        [titleLabel release];
        
        //Create the descriptionLabel
        UILabel* descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(75.0, 23.0, 180.0, 33.0)];
        descriptionLabel.numberOfLines = 2;
        descriptionLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
        descriptionLabel.backgroundColor = [UIColor clearColor];
        descriptionLabel.tag = kTagForCellSubviewDescriptionLabel;
        [cell addSubview:descriptionLabel];
        [descriptionLabel release];
        
        //Create the imageView
        UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, 5.0, 50, 50)];
        imgView.tag = kTagForCellSubviewImageView;
        [cell addSubview:imgView];
        [imgView release];
     
    }
         
    
    //Configurate the cell
    //Configurate the titleLabel and assign good value
	UILabel *titleLabel = (UILabel*)[cell viewWithTag:kTagForCellSubviewTitleLabel];
    titleLabel.text = [[[[_arrTabs objectAtIndex:indexPath.section] _arrGadgetsInItem] objectAtIndex:indexPath.row] name];
    
	//Configuration the DesriptionLabel
    UILabel *descriptionLabel = (UILabel*)[cell viewWithTag:kTagForCellSubviewDescriptionLabel];
	descriptionLabel.text = [[[[_arrTabs objectAtIndex:indexPath.section] _arrGadgetsInItem] objectAtIndex:indexPath.row] description];
	
    //Configuration of the ImageView
    UIImageView *imgView = (UIImageView *)[cell viewWithTag:kTagForCellSubviewImageView];
    imgView.image = [[[[_arrTabs objectAtIndex:indexPath.section] _arrGadgetsInItem] objectAtIndex:indexPath.row] imageIcon];
    
    [cell setBackgroundForRow:indexPath.row inSectionSize:[self tableView:tableView numberOfRowsInSection:indexPath.section]];
    
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GateInDbItem *gadgetTab = [_arrTabs objectAtIndex:indexPath.section];
	Gadget_iPhone *gadget = [gadgetTab._arrGadgetsInItem objectAtIndex:indexPath.row];
	NSURL *tmpURL = gadget._urlContent;
	
	
	if (_gadgetDisplayViewController == nil) 
	{
		_gadgetDisplayViewController = [[GadgetDisplayViewController alloc] initWithNibAndUrl:@"GadgetDisplayViewController" bundle:nil url:tmpURL];
	}

	[_gadgetDisplayViewController setUrl:tmpURL];

    [self.navigationController pushViewController:_gadgetDisplayViewController animated:YES];
}


@end