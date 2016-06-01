//
//  ETIPassingData.h
//  BlueThermIOS-SDK
//
//  Copyright (c) 2012 ETILtd.co.uk All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ETIPassingData <NSObject>

-(void)readingAndDisplaying;//read probe values
-(void)settingTheProbe;//set probe values
-(void)probeButtonHasBeenPressed; //probe button has been pressed

-(void)blueThermConnected;
-(void)bluethermDisconnected;
-(void)newBlueThermFound;

-(void)soundtheAlarmInBackground;


//Emissivity setting
-(void)displayEmissivity;

@end
