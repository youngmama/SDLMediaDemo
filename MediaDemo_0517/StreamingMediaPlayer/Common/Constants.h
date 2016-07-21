//
//  Constants.h
//  StreamingMediaPlayer
//
//  Created by ShiStella on 14/12/19.
//  Copyright (c) 2014年 ford. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

extern const int SBT_ID_PLAY;
extern const int SBT_ID_PAUSE;

typedef enum{
    CMD_ID_LS = 90,
    CMD_ID_APT = 91,
    CMD_ID_CSPIB = 92,
    CMD_ID_CSPIM = 93,
    CMD_ID_RADIO_START = 100
} CommandIDs;

typedef enum{
    CH_ID_RADIO_START = 100
} Choices;

typedef enum{
    CS_ID_STATIONS = 1
} ChoiceSets;


@end
