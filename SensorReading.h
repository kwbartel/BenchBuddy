//
//  SensorReading.h
//  WorkoutLogger
//
//  Created by Katie Bartel on 4/16/16.
//  Copyright © 2016 Sam Madden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SensorReading : NSObject

@property(readonly) NSArray* accelReadings;
@property(readonly) NSArray* gyroReadings;
@property(readonly) NSDate *time;
@property(readonly) NSString *sensorId;

-(id)initWithReadingsAccel:(NSArray*)accelReadings andGyro:(NSArray*)gyroReadings atTime:(NSDate *)time andSensorId:(NSString *)sensorId;
-(NSString *)formattedValue;

@end
