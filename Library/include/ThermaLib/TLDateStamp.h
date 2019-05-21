//
//  TLDateStamp.h
//  ThermaLib
//
//  Created by Chris Leversuch on 01/10/2016.
//  Copyright © 2016 Brightec. All rights reserved.
//

#import <Foundation/Foundation.h>


/// Represents a date as 3 seperate integers
@interface TLDateStamp : NSObject
/// 2 digit year. Post-2000
@property (assign, nonatomic) NSUInteger year;
/// Month
@property (assign, nonatomic) NSUInteger month;
/// Day
@property (assign, nonatomic) NSUInteger day;

/**
 * Custom initialiser
 *
 * @param year Year
 * @param month Month
 * @param day Day
 */
- (instancetype)initWithYear:(NSUInteger)year month:(NSUInteger)month day:(NSUInteger)day;

/// Creates an object initialised to today's date
+ (instancetype)today;

/// Resets the properties
- (void)clear;
@end
