//
//  TLSensor.h
//  ThermaLib
//
//  Created by Chris Leversuch on 22/09/2016.
//  Copyright © 2016 Brightec. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TLDevice;
@class TLDateStamp;


/// Possible sensor types
typedef NS_ENUM(NSInteger, TLSensorType) {
    /// Unknown
    TLSensorTypeUnknown,
    /// Internal Thermistor
    TLSensorTypeInternalThermistor,
    /// External Thermistor
    TLSensorTypeExternalThermistor,
    /// Infrared Sensor
    TLSensorTypeIRSensor,
    /// K Thermocouple
    TLSensorTypeKThermocouple,
    /// T Thermocouple
    TLSensorTypeTThermocouple,
    /// PT1000
    TLSensorTypePT1000,
    /// pH Sensor
    TLSensorTypePHSensor,
    /// Humidity Temperature
    TLSensorTypeHumidityTemperature,
    /// Humidity
    TLSensorTypeHumidity,
    /// Moisture Sensor
    TLSensorTypeMoistureSensor
};


/// The `TLSensor` protocol encapsulates a sensor independently of the underlying connection type of the device e.g. Bluetooth
@protocol TLSensor <NSObject>

/// The device that the sensor is part of
@property (weak, nonatomic, readonly) id<TLDevice> device;

/// The current trim value set on the sensor
@property (assign, nonatomic) float trimValue;

/// The date that the trim value was set
@property (strong, nonatomic, readonly) TLDateStamp *trimSetDate;

/// The current temperature reading
@property (assign, nonatomic, readonly) float reading;

/// The temperature at which the high alarm should trigger
@property (assign, nonatomic) float highAlarm;

/// Whether the high alarm is on/off
@property (assign, nonatomic) BOOL highAlarmEnabled;

/// The temperature at which the low alarm should trigger
@property (assign, nonatomic) float lowAlarm;

/// Whether the low alarm is on/off
@property (assign, nonatomic) BOOL lowAlarmEnabled;

/// The type of sensor
@property (assign, nonatomic, readonly) TLSensorType type;

/// The sensor's index (1-based)
@property (assign, nonatomic, readonly) NSUInteger index;

/// Whether the sensor is enabled or not (Note: not all sensors can be disabled)
@property (assign, nonatomic, getter=isEnabled) BOOL enabled;

/// Whether the sensor currently has a fault
@property (assign, nonatomic, readonly, getter=isFault) BOOL fault;

/// The sensor's name
@property (strong, nonatomic) NSString *name;
@end
