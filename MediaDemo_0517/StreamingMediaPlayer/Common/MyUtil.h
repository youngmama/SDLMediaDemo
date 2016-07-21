//
//  MyUtil.h
//  StreamingMediaPlayer
//
//  Created by shi stella on 12/16/14.
//  Copyright (c) 2014 ford. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyUtil : NSObject

- (NSMutableArray *)loadRadioListFromPlist;

- (void)addLog:(NSString *)str;
@end
