//
//  iPadiPadServerAddingViewController.m
//  eXo Platform
//
//  Created by Tran Hoai Son on 3/28/11.
//  Copyright 2011 home. All rights reserved.
//

#import "iPadServerAddingViewController.h"
#import "ServerManagerViewController.h"
#import "ContainerCell.h"
#import "defines.h"
#import "LoginViewController.h"
#import "CustomBackgroundForCell_iPhone.h"
#import "AppDelegate_iPad.h"

static NSString *ServerObjCellIdentifier = @"ServerObj";


@implementation iPadServerAddingViewController

@synthesize _txtfServerName;
@synthesize _txtfServerUrl;
@synthesize _tblvServerInfo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [_strServerName release];
    [_strServerUrl release];
    [_txtfServerName release];
    [_txtfServerUrl release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)setDelegate:(id)delegate
{
    _delegate = delegate;
}

- (void)localize
{
    [_tblvServerInfo reloadData];
}


- (IBAction)onBtnBack:(id)sender
{
    [_delegate onBackDelegate];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    _txtfServerName = [iPadServerAddingViewController textInputFieldForCellWithSecure:NO];
    [_txtfServerName setReturnKeyType:UIReturnKeyNext];
	_txtfServerName.delegate = self;
	_txtfServerUrl = [iPadServerAddingViewController textInputFieldForCellWithSecure:NO];
    [_txtfServerUrl setReturnKeyType:UIReturnKeyDone];
	_txtfServerUrl.delegate = self;


    _bbtnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onBtnDone)];
    self.navigationItem.rightBarButtonItem = _bbtnDone;

    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [_txtfServerName setTextColor:[UIColor grayColor]];
    [_txtfServerUrl setTextColor:[UIColor grayColor]];
    [_bbtnDone setEnabled:NO];
    [super viewWillAppear:YES];
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
    return YES;
}

- (void)onBtnDone
{
    [_txtfServerName resignFirstResponder];
    [_txtfServerUrl resignFirstResponder];
    _strServerName = [_txtfServerName text];
    _strServerUrl = [_txtfServerUrl text];
    
    NSRange range = [_strServerUrl rangeOfString:@"http://"];
    if(range.length == 0 && [_strServerUrl length] > 0)
    {
        _strServerUrl = [NSString stringWithFormat:@"http://%@", _strServerUrl];
    }
    
    if ([_strServerName length] > 0 && [_strServerUrl length] > 0) 
    {
        [_delegate addServerObjWithServerName:_strServerName andServerUrl:_strServerUrl];
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Message Info" message:@"You cannot add a server with an empty name or url" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}

+ (UITextField*)textInputFieldForCellWithSecure:(BOOL)secure 
{
    UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(180, 12, 330, 22)];
    textField.placeholder = @"Required";
    textField.secureTextEntry = secure;
    textField.keyboardType = UIKeyboardTypeASCIICapable;
    textField.returnKeyType = UIReturnKeyDone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    return textField;
}

- (UITableViewCell*)containerCellWithLabel:(UILabel*)label view:(UIView*)view 
{
    NSString *MyIdentifier = label.text;
    ContainerCell *cell = (ContainerCell*)[_tblvServerInfo dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) 
    {
        cell = [[ContainerCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier];
    }
    cell.textLabel.text = label.text;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell attachContainer:view];
    
    return cell;
}

- (UITableViewCell*)textCellWithLabel:(UILabel*)label 
{
    NSString *MyIdentifier = label.text;
    ContainerCell *cell = (ContainerCell*)[_tblvServerInfo dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) 
    {
        cell = [[ContainerCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier];
    }
    cell.textLabel.text = label.text;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [_bbtnDone setEnabled:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField 
{
    if (theTextField == _txtfServerName) 
    {
        
        [_txtfServerUrl becomeFirstResponder];
    }
    else
    {    
        [_txtfServerUrl resignFirstResponder];
        [_txtfServerName resignFirstResponder];
        _strServerName = [[_txtfServerName text] retain];
        _strServerUrl = [[_txtfServerUrl text] retain];
        
        
        [self onBtnDone];
    }    
    
    _strServerName = [[_txtfServerName text] retain];
    _strServerUrl = [[_txtfServerUrl text] retain];

    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Dismiss the keyboard when the view outside the text field is touched.
    [_txtfServerName resignFirstResponder];
    [_txtfServerUrl resignFirstResponder];	
    [super touchesBegan:touches withEvent:event];
}


#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString* tmpStr = @"";
	return tmpStr;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomBackgroundForCell_iPhone *cell = [[[CustomBackgroundForCell_iPhone alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ServerObjCellIdentifier] autorelease];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if(indexPath.row == 0)
    {
        //TODO localize the label
        cell.textLabel.text = @"Server Name";
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
        
        [cell addSubview:_txtfServerName];
    }
    else
    {
        //TODO localize this label
        cell.textLabel.text = @"Server Url";
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
        
        [cell addSubview:_txtfServerUrl];
    }
    
    
    [cell setBackgroundForRow:indexPath.row inSectionSize:[self tableView:tableView numberOfRowsInSection:indexPath.section]];
    
    
    return cell;
}

@end

