//
//  EAController.h
//  BlueThermIOS-SDK
//
//  Copyright (c) 2012 ETILtd.co.uk All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <ExternalAccessory/ExternalAccessory.h>

#import "ControllerReturn.h"
#import "BlueThermObject.h"
#import "ETIPassingData.h"
#import "AlertMessages.h"
#import "AlertMessageDelegate.h"


@interface EAController : NSObject <EAAccessoryDelegate, NSStreamDelegate, UIAlertViewDelegate>
{
    NSMutableArray  *_accessoryList;
    EASession       *_session;
    EAAccessory     *_selectedAccessory;
    NSMutableArray  *_pa;
    UInt8            holdOff;
}

@property (nonatomic, retain, readonly) ControllerReturn *selectedAccessory;

@property (strong) NSMutableData *writeDataBuffer;
@property (strong) NSMutableData *incomingBuffer;
@property (nonatomic,retain) id <ETIPassingData> callBack;
@property (nonatomic,retain) id <ETIPassingData> notificationCallBack;
@property (nonatomic,retain) id <AlertMessageDelegate> setUpAlerts;

+ (void) setAlertMessagesDelegate: (id <AlertMessageDelegate>) del; //Pass the alertMessage delegate
+ (id <AlertMessageDelegate>) alertMessagesDelegate;

+(EAController*) sharedController;
-(BOOL)openSession;
-(void) writeData:(NSData* )data;
-(void) writeDataSkipHoldOff:(NSData*) data;
+(NSData*)passingData;

//returning if the bluetherm is connected
+(BOOL)isTheProbeConnected;

//get reading from the probe
+(void)doSend;

//show paired BlueTherms
-(void)showBlueThermDeviceList;

@end
