//
//  ProbeProperties.h
//  BlueThermIOS-SDK
//
//  Copyright (c) 2012 ETILtd.co.uk All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAController.h"

@interface ProbeProperties : NSObject

#pragma mark - probe readings and properties

//BlueTherm Probe and BlueTherm Duo
+(BOOL)isBlueThermConnected;

//These are the methods for getting the readings from the probe
+(NSString*) batteryLevel;
+(NSString*) batteryTemperature;
+(NSString*) batteryVolts;
+(NSString*) calibration;
+(NSString*) firmware;
+(BOOL)      duoInput2Enabled; //sensor 2 enabled on a duo probe
+(BOOL)      isBlueThermDuo; //duo or single probe connected
+(NSString*) serialNumber;

//sensor 1 readings
+(NSString*) sensor1HighLimit;
+(NSString*) sensor1LowLimit;
+(NSString*) sensor1Name;
+(NSString*) sensor1Reading;
+(NSString*) sensor1Trim;
+(NSString*) sensor1TrimDate;
+(NSString*) sensor1Type;
+(NSString*) sensor1Units;

//sensor 2 readings
+(NSString*) sensor2HighLimit;
+(NSString*) sensor2LowLimit;
+(NSString*) sensor2Name;
+(NSString*) sensor2Reading;
+(NSString*) sensor2Trim;
+(NSString*) sensor2TrimDate;
+(NSString*) sensor2Type;
+(NSString*) sensor2Units;

+(NSString*) getEmissivityValue; //this should only be called once the HomeViewController has received  the callback 'displayEmissivity'

+(BOOL)blueThermDuoDegreesC; //returns the correct degrees from a Duo BlueTherm
+(BOOL)blueThermProbeDegreesC; //returns the correct degrees from a BlueTherm Probe


//BlueTherm Probe
+(BOOL) degreesCorDegreesFSingleProbeSetting;//Changes the BlueTherm Probe to read in degrees C or Degrees F.
//By default the probe will read in degrees C when first started.



@end
