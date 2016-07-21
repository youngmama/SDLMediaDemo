//
//  ViewController.m
//  StreamingMediaPlayer
//
//  Created by shi stella on 12/9/14.
//  Copyright (c) 2014 ford. All rights reserved.
//

// These should be replaced with a vaild AppName and AppID
#define PLACEHOLDER_APPNAME @"Media Player Demo"
#define PLACEHOLDER_APPID @"44770123"

// IDs used in the settings bundle
#define PREFS_FIRST_RUN @"firstRun"
#define PREFS_PROTOCOL @"protocol"
#define PREFS_IPADDRESS @"ipaddress"
#define PREFS_PORT @"port"

#define kContentViewTag 88

#import "ViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "RadioStream.h"
#import "MyUtil.h"
#import "LockViewController.h"
#import "Constants.h"
#import "LogInfo.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController{
    UIButton *clearBtn;
    
    NSArray *contents;
    NSMutableArray *contentList;
    NSArray *menuList;
    MPMoviePlayerController *player;
    
    NSMutableArray *streamList;
    NSMutableArray *presetList;
    
    int nowPlayNum;//the number of which stream is now playing
    
    BOOL isPausedForSpeak;
    
    BOOL isFirstRun;
    BOOL isLocked;
    
    // We'll keep track of the ids of album art putFiles, removing them from this array when they complete
    NSMutableArray *albumArtPutFileCorrIds;
    BOOL isAlbumArtAvailable;
    
    NSMutableArray *softButtons;
    
    SDLSoftButton *playPauseBtn;
    BOOL isNowPlaying;
    
    NSMutableData *mData;//data for save audio pass thru
    
    MyUtil *mUtil;
    
    BOOL isLogShown;
    
    CGRect hostFrame;//screen frame
    
    BOOL isTouchScreen;//if the GEN3
    
    NSNumber *appIconCorrID;
    
    AppDelegate *delegate;
    
    BOOL mAudible;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mUtil = [[MyUtil alloc] init];
    isLogShown = YES;
    
    [mUtil addLog:@"ViewController viewDidLoad"];
    
    delegate = [AppDelegate getDelegate];
    
    hostFrame = [[UIScreen mainScreen] applicationFrame];
    
    self.navigationController.navigationBarHidden = YES;
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    float screenWidth = [[UIScreen mainScreen] bounds].size.width;
    float screenHeight = [[UIScreen mainScreen] bounds].size.height;
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 70)];
    _topView.backgroundColor = [UIColor brownColor];
    [self.view addSubview:_topView];
    
    contentList = [[NSMutableArray alloc] init];
    _contentTableView = [[UITableView alloc] initWithFrame:CGRectMake(6, 120, screenWidth-12, screenHeight-110)];
    [self.view addSubview:_contentTableView];
    _contentTableView.dataSource = self;
    _contentTableView.delegate = self;
    _contentTableView.tag = kContentViewTag;
    
    //add logo and name
    UIImageView *logView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 30, 36, 36)];
    logView.image = [UIImage imageNamed:@"test120.png"];
    [_topView addSubview:logView];
    
    UILabel *appnameLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 30, 200, 36)];
    appnameLabel.text = @"Media Player Demo";
    [_topView addSubview:appnameLabel];
    
    clearBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [clearBtn setFrame:CGRectMake(hostFrame.size.width-110, 80, 100, 30)];
    clearBtn.backgroundColor = [UIColor blackColor];
    [clearBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [clearBtn addTarget:self action:@selector(didTapClear:) forControlEvents:UIControlEventTouchUpInside];
    [clearBtn setTitle:NSLocalizedString(@"Clear", nil) forState:UIControlStateNormal];
    [self.view addSubview:clearBtn];

    //load all stream objects
    streamList = [mUtil loadRadioListFromPlist];
    
    nowPlayNum = 0;
    mAudible = YES;
    
    softButtons = [[NSMutableArray alloc] init];
    isFirstRun = YES;
    isNowPlaying = NO;
    [self setupProxy];
    [self startBackgroundStreaming];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    isLocked = NO;
    [mUtil addLog:@"ViewController viewDidAppear"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)didTapClear:(UIButton *)sender
{
    [contentList removeAllObjects];
    contents= nil;
    [_contentTableView reloadData];
}


//add data to contents and reload table
- (void)addData:(NSString *)str
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    LogInfo *log = [[LogInfo alloc] init];
    log.logContent = str;
    log.logTime = [dateFormatter stringFromDate:[NSDate date]];
    [contentList addObject:log];
    contents = (NSArray *)[contentList copy];
    [_contentTableView reloadData];
    
    [mUtil addLog:str];
}


- (void)testLoadData
{
    for (int i = 0; i<100; i++) {
        [self addData:[NSString stringWithFormat:@"%d",i]];
    }
}

- (void)playStreamAtIndex:(int)index
{
    nowPlayNum = index;
    RadioStream *rs = [streamList objectAtIndex:index];
    [self playStream:rs];
    playPauseBtn.text = @"Pause";
    
    [self showNowPlaying];
}

-(void)showNowPlaying {
    
    RadioStream *rs = [streamList objectAtIndex:nowPlayNum];
    NSString *mediaTrackString = [NSString stringWithFormat:@"%d/%d",nowPlayNum + 1,(int)[streamList count]];
    
    if (isAlbumArtAvailable) {
        // Since album art is available, include it with the show
        SDLImage *image = [[SDLImage alloc] init];
        image.value = rs.name;
        image.imageType = [SDLImageType DYNAMIC];
        [self updateShowScreenMainText1:@"Playing..."
                              MainText2:rs.name
                             MediaTrack:mediaTrackString
                            SoftButtons:softButtons
                                Presets:nil
                                Graphic:image];
    } else {
        [self updateShowScreenMainText1:@"Playing..."
                              MainText2:rs.name
                             MediaTrack:mediaTrackString
                            SoftButtons:softButtons];
    }
}

- (void)playStream:(RadioStream *)stream
{
    isNowPlaying = YES;
    
    NSURL *url = [NSURL URLWithString:stream.url];
    
    if(player != nil){
        [player stop];
        player = nil;
    }
    player = [[MPMoviePlayerController alloc] initWithContentURL:url];
    player.view.hidden = YES;
    
    [player prepareToPlay];
    [player play];
    
    [player setShouldAutoplay:YES];

    //test media clock timer
    SDLSetMediaClockTimer *clockTimerReq = [SDLRPCRequestFactory buildSetMediaClockTimerWithUpdateMode: [SDLUpdateMode COUNTUP] correlationID:[NSNumber numberWithInt:self.autoIncCorrID++]];
    
    SDLStartTime *startTime = [[SDLStartTime alloc] init];
    startTime.hours = [NSNumber numberWithFloat:0.0];
    startTime.minutes = [NSNumber numberWithFloat:0.0];
    startTime.seconds = [NSNumber numberWithFloat:0.0];
    
    SDLStartTime *endTime = [[SDLStartTime alloc] init];
    endTime.hours = [NSNumber numberWithFloat:1.0];
    endTime.minutes = [NSNumber numberWithFloat:0.0];
    endTime.seconds = [NSNumber numberWithFloat:0.0];
    
    clockTimerReq.startTime = startTime;
    clockTimerReq.endTime = endTime;
    [self.proxy sendRPC:clockTimerReq];
    [self addData:@"send clock timer request"];
}

- (void)stopStream
{
    if (player != nil) {
        isNowPlaying = NO;
        [player stop];
        player = nil;
    }
}

#pragma mark --
#pragma UITableViewDataSourceDelegate
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [contents count];
}

#pragma mark --
#pragma UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"simpleCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    LogInfo * log = [contents objectAtIndex:indexPath.row];
    NSString *displayStr = [NSString stringWithFormat:@"%@ \n%@",log.logTime,log.logContent];
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.text = displayStr;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LogInfo *log = [contents objectAtIndex:indexPath.row];
    NSString * displayStr = [NSString stringWithFormat:@"%@,\n %@",log.logTime,log.logContent];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Detail" message:displayStr delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark Settings Bundle Defaults
-(void) savePreferences {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    //Set to match settings.bundle defaults
    if (![[prefs objectForKey:PREFS_FIRST_RUN] isEqualToString:@"False"]) {
        [prefs setObject:@"False" forKey:PREFS_FIRST_RUN];
        [prefs setObject:@"iap" forKey:PREFS_PROTOCOL];
        [prefs setObject:@"192.168.0.1" forKey:PREFS_IPADDRESS];
        [prefs setObject:@"50007" forKey:PREFS_PORT];
        
        [prefs synchronize];
    }
}

#pragma Applink proxy
-(void) setupProxy {
    [SDLDebugTool logInfo:@"setupProxy"];
    [self addData:@"setupProxy"];

    [self addData:[NSString stringWithFormat:@"registering as: %@ appid: %@", PLACEHOLDER_APPNAME, PLACEHOLDER_APPID]];
    
    if (isFirstRun) {
        [self savePreferences];
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([[prefs objectForKey:PREFS_PROTOCOL] isEqualToString:@"tcpl"]) {
        _proxy = [SDLProxyFactory buildSDLProxyWithListener:self tcpIPAddress:nil tcpPort:nil];
    } else if ([[prefs objectForKey:PREFS_PROTOCOL] isEqualToString:@"tcps"]) {
        _proxy = [SDLProxyFactory buildSDLProxyWithListener:self tcpIPAddress:[prefs objectForKey:PREFS_IPADDRESS] tcpPort:[prefs objectForKey:PREFS_PORT]];
    } else{
        _proxy = [SDLProxyFactory buildSDLProxyWithListener:self];
    }

    _autoIncCorrID = 101;
    
    NSString *proxyVersion = _proxy.proxyVersion;
    NSLog(@"ProxyVersion = %@", proxyVersion);
}

-(void) teardownProxy {
    [SDLDebugTool logInfo:@"teardownProxy"];
    [self addData:@"teardownProxy"];
    [_proxy dispose];
    _proxy = nil;
}

#pragma mark --
#pragma SDLProxyListener
-(void) onOnDriverDistraction:(SDLOnDriverDistraction*) notification
{
    [self addData:@"onOnDriverDistraction"];
}

-(void) onOnHMIStatus:(SDLOnHMIStatus*) notification
{
    if (notification.hmiLevel == SDLHMILevel.NONE ) {
        
        [SDLDebugTool logInfo:@"HMI_NONE"];
        [self unlockUserInterface];
        [self addData:@"HMI_NONE"];
    } else if (notification.hmiLevel == SDLHMILevel.FULL ) {
        
        [SDLDebugTool logInfo:@"HMI_FULL"];
        [self addData:@"HMI_FULL"];
        if(isFirstRun){
            [self lockUserInterface];
            
            dispatch_queue_t backgroundQueue = dispatch_queue_create("backgroundThread", NULL);
            dispatch_async(backgroundQueue, ^{
                [self sendAlbumArtPutFiles];
            });

            [self playStreamAtIndex:0];
            //send RPCs seperately by some time intervals to void block
            [self performSelector:@selector(buildSoftbuttons) withObject:nil afterDelay:1];
            [self performSelector:@selector(sendInitCommands) withObject:nil afterDelay:3];
            [self performSelector:@selector(subscribeButtons) withObject:nil afterDelay:5];
            isFirstRun = NO;
        }
        
    } else if (notification.hmiLevel == SDLHMILevel.BACKGROUND ) {
        [SDLDebugTool logInfo:@"HMI_BACKGROUND"];
        [self addData:@"HMI_BACKGROUND"];
    } else if (notification.hmiLevel == SDLHMILevel.LIMITED ) {
        [SDLDebugTool logInfo:@"HMI_LIMTED"];
        [self addData:@"HMI_LIMITED"];
    }
    
    if (notification.audioStreamingState == SDLAudioStreamingState.AUDIBLE) {
        mAudible = YES;
        [self addData:@"notification.audioStreamingState = Audible"];

        if (!isNowPlaying) {
            [self playStreamAtIndex:nowPlayNum];
            [self addData:@"Audible playStream"];
        }
    }else{
        mAudible = NO;
        [self stopStream];
        [self addData:@"notification.audioStreamingState = NOT Audible, stopStream"];
    }
}

-(void) onProxyClosed
{
    [self addData:@"onProxyClosed"];

    [self stopStream];
    [self unlockUserInterface];
    [self teardownProxy];
    [self setupProxy];
    isFirstRun = YES;
}

-(void) onProxyOpened
{
    [self addData:@"onProxyOpened"];
    [SDLDebugTool logInfo:@"onProxyOpened"];
    SDLRegisterAppInterface* raiRequest = [SDLRPCRequestFactory buildRegisterAppInterfaceWithAppName:PLACEHOLDER_APPNAME languageDesired:[SDLLanguage EN_US] appID:PLACEHOLDER_APPID];
    raiRequest.isMediaApplication = [NSNumber numberWithBool:YES];
    raiRequest.ngnMediaScreenAppName = nil;
    raiRequest.vrSynonyms = [NSMutableArray arrayWithObjects:@"Media Player Demo",@"SRP",@"SRP测试",nil];
    
    //Build ttsName Array
    NSMutableArray *ttsName = [NSMutableArray arrayWithObject:[SDLTTSChunkFactory buildTTSChunkForString:@"Media Player Demo" type:SDLSpeechCapabilities.TEXT]];
    raiRequest.ttsName = ttsName; 
    
    [_proxy sendRPC:raiRequest];
}

- (void) buildSoftbuttons
{
    //clear the softbuttons array before build
    if ([softButtons count] > 0) {
        [softButtons removeAllObjects];
    }
    [self addData:@"buildSoftbuttons"];
    if (!isTouchScreen) {//if touchScreen, no need for pause/play
        [self addData:@"buildSoftButtons -- is not TouchScreen"];
        playPauseBtn = [[SDLSoftButton alloc] init];
        playPauseBtn.type = [SDLSoftButtonType TEXT];
        playPauseBtn.text = NSLocalizedString(@"Pause", nil);
        playPauseBtn.softButtonID = [NSNumber numberWithInt:SBT_ID_PLAY];
        playPauseBtn.systemAction = [SDLSystemAction DEFAULT_ACTION];
        playPauseBtn.isHighlighted = [NSNumber numberWithBool:YES];
        [softButtons addObject:playPauseBtn];
    }
    
    if (streamList!=nil && [streamList count]>0) {
        int i = 1;
        for (RadioStream *stream in streamList) {
            if (i<6) {//softbuttons only 7 max, set to 6 to match the Android implementation
                
                SDLSoftButton *btn = [[SDLSoftButton alloc] init];
                btn.type = [SDLSoftButtonType TEXT];
                btn.text = stream.nameShort;
                btn.softButtonID = [NSNumber numberWithInt:(SBT_ID_PLAY+i)];
                btn.systemAction = [SDLSystemAction DEFAULT_ACTION];
                btn.isHighlighted = [NSNumber numberWithBool:NO];
                [softButtons addObject:btn];
                i++;
            }
        }
    }
}

- (void)sendPutFile
{
    NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
//    NSString *filePath = [resourcePath stringByAppendingPathComponent:@"soma.png"];
    NSString *filePath = [resourcePath stringByAppendingPathComponent:@"test120.png"];
    UIImage *sendImg = [UIImage imageWithContentsOfFile:filePath];
    NSData *imgData = UIImagePNGRepresentation(sendImg);

    [self addData:[NSString stringWithFormat:@"sendPutFile---[size=%lu]---",(unsigned long)imgData.length]];
    SDLPutFile *putFile = [[SDLPutFile alloc] init];
    putFile.fileType = [SDLFileType GRAPHIC_PNG];
    putFile.syncFileName = @"test120.png";
    putFile.bulkData = imgData;
    putFile.length = [NSNumber numberWithInteger:imgData.length];
    putFile.offset = [NSNumber numberWithInt:0];
    putFile.persistentFile = [NSNumber numberWithBool:NO];
    putFile.correlationID = [NSNumber numberWithInt:_autoIncCorrID++];
    appIconCorrID = putFile.correlationID;
    [_proxy sendRPC:putFile];
}

- (void)sendPutFileByURL:(NSString *)urlStr Name:(NSString *)name correlationID:(NSNumber*)corrId
{
    NSURL *url = [NSURL URLWithString:urlStr];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    [self addData:[NSString stringWithFormat:@"sendPutFileByUrl:%@",urlStr]];
    
    NSString *trimmedString=[urlStr substringFromIndex:MAX((int)[urlStr length]-4, 0)];
    SDLPutFile *putFile = [[SDLPutFile alloc] init];
    if ([trimmedString isEqualToString:@"png"]) {
        putFile.fileType = [SDLFileType GRAPHIC_PNG];
    }else if ([trimmedString isEqualToString:@"jpg"]){
        putFile.fileType = [SDLFileType GRAPHIC_JPEG];
    }else{
        putFile.fileType = [SDLFileType GRAPHIC_BMP];
    }
    
    putFile.syncFileName = name;
    putFile.bulkData = data;
    putFile.length = [NSNumber numberWithInteger:data.length];
    putFile.offset = [NSNumber numberWithInt:0];
    putFile.persistentFile = [NSNumber numberWithBool:NO];
    putFile.correlationID = corrId;
    [_proxy sendRPC:putFile];
}

- (void)sendPutFileByURL:(NSString *)urlStr Name:(NSString *)name
{
    [self sendPutFileByURL:urlStr
                      Name:name
             correlationID:[NSNumber numberWithInt:_autoIncCorrID++]];
}

- (void)sendAlbumArtPutFiles
{
    
    albumArtPutFileCorrIds = [NSMutableArray array];
    
    if (streamList!=nil && [streamList count]>0) {
        
        for (RadioStream *rs in streamList) {
            NSNumber *corrId = [NSNumber numberWithInt:_autoIncCorrID++];
            [albumArtPutFileCorrIds addObject:corrId];
            [self sendPutFileByURL:rs.imageUrl Name:rs.name correlationID:corrId];
        }
    }
}

- (void)sendInitCommands{
    SDLRPCRequest* msg = nil;

    msg = [SDLRPCRequestFactory buildAddCommandWithID:[NSNumber numberWithInt:CMD_ID_LS] menuName:@"List Stations" parentID:0 position:0 vrCommands:nil iconValue:nil iconType:nil correlationID:[NSNumber numberWithInt:_autoIncCorrID++]];
    [_proxy sendRPC:msg];

    msg = [SDLRPCRequestFactory buildAddCommandWithID:[NSNumber numberWithInt:CMD_ID_CSPIB] menuName:@"Choose Station Perform Inter Both" parentID:0 position:[NSNumber numberWithInt:2] vrCommands:[NSArray arrayWithObjects:@"Choose Station Perform Inter Both", nil] iconValue:nil iconType:nil correlationID:[NSNumber numberWithInt:_autoIncCorrID++]];
    [_proxy sendRPC:msg];

    msg = [SDLRPCRequestFactory buildAddCommandWithID:[NSNumber numberWithInt:CMD_ID_CSPIM] menuName:@"Choose Station Perform Inter Menu" parentID:0 position:[NSNumber numberWithInt:3] vrCommands:[NSArray arrayWithObjects:@"Choose Station Perform Inter Menu", nil] iconValue:nil iconType:nil correlationID:[NSNumber numberWithInt:_autoIncCorrID++]];
    [_proxy sendRPC:msg];


    SDLTTSChunk *helpPromptchunk1 = [[SDLTTSChunk alloc] init];
    helpPromptchunk1.text = @" the name of any station, or choose station, you can also say list stations";
    helpPromptchunk1.type = [SDLSpeechCapabilities TEXT];
    
    NSMutableArray *choices = [[NSMutableArray alloc] init];
    if (streamList!=nil && [streamList count]>0) {
        int i = 0;
        for (RadioStream *rs in streamList) {
            if (rs != nil && rs.name != nil) {
                
                // Create station choice
                SDLChoice *choice = [[SDLChoice alloc] init];
                choice.choiceID = [NSNumber numberWithInt:(CH_ID_RADIO_START + i)];
                choice.menuName = rs.name;
                choice.vrCommands = [NSMutableArray arrayWithObject:rs.name];
                [choices addObject:choice];

                // Create station command
                SDLAddCommand *radioCom = [SDLRPCRequestFactory buildAddCommandWithID:[NSNumber numberWithInt:(CMD_ID_RADIO_START + i)] vrCommands:[NSArray arrayWithObjects:rs.name, nil] correlationID:[NSNumber numberWithInt:_autoIncCorrID++]];
                [_proxy sendRPC:radioCom];
                i++;
            }
        }
    }

    // Create choiceset
    if (choices != nil && [choices count] > 0) {
        msg = [SDLRPCRequestFactory buildCreateInteractionChoiceSetWithID:[NSNumber numberWithInt:CS_ID_STATIONS] choiceSet:choices correlationID:[NSNumber numberWithInt:_autoIncCorrID++]];
        [self.proxy sendRPC:msg];
    }

    // Override the default help menu
    SDLSetGlobalProperties *sgpRequest = [[SDLSetGlobalProperties alloc] init];
    sgpRequest.helpPrompt = [NSMutableArray arrayWithObject:helpPromptchunk1];
    sgpRequest.correlationID = [NSNumber numberWithInt:_autoIncCorrID++];
    
    // The vrhelpitem and vrhelp title shouldn't be required... but they make it work..
    SDLVRHelpItem *helpItem1 = [[SDLVRHelpItem alloc] init];
    helpItem1.text = @"Media Player Demo Help";
    helpItem1.image = nil;
    helpItem1.position = [NSNumber numberWithInt:1];
    sgpRequest.vrHelp = [NSMutableArray arrayWithObject:helpItem1];
    sgpRequest.vrHelpTitle = @"Media Player Demo Help";
    [self.proxy sendRPC:sgpRequest];
}

- (void)subscribeButtons{
    [self addData:@"subscribeButtons"];
    SDLSubscribeButton *sub_OK = [SDLRPCRequestFactory buildSubscribeButtonWithName:[SDLButtonName OK] correlationID:[NSNumber numberWithInt: _autoIncCorrID++]];
    [_proxy sendRPC:sub_OK];
    SDLSubscribeButton *sub_SeekLeft = [SDLRPCRequestFactory buildSubscribeButtonWithName:[SDLButtonName SEEKLEFT] correlationID:[NSNumber numberWithInt: _autoIncCorrID++]];
    [_proxy sendRPC:sub_SeekLeft];
    SDLSubscribeButton *sub_SeekRight = [SDLRPCRequestFactory buildSubscribeButtonWithName:[SDLButtonName SEEKRIGHT] correlationID:[NSNumber numberWithInt: _autoIncCorrID++]];
    [_proxy sendRPC:sub_SeekRight];

}


- (void)updateShowScreenMainText1:(NSString*)text1 MainText2:(NSString*)text2 MediaTrack:(NSString*)track SoftButtons:(NSMutableArray*)buttons
{
    SDLShow* showRequest = [SDLRPCRequestFactory buildShowWithMainField1:text1 mainField2:text2 mainField3:nil mainField4:nil statusBar:nil mediaClock:nil mediaTrack:track alignment:nil graphic:nil softButtons:buttons customPresets:nil correlationID:[NSNumber numberWithInt:self.autoIncCorrID++]];
    [self.proxy sendRPC:showRequest];
}

- (void)updateShowScreenMainText1:(NSString*)text1 MainText2:(NSString*)text2 MediaTrack:(NSString*)track SoftButtons:(NSMutableArray*)buttons Presets:(NSArray *)presetArray Graphic:(SDLImage *)image
{
    SDLShow* showRequest = [SDLRPCRequestFactory buildShowWithMainField1:text1 mainField2:text2 mainField3:nil mainField4:nil statusBar:nil mediaClock:nil mediaTrack:track alignment:nil graphic:image softButtons:buttons customPresets:presetArray correlationID:[NSNumber numberWithInt:self.autoIncCorrID++]];
    [self.proxy sendRPC:showRequest];
}


-(void)alertText1:(NSString*)text1 Text2:(NSString*)text2{
    SDLAlert* alert = [SDLRPCRequestFactory buildAlertWithAlertText1:text1 alertText2:text2 alertText3:nil duration:[NSNumber numberWithInt:3000] softButtons:nil correlationID:[NSNumber numberWithInt:_autoIncCorrID++]];
    [_proxy sendRPC:alert];
}


#pragma mark --
#pragma AppLink Callbacks


-(void)onSpeakResponse:(SDLSpeakResponse *)response
{
    [self addData:[NSString stringWithFormat:@"onSpeakResponse is %@ + result code is %@",response.info,response.resultCode]];
}

-(void)onAlertResponse:(SDLAlertResponse *)response
{

}

-(void) onSetMediaClockTimerResponse:(SDLSetMediaClockTimerResponse *)response{
    [self addData:[NSString stringWithFormat:@"SetMediaClockTimer Response is %@ + result code is %@",response.info,response.resultCode]];
}

-(void) onAddCommandResponse:(SDLAddCommandResponse *)response{
     [self addData:[NSString stringWithFormat:@"onAddCommandResponse is %@ + result code is %@",response.info,response.resultCode]];
}

-(void) onShowResponse:(SDLShowResponse *)response{
    [self addData:[NSString stringWithFormat:@"Show Response is %@ + result code is %@",response.info,response.resultCode]];
}

-(void) onCreateInteractionChoiceSetResponse:(SDLCreateInteractionChoiceSetResponse *)response{
}

-(void) onSliderResponse:(SDLSliderResponse *)response
{
    [self addData:[NSString stringWithFormat:@"Show onSliderResponse is %@ + result code is %@",response.info,response.resultCode]];
}


-(void) onPerformInteractionResponse:(SDLPerformInteractionResponse *)response{
    if ([[response resultCode] isEqual:[SDLResult SUCCESS]])
    {
        int choiceId = [[response choiceID] intValue];
        
        if (choiceId >= CH_ID_RADIO_START) {
            if (player) {
                [player stop];
            }
            [self playStreamAtIndex:choiceId - CH_ID_RADIO_START];
        }
    }
}

-(void) onScrollableMessageResponse:(SDLScrollableMessageResponse *)response{
    [self addData:[NSString stringWithFormat:@"onScrollableMessageResponse is %@ + result code is %@",response.info,response.resultCode]];
}

-(void)onRegisterAppInterfaceResponse:(SDLRegisterAppInterfaceResponse *)response
{
    SDLDisplayCapabilities *capabilities = response.displayCapabilities;
    SDLDisplayType *type = capabilities.displayType;
    NSNumber *suc = response.success;
    NSString *resultCode = response.resultCode.value;
    NSString *info = response.info;
    
    [self addData:[NSString stringWithFormat:@"onRegisterAppInterfaceResponse:[Success:%d],[resultCode:%@],[info:%@],[response.displayCapbilities: %@" ,suc.intValue,resultCode,info,capabilities]];

    if ([type isEqual:[SDLDisplayType GEN3_8_INCH]]) {
        isTouchScreen = YES;
        [self addData:@"is touch screen"];
    }else{
        isTouchScreen = NO;
        [self addData:@"is not touch screen"];
    }
    [self addData:[NSString stringWithFormat:@"onRegisterAppInterfaceResponse [capabilities.displayType:%@][type.value: %@]",capabilities.displayType,type.value]];
    
    [self sendPutFile];
}

- (void)onPutFileResponse:(SDLPutFileResponse *)response
{
    [self addData:[NSString stringWithFormat:@"--onPutFileResponse is %@ + result code is %@-------",response.info,response.resultCode]];
    
    if (response.resultCode == [SDLResult SUCCESS] && appIconCorrID != nil) {
        
        if ([response.correlationID compare:appIconCorrID] == NSOrderedSame) {
            SDLSetAppIcon *icon = [SDLSetAppIcon new];
            icon.syncFileName = @"test120.png";
            icon.correlationID = [NSNumber numberWithInt:_autoIncCorrID++];
            [_proxy sendRPC:icon];
            [self addData:@"-------setAppIcon Request sent--------"];
        } else {
            // See if this correlation ID matches an album art putFile request
            NSNumber *matchingCorrId = nil;
            for (NSNumber *corrId in albumArtPutFileCorrIds) {
                if ([response.correlationID compare:corrId] == NSOrderedSame) {
                    matchingCorrId = corrId;
                    break;
                }
            }
            // If we found a match, remove it from the album art IDs array and see if all album art has been loaded
            if (matchingCorrId) {
                [albumArtPutFileCorrIds removeObject:matchingCorrId];
                if ([albumArtPutFileCorrIds count] == 0) {
                    
                    // All album art is loaded, send another show to include album art in now playing
                    isAlbumArtAvailable = YES;
                    [self showNowPlaying];
                }
            }
        }
    }
}

-(void)turnMusicBackOn {
    if (isPausedForSpeak) {
        [self playOrPause];
        isPausedForSpeak = NO;
    }
}

- (void) onOnCommand:(SDLOnCommand *)notification
{
    int cmdID = [notification.cmdID intValue];
    
    if (cmdID == CMD_ID_LS){
        SDLTTSChunk *chunk1 = [[SDLTTSChunk alloc] init];
        chunk1.text = @"You can say any of the following stations: ";
        chunk1.type = [SDLSpeechCapabilities TEXT];
        NSMutableArray * listArray = [[NSMutableArray alloc] initWithObjects:chunk1, nil];
        if (streamList !=nil) {
            for (RadioStream *rs in streamList) {
                SDLTTSChunk *chunk = [[SDLTTSChunk alloc] init];
                chunk.text = [NSString stringWithFormat:@"%@. ", rs.name];
                chunk.type = [SDLSpeechCapabilities TEXT];
                [listArray addObject:chunk];
            }
        }
        
        isPausedForSpeak = NO;
        SDLSpeak *speak = [SDLRPCRequestFactory buildSpeakWithTTSChunks:listArray correlationID:[NSNumber numberWithInt:(_autoIncCorrID+1)]];
        if (isNowPlaying) {
            [self playOrPause];
            isPausedForSpeak = YES;
            
            // turnMusicBackOn's logic should happen in the speak response, but it isn't being triggered at this time. This is the workaround:
            [self performSelector:@selector(turnMusicBackOn) withObject:nil afterDelay:11.5];
        }
        
        [_proxy sendRPC:speak];
    } else if (cmdID == CMD_ID_APT) {
        SDLPerformAudioPassThru * apt = [SDLRPCRequestFactory buildPerformAudioPassThruWithInitialPrompt:@"Say anything to be played back" audioPassThruDisplayText1:@"APT Test" audioPassThruDisplayText2:@"Say anything" samplingRate:[SDLSamplingRate _16KHZ] maxDuration:[NSNumber numberWithInt:30000] bitsPerSample:[SDLBitsPerSample _16_BIT] audioType:[SDLAudioType PCM] muteAudio:nil correlationID:[NSNumber numberWithInt:(_autoIncCorrID+1)]];
        [_proxy sendRPC:apt];
    } else if (cmdID == CMD_ID_CSPIB) {
        // Perform the interaction choice set
        SDLRPCRequest *msg = nil;
        SDLInteractionMode *im = [SDLInteractionMode BOTH];
        msg = [SDLRPCRequestFactory buildPerformInteractionWithInitialPrompt:@"Say the name of a station" initialText:@"Say Station Name" interactionChoiceSetIDList:[NSArray arrayWithObject:[NSNumber numberWithInt:CS_ID_STATIONS]] helpPrompt:@"Say the name of a station" timeoutPrompt:@"No station selected" interactionMode:im timeout:[NSNumber numberWithInt:30000] correlationID:[NSNumber numberWithInt:(_autoIncCorrID+1)]];
        [self.proxy sendRPC:msg];
    } else if (cmdID == CMD_ID_CSPIM) {
        // Perform the interaction choice set
        SDLRPCRequest *msg = nil;
        SDLInteractionMode *im = [SDLInteractionMode MANUAL_ONLY];
        msg = [SDLRPCRequestFactory buildPerformInteractionWithInitialPrompt:@"Choose a station" initialText:@"Choose A Station" interactionChoiceSetIDList:[NSArray arrayWithObject:[NSNumber numberWithInt:CS_ID_STATIONS]] helpPrompt:@"Choose a station" timeoutPrompt:@"No station selected" interactionMode:im timeout:[NSNumber numberWithInt:30000] correlationID:[NSNumber numberWithInt:(_autoIncCorrID+1)]];
        [self.proxy sendRPC:msg];
    } else if (cmdID >= CMD_ID_RADIO_START) {
        if (player) {
            [player stop];
        }
        [self playStreamAtIndex:cmdID - CMD_ID_RADIO_START];
    }
}

- (void) onOnButtonPress:(SDLOnButtonPress *)notification
{
    if(notification.buttonName == [SDLButtonName OK]){
        [self playOrPause];
    }else if(notification.buttonName == [SDLButtonName SEEKLEFT]){
        if (nowPlayNum == 0) {
            nowPlayNum = 2;
        }else{
            nowPlayNum--;
        }
        [self playStreamAtIndex:nowPlayNum];
    }else if(notification.buttonName == [SDLButtonName SEEKRIGHT]){
        if (nowPlayNum == 2) {
            nowPlayNum = 0;
        }else{
            nowPlayNum++;
        }
        [self playStreamAtIndex:nowPlayNum];
    }else{
        [self playStreamAtIndex:nowPlayNum];
    }
    
}

- (void)onSetGlobalPropertiesResponse:(SDLSetGlobalPropertiesResponse *)response {
    [self addData:[NSString stringWithFormat:@"SetGlobalProperties: %@, %@", response.success, response.resultCode]];
}

- (void)playOrPause
{
    [self addData:[NSString stringWithFormat:@"playOrPause called"]];

    NSString *firstText;
    if (isNowPlaying) {
        if (player) {
            isNowPlaying = NO;
            [player pause];
            [self addData:[NSString stringWithFormat:@"Pause Audio"]];
            [playPauseBtn setText:@"Play"];
            firstText = @"Paused!";
            [_proxy sendRPC:[SDLRPCRequestFactory buildSetMediaClockTimerWithUpdateMode:[SDLUpdateMode PAUSE] correlationID:[NSNumber numberWithInt:_autoIncCorrID++]]];
        }
    }else{
        isNowPlaying = YES;
        [player play];
        [self addData:[NSString stringWithFormat:@"Play Audio"]];
        [playPauseBtn setText:@"Pause"];
        firstText = @"Playing...";
        [_proxy sendRPC:[SDLRPCRequestFactory buildSetMediaClockTimerWithUpdateMode:[SDLUpdateMode RESUME] correlationID:[NSNumber numberWithInt:_autoIncCorrID++]]];
    }
    RadioStream *nowRS = [streamList objectAtIndex:nowPlayNum];
    [self updateShowScreenMainText1:firstText MainText2:nowRS.name MediaTrack:[NSString stringWithFormat:@"%d/%d",nowPlayNum+1,(int)[streamList count]] SoftButtons:softButtons];
}

#pragma mark --
#pragma Lock Screen methods
- (void)lockUserInterface
{
    if (!isLocked) {
        [SDLDebugTool logInfo:@"lockUserInterface"];
        [self addData:@"lockUserInterface"];
        isLocked = YES;
        LockViewController *lockVC = [[LockViewController alloc] init];
        [self.navigationController pushViewController:lockVC animated:YES];
    }
}

- (void)unlockUserInterface
{
    if (isLocked) {
        [SDLDebugTool logInfo:@"unlockUserInterface"];
        [self addData:@"unlockUserInterface"];
        isLocked = NO;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark --
#pragma play in background
- (void)startBackgroundStreaming
{
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    NSError *activationError = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&activationError];
    [audioSession setActive:YES error:&activationError];
}


@end
