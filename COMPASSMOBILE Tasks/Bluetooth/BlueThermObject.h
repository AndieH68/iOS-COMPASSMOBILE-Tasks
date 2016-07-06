//
//  BlueThermObject.h
//  BlueThermIOS-SDK
//
//  Copyright (c) 2012 ETILtd.co.uk All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BlueThermObject : NSObject

+ (BOOL) isValid:(NSData *)data;
+ (void) ComputeChecksumBytes:(uint8_t *) bytes secondParam:(UInt32) numberOfBytesToCheckSum byteone:(UInt8 *) b1 bytetwo:(UInt8 *) b2;

@end