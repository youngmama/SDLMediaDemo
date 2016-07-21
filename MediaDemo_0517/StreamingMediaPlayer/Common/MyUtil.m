//
//  MyUtil.m
//  StreamingMediaPlayer
//
//  Created by shi stella on 12/16/14.
//  Copyright (c) 2014 ford. All rights reserved.
//

#import "MyUtil.h"
#import "RadioStream.h"
#import "LogInfo.h"
#import "AppDelegate.h"

@implementation MyUtil

- (NSMutableArray *)loadRadioListFromPlist
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"radioList" ofType:@"plist"]];
    NSArray *infoList = [dict objectForKey:@"radioList"];
    
    NSMutableArray * radioList = [[NSMutableArray alloc] init];
    if (infoList !=nil) {
        for (NSDictionary *item in infoList) {
            RadioStream *rs = [[RadioStream alloc] init];
            rs.nameShort = [item objectForKey:@"nameShort"];
            rs.name = [item objectForKey:@"name"];
            rs.url = [item objectForKey:@"url"];
            rs.imageUrl = [item objectForKey:@"image"];
            [radioList addObject:rs];
        }
    }
    return radioList;
}

//- (void)exportToCSV:(NSArray *)logArray byName:(NSString *)fileName
//{
//    [self addLog:@"-------clearCSV-----"];
//    NSMutableString *writeStr = [NSMutableString stringWithCapacity:0];
//    for (LogInfo *log in logArray) {
//        [writeStr appendString:[NSString stringWithFormat:@"*****%@,%@ \n",log.logTime,log.logContent]];
//    }
//    
//    //Moved this stuff out of the loop so that you write the complete string once and only once.
//    NSLog(@"writeString :%@",writeStr);
//    
//    NSString *path = [[self applicationDocumentsDirectory].path
//                      stringByAppendingPathComponent:fileName];
//    if ([writeStr writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil]) {
//        
//    }
//}
//
//
//- (NSURL *)applicationDocumentsDirectory {
//    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
//                                                   inDomains:NSUserDomainMask] lastObject];
//}
//
//-(NSData *)dataFromCSVFile:(NSString *)fileName
//{
//    NSString *path = [[self applicationDocumentsDirectory].path
//                      stringByAppendingPathComponent:fileName];
//    NSData *fileData = [NSData dataWithContentsOfFile:path];
//    return fileData;
//}


#pragma mark --
#pragma add wav head
//typedef struct
//{
//    char chChunkID[4];
//    int nChunkSize;
//}XCHUNKHEADER; //8
//typedef struct
//{
//    short nFormatTag;
//    short nChannels;
//    int nSamplesPerSec;
//    int nAvgBytesPerSec;
//    short nBlockAlign;
//    short nBitsPerSample;
//}WAVEFORMATX; //16
//typedef struct
//{
//    char chRiffID[4];
//    int nRiffSize;
//    char chRiffFormat[4];
//}RIFFHEADER; //12
//
//void WriteWAVEHeader(NSMutableData* fpwave, int nFrame)
//{
//    char tag[10] = "";
//    
//    // 1. 写RIFF头
//    RIFFHEADER riff;
//    strcpy(tag, "RIFF");
//    memcpy(riff.chRiffID, tag, 4);
//    riff.nRiffSize = 4 + sizeof(XCHUNKHEADER) + sizeof(XCHUNKHEADER) + sizeof(WAVEFORMATX) + sizeof(XCHUNKHEADER) + nFrame - 8;
//    strcpy(tag, "WAVE");
//    memcpy(riff.chRiffFormat, tag, 4);
//    [fpwave appendBytes:&riff length:sizeof(RIFFHEADER)];
//    
//    // 2. 写FMT块
//    XCHUNKHEADER chunk;
//    WAVEFORMATX wfx;
//    strcpy(tag, "fmt ");
//    memcpy(chunk.chChunkID, tag, 4);
//    chunk.nChunkSize = sizeof(WAVEFORMATX);
//    [fpwave appendBytes:&chunk length:sizeof(XCHUNKHEADER)];
//    memset(&wfx, 0, sizeof(WAVEFORMATX));
//    wfx.nFormatTag = 1;
//    wfx.nChannels = 1; // 单声道
//    wfx.nSamplesPerSec = 16000; // 16khz
//    wfx.nAvgBytesPerSec = 16000;
//    wfx.nBlockAlign = 2;
//    wfx.nBitsPerSample = 16; // 16位
//    [fpwave appendBytes:&wfx length:sizeof(WAVEFORMATX)];
//    
//    // 3. 写data块头
//    strcpy(tag, "data");
//    memcpy(chunk.chChunkID, tag, 4);
//    chunk.nChunkSize = 4 + sizeof(XCHUNKHEADER) + sizeof(XCHUNKHEADER) + sizeof(WAVEFORMATX) + sizeof(XCHUNKHEADER) + nFrame - 44;
//    [fpwave appendBytes:&chunk length:sizeof(XCHUNKHEADER)];
//}

//add log to list
- (void)addLog:(NSString *)str
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd-HH:mm:ss"];

    LogInfo *log = [[LogInfo alloc] init];
    log.logContent = str;
    log.logTime = [dateFormatter stringFromDate:[NSDate date]];
    AppDelegate *delegate = [AppDelegate getDelegate];
    [delegate.logList addObject:log];

}


@end
