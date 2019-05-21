//
//  ThermaLib.h
//  ThermaLib
//
//  Created by Chris Leversuch on 19/09/2016.
//  Copyright © 2016 Brightec. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TLDevice;

/// Notification sent when a new device is found during a scan
FOUNDATION_EXPORT NSString *const ThermaLibNewDeviceFoundNotificationName;

/// Notification sent when a notification is received from a device
FOUNDATION_EXPORT NSString *const ThermaLibNotificationReceivedNotificationName;

/**
 * User info dictionary key for the TLDeviceNotificationType
 *
 * @see ThermaLibNotificationReceivedNotificationName
 */
FOUNDATION_EXPORT NSString *const ThermaLibNotificationReceivedNotificationTypeKey;

/**
 * Notification sent when a battery level notification is received from a device
 *
 * The new level can be read from the device or the notification
 */
FOUNDATION_EXPORT NSString *const ThermaLibBatteryLevelNotificationName;

/**
 * Notification sent when a device has been updated
 *
 * This may be the result of a read request or a write request
 */
FOUNDATION_EXPORT NSString *const ThermaLibDeviceUpdatedNotificationName;

/**
 * Notification sent when the RSSI value has update
 *
 * The new level can be read from the device or the notification
 *
 * @see ThermaLibRSSINotificationKey
 */
FOUNDATION_EXPORT NSString *const ThermaLibRSSINotificationName;

/**
 * User info dictionary key for the new RSSI value
 *
 * @see ThermaLibRSSINotificationName
 */
FOUNDATION_EXPORT NSString *const ThermaLibRSSINotificationKey;

/// Notification sent when an updated sensor reading is received.
FOUNDATION_EXPORT NSString *const ThermaLibSensorUpdatedNotificationName;


/// The connection method for the device
typedef NS_ENUM(NSInteger, TLTransport) {
    /// Bluetooth connection
    TLTransportBluetoothLE,
    /// WiFi connection
    TLTransportWifi,
    /// Simulated device
    TLTransportSimulated
};


/// The type of device
typedef NS_ENUM(NSInteger, TLDeviceType) {
    /// Type unknown
    TLDeviceTypeUnknown,
    /// BlueTherm LE Probe
    TLDeviceTypeLEProbe,
    /// ThermaQ Blue
    TLDeviceTypeQBlue,
    /// BlueTherm LE Duo
    TLDeviceTypeLEDuo,
    /// BlueTherm Classic Probe
    TLDeviceTypeClassicProbe,
    /// BlueTherm Classic Duo
    TLDeviceTypeClassidDuo,
    /// BlueTherm WiFi
    TLDeviceTypeWiFi
};


/**
 * @brief The `ThermaLib` class is the main access point for the library
 *
 * See ThermaLib.h for details about the constants and enums used by this class
 */
@interface ThermaLib : NSObject
/// Singleton accessor
+ (instancetype)sharedInstance;

/// Checks the current state of Bluetooth
- (BOOL)isBluetoothAvailable;

/// Starts a scan for ThermaQ devices
- (void)startDeviceScan;

/// Stops an existing scan
- (void)stopDeviceScan;

/**
 * Gets the list of discovered devices
 */
- (NSArray<id<TLDevice>> *)deviceList;

/**
 * Gets the device for the given identifier
 *
 * @param identifier The identifier to search for
 */
- (id<TLDevice>)deviceWithIdentifier:(NSString *)identifier;

/**
 * Requests that a connection be established with the device
 *
 * @param device The device to connect to
 */
- (void)connectToDevice:(id<TLDevice>)device;

/**
 * Requests that the connection with the device be ended
 *
 * @param device The device to disconnect from
 */
- (void)disconectFromDevice:(id<TLDevice>)device;

/// Returns a list of devices with active connections
- (NSArray<id<TLDevice>> *)connectedDevices;

/**
 * Removes a device from the list of discovered devices
 *
 * The device will be re-added if it is discovered again
 *
 * @param device The device to remove
 */
- (void)removeDevice:(id<TLDevice>)device;
@end
