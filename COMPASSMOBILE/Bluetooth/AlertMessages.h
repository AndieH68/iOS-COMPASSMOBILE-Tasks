//
//  AlertMessages.h
//  BlueThermIOS-SDK
//
//  Copyright (c) 2012 ETILtd.co.uk All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "AlertMessageDelegate.h"
#import <UIKit/UIKit.h>
#import "AlertMessageDelegate.h"
#import "EAController.h"

@interface AlertMessages : NSObject <AlertMessageDelegate>

-(void)alertMessagesCreateAlertViewNoConnectionFoundSHOW;
-(void)alertMessagesCreateAlertViewNoConnectionFoundDISMISS;
-(void)alertViewConnectionHasBeenLostSHOW;
-(void)alertViewConnectionHasBeenLostDISMISS;

@end
