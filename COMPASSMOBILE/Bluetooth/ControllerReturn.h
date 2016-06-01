//
//  controllerReturnValue.h
//  BlueThermIOS-SDK
//
//  Copyright (c) 2012 ETILtd.co.uk All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ExternalAccessory/ExternalAccessory.h>


@interface ControllerReturn: NSObject{
    EAAccessory* _accessory;
}

@property (nonatomic) bool isAwaitingUI;
@property (nonatomic) bool isNoneAvailable;

-SetAccessory:(EAAccessory*) value;
-(EAAccessory*) GetAccessory;

@end

