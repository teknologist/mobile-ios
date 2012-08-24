//
//  Configuration.m
//  eXo Platform
//
//  Created by Nguyen Khac Trung on 9/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ServerPreferencesManager.h"
#import "CXMLDocument.h"
#import "CXMLNode.h"
#import "CXMLElement.h"
#import "defines.h"

/*
 * Key of User Preference to save selected stream tab order. it contains domain name and username to distinguish amongs users.
 */
#define EXO_SELECTED_STREAM                 [NSString stringWithFormat:@"%@_%@_selected_stream", self.selectedDomain, self.username]
#define EXO_REMEMBER_MY_STREAM              [NSString stringWithFormat:@"%@_%@_remember_my_stream", self.selectedDomain, self.username]
/*
 * Keys for login settings
 */
#define EXO_REMEMBER_ME                     @"remember_me"
#define EXO_AUTO_LOGIN                      @"auto_login"
/* key for showing prive drive */
#define EXO_PREFERENCE_SHOW_PRIVATE_DRIVE   [NSString stringWithFormat:@"%@_%@_show_private_drive", self.selectedDomain, self.username]

//=====================================================================

@implementation ServerObj
@synthesize _strServerName;
@synthesize _strServerUrl;
@synthesize _bSystemServer;
@end


//======================================================================
@implementation ServerPreferencesManager

@synthesize selectedServerIndex = _selectedServerIndex;
@synthesize selectedDomain = _selectedDomain;
@synthesize username = _username;
@synthesize password = _password;
@synthesize currentRepository = _currentRepository;
@synthesize defaultWorkspace = _defaultWorkspace;
@synthesize userHomeJcrPath = _userHomeJcrPath;
@synthesize selectedSocialStream;
@synthesize rememberSelectedSocialStream;
@synthesize isUserLogged = _isUserLogged;
@synthesize autoLogin;
@synthesize rememberMe;
@synthesize showPrivateDrive;

+ (ServerPreferencesManager*)sharedInstance
{
	static ServerPreferencesManager *sharedInstance;
	@synchronized(self)
	{
		if(!sharedInstance)
		{
			sharedInstance = [[ServerPreferencesManager alloc] init];
		}
		return sharedInstance;
	}
	return sharedInstance;
}

- (id) init
{
	self = [super init];
    if (self) 
    {        
        self.selectedServerIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:EXO_PREFERENCE_SELECTED_SEVER] intValue];
        [self reloadUsernamePassword];
                
        // At the startup time, the user is always unsigned.
        _isUserLogged = NO;
    }	
	return self;
}

- (void) dealloc
{
    [_selectedDomain release];
	[_arrServerList release];
    [_username release];
    [_password release];
    [_currentRepository release];
    [_defaultWorkspace release];
    [_userHomeJcrPath release];
	[super dealloc];
}

- (void)loadServerList
{
    NSError* error;
    NSMutableArray* arrSystemServerList;
    NSMutableArray* arrUserServerList;
    NSMutableArray* arrDeletedSystemServerList;
    NSString* strDefaultConfigPath;
    NSString* strSystemConfigPath;
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    NSString* strAppOldVersion = [userDefault objectForKey:@"prefVersion"];
    NSString* strAppCurrentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    
    //Load the system Configuration
    if ((!strAppOldVersion) || (strAppOldVersion && ([strAppCurrentVersion compare:strAppOldVersion] == NSOrderedAscending)))
    {
        //copy the defautl Configuration to the system Configuration in the /app/documents
        strDefaultConfigPath = [[NSBundle mainBundle] pathForResource:@"Configuration" ofType:@"xml"];
        strSystemConfigPath = [[paths objectAtIndex:0] stringByAppendingString:@"/SystemConfiguration"];
        [fileManager copyItemAtPath:strDefaultConfigPath toPath:strSystemConfigPath error:&error];
    }
    
    //Load the system Configuration
    arrSystemServerList = [self loadSystemConfiguration];
    
    //Load the deleted system Configuration
    arrDeletedSystemServerList = [self loadDeletedSystemConfiguration];
    
    if ([arrDeletedSystemServerList count] > 0) 
    {
        for (int i = 0; i < [arrSystemServerList count]; i++) 
        {
            ServerObj* tmpServerObj1 = [arrSystemServerList objectAtIndex:i];
            for (int j = 0; j < [arrDeletedSystemServerList count]; j++) 
            {
                ServerObj* tmpServerObj2 = [arrDeletedSystemServerList objectAtIndex:j];
                if ([tmpServerObj2._strServerName isEqualToString:tmpServerObj1._strServerName] &&
                    [tmpServerObj2._strServerUrl isEqualToString:tmpServerObj1._strServerUrl]) 
                {
                    [arrSystemServerList removeObjectAtIndex:i];
                    i --;
                    break;
                }
            }
            if ((i == 0) && ([arrSystemServerList count] == 1))
            {
                i--;
            }
        }
    }
    
    //Load the user Configuration    
    arrUserServerList = [self loadUserConfiguration];
    if (!_arrServerList) _arrServerList = [[NSMutableArray alloc] init];
    [_arrServerList removeAllObjects];
    if ([arrSystemServerList count] > 0) 
    {
        [_arrServerList addObjectsFromArray:arrSystemServerList];
    }
    if ([arrUserServerList count] > 0) 
    {
        [_arrServerList addObjectsFromArray:arrUserServerList];
    }
    
    NSData* tmpData = [self createXmlDataWithServerList:_arrServerList];
    [self writeData:tmpData toFile:@"Test"];
}

//Load the system Configuration
- (NSMutableArray*)loadSystemConfiguration
{
    NSData* data = [self readFileWithName:@"SystemConfiguration"];
    NSMutableArray* arr = [self parseConfiguration: data withBSystemSever:YES];
    return arr;
}

//Load the deleted system Configuration
- (NSMutableArray*)loadDeletedSystemConfiguration
{
    NSData* data = [self readFileWithName:@"DeletedSystemConfiguration"];
    NSMutableArray* arr = [self parseConfiguration: data withBSystemSever:YES];
    return arr;
}

//Load the user Configuration
- (NSMutableArray*)loadUserConfiguration
{
    NSData* data = [self readFileWithName:@"UserConfiguration"];
    NSMutableArray* arr = [self parseConfiguration: data withBSystemSever:NO];
    return arr;
}

- (NSMutableArray*)parseConfiguration:(NSData*)data withBSystemSever:(BOOL)bSystemServer
{
    NSError* error;
    NSMutableArray* arrServerList = [[[NSMutableArray alloc] init] autorelease];
    CXMLDocument* doc = [[CXMLDocument alloc] initWithData:data options:0 error:&error];
    if(doc != nil) 
    {
        CXMLElement* root = [doc rootElement];
        NSArray* arrXml = [root elementsForName:@"xml"];
        if (arrXml) 
        {
            CXMLElement* elementXml = [arrXml objectAtIndex:0];
            NSArray* arrServers = [elementXml elementsForName:@"Servers"];
            if (arrServers) 
            {
                CXMLElement* elementSevers = [arrServers objectAtIndex:0];
                NSArray* arrsever = [elementSevers elementsForName:@"server"];
                if (arrsever) 
                {
                    CXMLNode* tmpNode;                   
                    for (int i = 0; i < [arrsever count]; i++) 
                    {
                        tmpNode = [arrsever objectAtIndex:i];
                        ServerObj* serverObj = [[ServerObj alloc] init];
                        serverObj._strServerName = [self getNodeValue:tmpNode withName:@"name"];
                        serverObj._strServerUrl = [self getNodeValue:tmpNode withName:@"serverURL"];
                        serverObj._bSystemServer = bSystemServer;
                        [arrServerList addObject:serverObj];
                        [serverObj release];
                    }
                }
            }
        }
    }
    [doc release];
    return arrServerList;
}

//Read the file with name
- (NSData*)readFileWithName:(NSString*)strFileName
{    
    NSData* data = nil;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL bExist = NO;
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* strFilePath = [[paths objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"/%@",strFileName]];
    bExist = [fileManager fileExistsAtPath:strFilePath];
    if (bExist) 
    {
        data = [fileManager contentsAtPath:strFilePath];
    }
    return data;
}

//Saved the system Configuration to the /app/documents
- (void)writeSystemConfiguration:(NSMutableArray*)arrSystemServerList
{
    // update selected server info to userdefault
    self.selectedServerIndex = self.selectedServerIndex;
    NSData* dataWrite  = [self createXmlDataWithServerList:arrSystemServerList];
    [self writeData:dataWrite toFile:@"SystemConfiguration"];
}

//Saved the deleted system Configuration to the /app/documents
- (void)writeDeletedSystemConfiguration:(NSMutableArray*)arrDeletedSystemServerList
{
    NSData* data = [self readFileWithName:@"DeletedSystemConfiguration"];
    NSMutableArray* tmpArr = [self parseConfiguration: data withBSystemSever:YES];
    [tmpArr addObjectsFromArray:arrDeletedSystemServerList];
    NSData* dataWrite  = [self createXmlDataWithServerList:tmpArr];
    [self writeData:dataWrite toFile:@"DeletedSystemConfiguration"];
}

//Saved the user Configuration to the /app/documents
- (BOOL)writeUserConfiguration:(NSMutableArray*)arrUserSystemServerList
{
    // update selected server info
    self.selectedServerIndex = self.selectedServerIndex;
    NSData* dataWrite = [self createXmlDataWithServerList:arrUserSystemServerList];
    return [self writeData:dataWrite toFile:@"UserConfiguration"];
}

- (BOOL)writeData:(NSData*)data toFile:(NSString*)strFileName
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* strFilePath = [[paths objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"/%@",strFileName]];
    return [fileManager createFileAtPath:strFilePath contents:data attributes:nil];
}


//Created the xml string before saving
- (NSData*)createXmlDataWithServerList:(NSMutableArray*)arrServerList
{
    NSString* strContent = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n<plist version=\"1.0\">\n\t<xml>\n\t\t<Servers>\n";
    for (int i = 0; i < [arrServerList count]; i++) 
    {
        ServerObj* tmpServerObj = [arrServerList objectAtIndex:i];
        NSString* tmpStr = [NSString stringWithFormat:@"\t\t\t<server name=\"%@\" serverURL=\"%@\"/>\n",tmpServerObj._strServerName, tmpServerObj._strServerUrl];
        strContent = [strContent stringByAppendingString:tmpStr];
    }
    
    NSString* strEnd = @"\t\t</Servers>\n\t</xml>\n</plist>";
    strContent = [strContent stringByAppendingString:strEnd];
    NSData* data = [strContent dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}


- (CXMLNode*) getNode: (CXMLNode*) element withName: (NSString*) name 
{
	for(CXMLNode* child in [element children]) 
    {
		if([child respondsToSelector:@selector(name)] && [[child name] isEqual: name]) 
        {
			return (CXMLNode*)child;
		}
	}
	
    for(CXMLNode* child in [element children]) 
    {
		CXMLNode* el = [self getNode: (CXMLElement*)child withName: name];
		if(el != nil) 
        { 
            return el; 
        }
	}
	return nil;
}

- (NSString*) getNodeValue: (CXMLNode*) node withName: (NSString*) name 
{
	// Set up the variables
	if(node == nil || name == nil) 
    { 
        return nil; 
    }
	
    CXMLNode* child = nil;
	
	// If it's an attribute get it
	if([node isKindOfClass: [CXMLElement class]])
	{
		child = [(CXMLElement*)node attributeForName: name];
		if(child != nil) 
        {
			return [child stringValue];
		}
	}
    
	// Otherwise get the first element
	child = [self getNode: node withName: name];
	if(child != nil) 
    {
		return [child stringValue];
	}
	return nil;
}

- (NSMutableArray *)serverList {
    if (!_arrServerList) {
        [self loadServerList];
    }
    return _arrServerList;
}
#pragma mark - username & password management 
- (void)persistUsernameAndPasswod {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.username forKey:EXO_PREFERENCE_USERNAME];
    [userDefaults setObject:self.password forKey:EXO_PREFERENCE_PASSWORD];
}

- (void)reloadUsernamePassword {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    self.username = [userDefaults objectForKey:EXO_PREFERENCE_USERNAME];
    self.username = self.username ? self.username : @"";
    self.password = [userDefaults objectForKey:EXO_PREFERENCE_PASSWORD];
    self.password = self.password ? self.password : @"";
}

#pragma mark - getters & setters 
- (void)setSelectedServerIndex:(int)selectedServerIndex {
    // customize setter of selectedServerIndex
    int tmpIndex = -1; // default value for selected server index 
    NSString *tmpDomain = nil; // default value for selected domain
    if (selectedServerIndex >= 0 && self.serverList.count > 0) {
        if (selectedServerIndex < [self.serverList count]) {
            tmpIndex = selectedServerIndex;
            ServerObj *selectedObj = [self.serverList objectAtIndex:selectedServerIndex];
            tmpDomain = selectedObj._strServerUrl;
        }
    }
    [_selectedDomain release];
    _selectedDomain = [tmpDomain retain];
    _selectedServerIndex = tmpIndex;
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSString stringWithFormat:@"%d", _selectedServerIndex] forKey:EXO_PREFERENCE_SELECTED_SEVER];
    [userDefaults setObject:_selectedDomain forKey:EXO_PREFERENCE_DOMAIN];
}

- (NSString *)selectedDomain {
    if (!_selectedDomain) {
        _selectedDomain = [[NSUserDefaults standardUserDefaults] objectForKey:EXO_PREFERENCE_DOMAIN];
    }
    return [[_selectedDomain copy] autorelease];
}

- (BOOL)rememberSelectedSocialStream {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *value = [userDefaults objectForKey:EXO_REMEMBER_MY_STREAM];
    return value ? [value boolValue] : YES;
}

- (void)setRememberSelectedSocialStream:(BOOL)agree {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSString stringWithFormat:@"%d", agree] forKey:EXO_REMEMBER_MY_STREAM];
}

- (void)setSelectedSocialStream:(int)selectedIndex {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSString stringWithFormat:@"%d", selectedIndex] forKey:EXO_SELECTED_STREAM];
}

- (int)selectedSocialStream {
    return self.rememberSelectedSocialStream ? [[[NSUserDefaults standardUserDefaults] objectForKey:EXO_SELECTED_STREAM] intValue] : 0;
}

- (void)setJcrRepositoryName:(NSString *)repositoryName defaultWorkspace:(NSString *)defaultWorkspace userHomePath:(NSString *)userHomePath {
    [repositoryName retain];
    [_currentRepository release];
    _currentRepository = repositoryName ? repositoryName : [@"repository" retain];
    [defaultWorkspace retain];
    [_defaultWorkspace release];
    _defaultWorkspace = defaultWorkspace ? defaultWorkspace : [@"collaboration" retain];
    [userHomePath retain];
    [_userHomeJcrPath release];
    _userHomeJcrPath = userHomePath ? userHomePath : [[self makeUserHomePath:self.username] retain];
}

- (NSString *)makeUserHomePath:(NSString *)username; 
{
    NSMutableString *path = [NSMutableString stringWithString:@"/Users"];
    
    int length = [username length];
    
    int numberOfUserLevel = length < 4 ?  2 : 3;
    
    for(int i = 1; i <= numberOfUserLevel; i++)
    {
        NSMutableString *userNameLevel = [NSMutableString stringWithString:[username substringToIndex:i]];
        
        for(int j = 1; j <= 3; j++)
        {
            [userNameLevel appendString:@"_"];
        }
        
        [path appendFormat:@"/%@", userNameLevel];        
    }
    
    [path appendFormat:@"/%@", username];
    return path;
}

#pragma mark - Login management
- (BOOL)autoLogin {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *value = [userDefaults objectForKey:EXO_AUTO_LOGIN];
    return value ? [value boolValue] : NO;
}

- (void)setAutoLogin:(BOOL)agree {
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", agree] forKey:EXO_AUTO_LOGIN];
}

- (BOOL)rememberMe {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *value = [userDefaults objectForKey:EXO_REMEMBER_ME];
    return value ? [value boolValue] : NO;
}

- (void)setRememberMe:(BOOL)agree {
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", agree] forKey:EXO_REMEMBER_ME];
}

#pragma mark - Document setting management
- (BOOL)showPrivateDrive {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *value = [userDefaults objectForKey:EXO_PREFERENCE_SHOW_PRIVATE_DRIVE];
    return value ? [value boolValue] : YES;
}

- (void)setShowPrivateDrive:(BOOL)agree {
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", agree] forKey:EXO_PREFERENCE_SHOW_PRIVATE_DRIVE];
}

@end
