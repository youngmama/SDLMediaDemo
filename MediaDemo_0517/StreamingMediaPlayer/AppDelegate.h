//
//  AppDelegate.h
//  StreamingMediaPlayer
//
//  Created by shi stella on 12/9/14.
//  Copyright (c) 2014 ford. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navController;

@property (nonatomic,strong) NSMutableArray *logList;

+(AppDelegate *)getDelegate;
@end

