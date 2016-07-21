//
//  ViewController.h
//  StreamingMediaPlayer
//
//  Created by shi stella on 12/9/14.
//  Copyright (c) 2014 ford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <smartdevicelink/smartdevicelink.h>


@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,SDLProxyListener>

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UITableView *contentTableView;
@property (nonatomic, strong) UITableView *menuTableView;

@property (nonatomic, strong) SDLProxy *proxy;
@property (nonatomic) int autoIncCorrID;


@end

