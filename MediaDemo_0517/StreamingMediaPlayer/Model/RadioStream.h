//
//  RadioStream.h
//  StreamingMediaPlayer
//
//  Created by shi stella on 12/16/14.
//  Copyright (c) 2014 ford. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RadioStream : NSObject

@property (nonatomic, strong) NSString *nameShort;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *imageUrl;

@end
