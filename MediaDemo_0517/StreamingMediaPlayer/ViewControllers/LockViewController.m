//
//  LockViewController.m
//  StreamingMediaPlayer
//
//  Created by ShiStella on 14/12/19.
//  Copyright (c) 2014年 ford. All rights reserved.
//

#import "LockViewController.h"

@interface LockViewController ()

@end

@implementation LockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)unlock:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
