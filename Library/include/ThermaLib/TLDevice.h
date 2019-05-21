//
//  TLDevice.h
//  ThermaLib
//
//  Created by Chris Leversuch on 22/09/2016.
//  Copyright © 2016 Brightec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThermaLib.h"

@protocol TLSensor;
@class TLDateStamp;


/// Possible connection states
typedef NS_ENUM(NSInteger, TLDeviceConnectionState) {
    /// Unknown
    TLDeviceConnectionStateUnknown,
    /// Available
    TLDeviceConnectionStateAvailable,
    /// Connecting
    TLDeviceConnectionStateConnecting,
    /// Connected
    TLDeviceConnectionStateConnected,
    /// Disconnecting
    TLDeviceConnectionStateDisconnecting,
    /// Disconnected
    TLDeviceConnectionStateDisconnected,
    /// Unavailable
    TLDeviceConnectionStateUnavailable,
    /// Unsupported
    TLDeviceConnectionStateUnsupported
};


/// Temperature display unit
typedef NS_ENUM(NSInteger, TLDeviceUnit) {
    /// Celsius
    TLDeviceUnitCelsius,
    /// Fahrenheit
    TLDeviceUnitFahrenheit
};


/// Possible device commands
typedef NS_ENUM(NSInteger, TLDeviceCommandType) {
    /// Requests the device takes a measurement immediately
    TLDeviceCommandTypeMeasure,
    /// Requests the device identifies itself, e.g. by flashing an LED
    TLDeviceCommandTypeIdentify,
    /// Requests the device returns to factory settings, excluding trim values
    TLDeviceCommandTypeFactorySettings,
    /// Requests the device returns to factory settings, including trim values
    TLDeviceCommandTypeFactoryReset
};


/// Possible notifications
typedef NS_ENUM(NSInteger, TLDeviceNotificationType) {
    /// None
    TLDeviceNotificationTypeNone,
    /// Button pressed on the device
    TLDeviceNotificationTypeButtonPressed,
    /// Device is about to shutdown
    TLDeviceNotificationTypeShutdown,
    /// Device received an invalid setting
    TLDeviceNotificationTypeInvalidSetting,
    /// Device received an invalid command
    TLDeviceNotificationTypeInvalidCommand,
    /// Communication error detected
    TLDeviceNotificationTypeCommunicationError
};


/// The `TLDevice` protocol encapsulates a device independently of the underlying connection type e.g. Bluetooth
@protocol TLDevice <NSObject>

/// The manufacturer name of the device
@property (strong, nonatomic, readonly) NSString *manufacturerName;

/// The serial number of the device
@property (strong, nonatomic, readonly) NSString *serialNumber;

/// The model number of the device
@property (strong, nonatomic, readonly) NSString *modelNumber;

/// The protocol version of the device
@property (strong, nonatomic, readonly) NSString *protocolVersion;

/// The hardware version of the device
@property (strong, nonatomic, readonly) NSString *hardwareVersion;

/// The software revision of the device
@property (strong, nonatomic, readonly) NSString *softwareRevision;

/// The firmware revision of the device
@property (strong, nonatomic, readonly) NSString *firmwareRevision;

/// The transport type of the device e.g. Bluetooth
@property (assign, nonatomic, readonly) TLTransport transportType;

/// The device name
@property (strong, nonatomic, readonly) NSString *deviceName;

/// The device type
@property (assign, nonatomic, readonly) TLDeviceType deviceType;

/**
 * The device identifier
 *
 * For Bluetooth devices, this is a UUID assigned by iOS at discovery time.
 * Only use this identifier if you are sure it meets your requirements in terms of scope and stability.
 * (See https://developer.apple.com/reference/corebluetooth/cbperipheral/1518935-identifier). For a globally unique and stable identifier, use the serialNumber property.
 * This identifier is not currently defined for non-Bluetooth devices.
 */
@property (strong, nonatomic, readonly) NSString *deviceIdentifier;

/// The sensors included in the device
@property (strong, nonatomic, readonly) NSArray<id<TLSensor>> *sensors;

/// The temperature unit the device is using
@property (assign, nonatomic) TLDeviceUnit unit;

/// The frequency of measurements reported by the device (in seconds)
@property (assign, nonatomic) NSInteger measurementInterval;

/// The time internal for switching the device off (in minutes)
@property (assign, nonatomic) NSInteger autoOffInterval;

/// The last RSSI reported by the device
@property (strong, nonatomic, readonly) NSNumber *rssi;

/// The current battery level of the device
@property (assign, nonatomic, readonly) NSInteger batteryLevel;

/// The connection state of the device
@property (assign, nonatomic, readonly) TLDeviceConnectionState connectionState;

/// Whether the device is ready i.e. all settings have been read and processed
@property (assign, nonatomic, readonly, getter=isReady) BOOL ready;

/// Whether the user has requested that the device be disconnected, to contrast with unexpected disconnections
@property (assign, nonatomic, readonly) BOOL userRequestedDisconnect;

/// Returns whether the device is connected
- (BOOL)isConnected;

/// Number of sensors the device physically has
- (NSInteger)maxSensorCount;

/**
 * Returns the sensor at the given index
 *
 * @param index The index of the sensor (1-based)
 */
- (id<TLSensor>)sensorAtIndex:(NSUInteger)index;

/**
 * Returns whether the requested sensor is enabled
 *
 * @param index The index of the sensor (1-based)
 */
- (BOOL)isSensorEnabledAtIndex:(NSUInteger)index;

/// Requests that the RSSI value be read from the device
- (void)updateRssi;

/**
 * Sends a command to the device
 *
 * @param command The command to send
 */
- (void)sendCommand:(TLDeviceCommandType)command;

/// Requests all values to be read from the device
- (void)refresh;
@end
