//
//  SensorReading.m
//  WorkoutLogger
//
//  Created by Katie Bartel on 4/16/16.
//  Copyright © 2016 Sam Madden. All rights reserved.
//

#import "SensorReading.h"
#import <UIKit/UIKit.h>

@implementation SensorReading

-(id)initWithReadingsAccel:(NSArray*)accelReadings andGyro:(NSArray*)gyroReadings atTime:(NSDate *)time andSensorId:(NSString *)sensorId {
    self = [super init];
    if (self) {
        _accelReadings = accelReadings;
        _gyroReadings = gyroReadings;
        _time = time;
        _sensorId = sensorId;
    }
    return self;
}

-(NSString *)formattedValue {
    NSString *accelString = [_accelReadings componentsJoinedByString:@", "];
    NSString* gyroString = [_gyroReadings componentsJoinedByString:@", "];
    NSString* label = [NSString stringWithFormat:@"%@,%@,%@,%@", _time, _sensorId, accelString, gyroString];
    return label;
}

@end
