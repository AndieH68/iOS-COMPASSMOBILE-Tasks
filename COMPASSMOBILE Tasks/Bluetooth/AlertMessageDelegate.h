//
//  AlertMessageDelegate.h
//  BlueThermIOS-SDK
//
//  Copyright (c) 2012 ETILtd.co.uk All rights reserved.
//
//

#import <Foundation/Foundation.h>

@protocol AlertMessageDelegate <NSObject>

-(void)alertMessagesCreateAlertViewNoConnectionFoundSHOW;
-(void)alertMessagesCreateAlertViewNoConnectionFoundDISMISS;
-(void)alertViewConnectionHasBeenLostSHOW;
-(void)alertViewConnectionHasBeenLostDISMISS;

@end
