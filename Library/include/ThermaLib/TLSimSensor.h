//
//  TLSimSensor.h
//  ThermaLib
//
//  Created by Chris Leversuch on 17/10/2016.
//  Copyright © 2016 Brightec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLSensor.h"


/// Represents a simulated sensor where all properties can be manually set
@interface TLSimSensor : NSObject <TLSensor>
@property (strong, nonatomic, readwrite) id<TLDevice> device;
@property (assign, nonatomic) float trimValue;
@property (strong, nonatomic, readwrite) TLDateStamp *trimSetDate;
@property (assign, nonatomic, readwrite) float reading;
@property (assign, nonatomic) float highAlarm;
@property (assign, nonatomic) BOOL highAlarmEnabled;
@property (assign, nonatomic) float lowAlarm;
@property (assign, nonatomic) BOOL lowAlarmEnabled;
@property (assign, nonatomic, readwrite) TLSensorType type;
@property (assign, nonatomic, readwrite) NSUInteger index;
@property (assign, nonatomic, getter=isEnabled) BOOL enabled;
@property (assign, nonatomic, readwrite, getter=isFault) BOOL fault;
@property (strong, nonatomic) NSString *name;
@end
