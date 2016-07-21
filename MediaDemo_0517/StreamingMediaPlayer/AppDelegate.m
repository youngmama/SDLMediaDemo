//
//  AppDelegate.m
//  StreamingMediaPlayer
//
//  Created by shi stella on 12/9/14.
//  Copyright (c) 2014 ford. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "MyUtil.h"
#import "Constants.h"

@interface AppDelegate ()

@end

@implementation AppDelegate{
    MyUtil *mUtil;
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions {
    
    if (self.logList == nil) {
        self.logList = [[NSMutableArray alloc] init];
    }
    if (mUtil == nil) {
        mUtil = [[MyUtil alloc] init];
    }
    [mUtil addLog:@"application willFinishLaunchingWithOptions:"];
    
    return YES;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.navController = [[UINavigationController alloc] init];
    
    ViewController *vc = [[ViewController alloc] init];
    self.window.rootViewController = self.navController;
    [self.navController pushViewController:vc animated:YES];
    [self.window makeKeyAndVisible];
    
    if (self.logList == nil) {
        self.logList = [[NSMutableArray alloc] init];
    }
    if (mUtil == nil) {
        mUtil = [[MyUtil alloc] init];
    }
    [mUtil addLog:@"application didFinishLaunchingWithOptions:"];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    if (self.logList == nil) {
        self.logList = [[NSMutableArray alloc] init];
    }
    if (mUtil == nil) {
        mUtil = [[MyUtil alloc] init];
    }
    [mUtil addLog:@"applicationWillResignActive"];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if (self.logList == nil) {
        self.logList = [[NSMutableArray alloc] init];
    }
    if (mUtil == nil) {
        mUtil = [[MyUtil alloc] init];
    }
    [mUtil addLog:@"applicationDidEnterBackground"];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if (self.logList == nil) {
        self.logList = [[NSMutableArray alloc] init];
    }
    if (mUtil == nil) {
        mUtil = [[MyUtil alloc] init];
    }
    [mUtil addLog:@"applicationWillEnterForeground"];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (self.logList == nil) {
        self.logList = [[NSMutableArray alloc] init];
    }
    if (mUtil == nil) {
        mUtil = [[MyUtil alloc] init];
    }
    [mUtil addLog:@"applicationDidBecomeActive"];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    if (self.logList == nil) {
        self.logList = [[NSMutableArray alloc] init];
    }
    if (mUtil == nil) {
        mUtil = [[MyUtil alloc] init];
    }
    [mUtil addLog:@"applicationWillTerminate"];
    
}

+ (AppDelegate *)getDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

@end
