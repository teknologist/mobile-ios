//
//  AppDelegate_iPad.m
//  eXo Platform
//
//  Created by Mai Gia on 1/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate_iPad.h"
#import "eXoMobileViewController.h"
#import "RootViewController.h"

@implementation AppDelegate_iPad

@synthesize window, viewController, rootViewController;

+ (AppDelegate_iPad *) instance {
    return (AppDelegate_iPad *) [[UIApplication sharedApplication] delegate];

}



#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
    
    //UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    //navigationController.navigationBarHidden = YES;
    //[window addSubview:navigationController.view];
    
    rootViewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
    
    [window addSubview:rootViewController.view];
    
    
	[window addSubview:viewController.view];
    
  
    
    
    [window makeKeyAndVisible];
    
    [rootViewController.view removeFromSuperview];
    
    return YES;
}



-(void)showHome:(id)delegateForViewControllers {
    rootViewController.delegate = delegateForViewControllers;

   
    [UIView transitionWithView:self.window
                      duration:1
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{ [viewController.view removeFromSuperview]; [self.window addSubview:rootViewController.view]; }
                    completion:NULL];
}


-(void)backToAuthenticate{

    
    [UIView transitionWithView:self.window
                      duration:1
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{ [rootViewController.view removeFromSuperview]; [self.window addSubview:viewController.view]; }
                    completion:NULL];
    
}



- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
