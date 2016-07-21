//
//  LockViewController.h
//  StreamingMediaPlayer
//
//  Created by ShiStella on 14/12/19.
//  Copyright (c) 2014年 ford. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LockViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *unlockBtn;

- (IBAction)unlock:(id)sender;

@end
