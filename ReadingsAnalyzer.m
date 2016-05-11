//
//  ReadingsAnalyzer.m
//  WorkoutLogger
//
//  Created by Kwame Efah  on 5/6/16.
//  Copyright © 2016 Sam Madden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReadingsAnalyzer.h"
#import "SensorReading.h"

@import Accelerate;

static id _instance;
@implementation ReadingsAnalyzer {
    NSArray* _thresholds;
    NSArray* _activities;
}

-(id) init {
    self = [super init];
    if (self) {
        _thresholds = @[[NSNumber numberWithFloat:-8282.1934],[NSNumber numberWithFloat:-4112.0137],[NSNumber numberWithFloat:4949.7021], [NSNumber numberWithFloat:7626.5186]];
        
        _activities= @[@"Squats", @"Bench Press", @"Rows", @"Curls", @"Tricep Extensions"];
    }
    return self;
}

/*
    Interprets sensor readings from two peripherals to determine what exercise the current user just performed.
    @param {leftSensorReadings} readings from the left peripheral
    @param {rightSensorReadings} readings from the right peripheral
*/
- (NSString*) recognizeActivityFromLeft: (NSArray *) leftSensorReadings andRight: (NSArray *) rightSensorReadings {
    NSArray* leftFeatures = [self extractFeatures:leftSensorReadings];
    NSArray* rightFeatures = [self extractFeatures:rightSensorReadings];
    
    NSInteger activityCode;
    
    // Decision Tree Evaluation
    if ([rightFeatures[1] floatValue] <= [_thresholds[0] floatValue]) {
        activityCode = 2;
    } else if ([rightFeatures[2] floatValue] <= [_thresholds[1] floatValue]) {
        activityCode = 3;
    } else if ([rightFeatures[2] floatValue] > [_thresholds[2] floatValue]) {
        activityCode = 0;
    } else if ([rightFeatures[0] floatValue] <= [_thresholds[3] floatValue]) {
        activityCode = 1;
    } else {
        activityCode = 4;
    }
    return _activities[activityCode];
}

/*
    Extracts features relevant for machine learning for a single peripheral's inertial sensing measurements
    @param {sensorReadings} readings from a single peripheral
*/
- (NSArray*) extractFeatures: (NSArray *) sensorReadings {
    NSArray* rawValues = [self convertReadingsToRaw: sensorReadings];
    NSArray* rawXValues = rawValues[0];
    NSArray* rawYValues = rawValues[1];
    NSArray* rawZValues = rawValues[2];
    

    NSNumber* meanX = [rawXValues valueForKeyPath:@"@avg.floatValue"];
    NSNumber* meanY = [rawYValues valueForKeyPath:@"@avg.floatValue"];
    NSNumber* meanZ = [rawZValues valueForKeyPath:@"@avg.floatValue"];

    NSArray *features = @[meanX, meanY, meanZ];

    return features;
}

/*
    Counts the number of repetitions completed in a particular exercise
    @param{leftSensorReadings} inertial sensing measurements from the left wrist peripheral 
    @param{rightSensorredings} inertial sensing measurements from the right wrist peripheral
*/
-(int) countRepetitionsFromLeft:(NSArray *)leftSensorReadings andRight:(NSArray *)rightSensorReadings {
    int leftRepetitionCount = [self countRepetitionsSingle: leftSensorReadings];
    int rightRepetitionCount = [self countRepetitionsSingle: rightSensorReadings];
    int avgRepCount = (leftRepetitionCount + rightRepetitionCount) / 2;
    return avgRepCount;
}

/*
    From a set of sensorReadings, extract the raw accelerometer data from a particular dimension
    @param {sensorReadings} readings to extract raw data from
*/
-(NSArray*) convertReadingsToRaw: (NSArray*) sensorReadings {
    unsigned long count = [sensorReadings count];

    NSMutableArray* rawXValues = [[NSMutableArray alloc] initWithCapacity:count];
    NSMutableArray* rawYValues = [[NSMutableArray alloc] initWithCapacity:count];
    NSMutableArray* rawZValues = [[NSMutableArray alloc] initWithCapacity:count];

    for (int i = 0; i < count; i++) {
        NSArray* accelValues = [sensorReadings[i] accelReadings];
        rawXValues[i] = accelValues[0];
        rawYValues[i] = accelValues[1];
        rawZValues[i] = accelValues[2];
    }

    NSArray* rawValues = [[NSArray alloc] initWithObjects:rawXValues,rawYValues,rawZValues,nil];
    return rawValues;
}
/*
    Counts the number of repetitions from a set of sensor readings from a single peripheral
    @param{sensorReadings} inertial sensing measurements from a single peripheral
*/
- (int) countRepetitionsSingle: (NSArray *) sensorReadings {
    unsigned long readingsCount = [sensorReadings count];
    
    NSArray* rawValues = [self convertReadingsToRaw: sensorReadings];
    NSMutableArray* rawXValues = rawValues[0];
    NSMutableArray* rawYValues = rawValues[1];
    NSMutableArray* rawZValues = rawValues[2];
    
    //memory read -t float -c34 rawValues

    NSNumber* meanX = [rawXValues valueForKeyPath:@"@avg.floatValue"];
    NSNumber* meanY = [rawYValues valueForKeyPath:@"@avg.floatValue"];
    NSNumber* meanZ = [rawZValues valueForKeyPath:@"@avg.floatValue"];

    for (int j = 0; j < readingsCount; j++) {
        rawXValues[j] = [NSNumber numberWithFloat:([rawXValues[j] floatValue] - [meanX floatValue])];
        rawYValues[j] = [NSNumber numberWithFloat:([rawYValues[j] floatValue] - [meanY floatValue])];
        rawZValues[j] = [NSNumber numberWithFloat:([rawZValues[j] floatValue] - [meanZ floatValue])];
    }
    
    //Low pass filter raw acceleration values
    NSArray* filteredXValues = [self filterAccelerationData:rawXValues length:readingsCount];
    NSArray* filteredYValues = [self filterAccelerationData:rawYValues length:readingsCount];
    NSArray* filteredZValues = [self filterAccelerationData:rawZValues length:readingsCount];
    
    //Calculate zero crossings for the three dimensions
    float filterThreshold = 4000;
    int zeroXCrossings = [self countZeroCrossings:filteredXValues length:readingsCount threshold: filterThreshold];
    int zeroYCrossings = [self countZeroCrossings:filteredYValues length:readingsCount threshold: filterThreshold];
    int zeroZCrossings = [self countZeroCrossings:filteredZValues length:readingsCount threshold: filterThreshold];

    int bestXY = MAX(zeroXCrossings, zeroYCrossings);
    int bestZeroCrossingCount = MAX(bestXY, zeroZCrossings);
    
    // Free memory
    return bestZeroCrossingCount / 2;
}
/*
    Low pass filter a set of sensor readings
    @param{rawValues} unfiltered accelerometer readings
*/
- (NSArray*) filterAccelerationData: (NSArray*)rawValues length: (unsigned long) count {
    
    NSMutableArray* filteredValues = [[NSMutableArray alloc] initWithCapacity: count];
    
    float inputSignal[count];
    float outputSignal[count];
    float delays[4] = {0.f, 0.f, 0.f, 0.f};
    for (int i = 0; i < count; i++) {
        inputSignal[i] = [rawValues[i] floatValue];
    }

    //10hz
    //const double filterCoefficients[5] = {0.5049992667097521, 1.0099985334195043,  0.5049992667097521, 0.7477865686482109, 0.27221049819079773};
    //15hz
    const double filterCoefficients[5] = {0.26287298871696146, 0.5257459774339229, 0.26287298871696146, -0.12274073900965186, 0.1742326938774977};
    
    //BiQuadratic Infinite Impulse Response Filter
    vDSP_biquad_Setup filterSetup = vDSP_biquad_CreateSetup (filterCoefficients, 1);
    vDSP_biquad ( filterSetup, delays, inputSignal, 1, outputSignal, 1, count);
    vDSP_biquad_DestroySetup(filterSetup);
    
    for (int i = 0; i < count; i++) {
        [filteredValues addObject: [NSNumber numberWithFloat:outputSignal[i]]];
    }
    return filteredValues;
}

/*
    Given a filtered signal, determines its periodicity by counting the number of times zero was crossed
    to within a given threshold
    @param {signal} filtered input signal
    @param {threshold} magnitude of sign flip required to constitute a zero crossing
*/
- (int) countZeroCrossings: (NSArray*) signal length: (unsigned long) count threshold: (float) threshold {
    NSNumber* lastValue = signal[0];
    NSNumber* currentValue;
    int numZeroCrossings = 0;
    bool smallDelta = FALSE;
    for (int i = 1; i < count; i++) {
        currentValue = signal[i];
        smallDelta = FALSE;
        
        //check if we crossed zero to a significant degree and increment
        if (([currentValue floatValue] > 0 && [lastValue floatValue] < 0) || ([currentValue floatValue] < 0 && [lastValue floatValue] > 0)) {
            if (ABS([currentValue floatValue] - [lastValue floatValue]) > threshold) {
                numZeroCrossings++;
            }
            else {
                smallDelta = TRUE;
            }
        }
        if (!smallDelta) {
            lastValue = currentValue;
        }
    }
    return numZeroCrossings;
}

+(ReadingsAnalyzer *) instance {
    if (!_instance) {
        _instance = [[ReadingsAnalyzer alloc] init];
    }
    return _instance;
}
@end