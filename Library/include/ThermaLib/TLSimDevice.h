//
//  TLSimDevice.h
//  ThermaLib
//
//  Created by Chris Leversuch on 17/10/2016.
//  Copyright © 2016 Brightec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLDevice.h"


/// Represents a simulated device where all properties can be manually set
@interface TLSimDevice : NSObject <TLDevice>
@property (strong, nonatomic, readwrite) NSString *manufacturerName;
@property (strong, nonatomic, readwrite) NSString *serialNumber;
@property (strong, nonatomic, readwrite) NSString *modelNumber;
@property (strong, nonatomic, readwrite) NSString *protocolVersion;
@property (strong, nonatomic, readwrite) NSString *hardwareVersion;
@property (strong, nonatomic, readwrite) NSString *softwareRevision;
@property (strong, nonatomic, readwrite) NSString *firmwareRevision;
@property (strong, nonatomic, readwrite) NSString *deviceName;
@property (assign, nonatomic, readwrite) TLDeviceType deviceType;
@property (strong, nonatomic, readwrite) NSString *deviceIdentifier;

@property (strong, nonatomic, readwrite) NSArray<id<TLSensor>> *sensors;
@property (assign, nonatomic) TLDeviceUnit unit;
@property (assign, nonatomic) NSInteger measurementInterval;
@property (assign, nonatomic) NSInteger autoOffInterval;
@property (strong, nonatomic, readwrite) NSNumber *rssi;
@property (assign, nonatomic, readwrite) NSInteger batteryLevel;
@property (assign, nonatomic, readwrite) TLDeviceConnectionState connectionState;
@property (assign, nonatomic, readwrite, getter=isReady) BOOL ready;
@property (assign, nonatomic, readwrite) BOOL userRequestedDisconnect;
@end
