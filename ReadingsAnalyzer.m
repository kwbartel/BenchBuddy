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
}

-(id) init {
    self = [super init];
    if (self) {
        //TODO: Initialize instance variables
    }
    return self;
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
    Counts the number of repetitions from a set of sensor readings from a single peripheral
    @param{sensorReadings} inertial sensing measurements from a single peripheral
*/
- (int) countRepetitionsSingle: (NSArray *) sensorReadings {
    unsigned long readingsCount = [sensorReadings count];
    
    //Allocate raw value arrays
    float* rawXValues = (float *) malloc (readingsCount * sizeof(float));
    float* rawYValues = (float *) malloc (readingsCount * sizeof(float));
    float* rawZValues = (float *) malloc (readingsCount * sizeof(float));
    
    for (int i = 0; i < readingsCount; i++) {
        NSArray* accelValues = [sensorReadings[i] accelReadings];
        rawXValues[i] = [accelValues[0] floatValue];
        rawYValues[i] = [accelValues[1] floatValue];
        rawZValues[i] = [accelValues[2] floatValue];
    }
    
    //memory read -t float -c34 rawValues
    float meanX;
    float meanY;
    float meanZ;
    vDSP_meanv(rawXValues, 1, &meanX, readingsCount);
    vDSP_meanv(rawYValues, 1, &meanY, readingsCount);
    vDSP_meanv(rawZValues, 1, &meanZ, readingsCount);
    
    for (int j = 0; j < readingsCount; j++) {
        rawXValues[j] -= meanX;
        rawYValues[j] -= meanY;
        rawZValues[j] -= meanZ;
    }
    
    
    //Low pass filter raw acceleration values
    float* filteredXValues = [self filterAccelerationData:rawXValues length:readingsCount];
    float* filteredYValues = [self filterAccelerationData:rawYValues length:readingsCount];
    float* filteredZValues = [self filterAccelerationData:rawZValues length:readingsCount];
    
    //Calculate zero crossings for the three dimensions
    float filterThreshold = 3000;
    int zeroXCrossings = [self countZeroCrossings:filteredXValues length:readingsCount threshold: filterThreshold];
    int zeroYCrossings = [self countZeroCrossings:filteredYValues length:readingsCount threshold: filterThreshold];
    int zeroZCrossings = [self countZeroCrossings:filteredZValues length:readingsCount threshold: filterThreshold];
    
    int bestXY = MAX(zeroXCrossings, zeroYCrossings);
    int bestZeroCrossingCount = MAX(bestXY, zeroZCrossings);
    
    
    // Free memory
    free(rawXValues); free(rawYValues); free(rawZValues);
    free(filteredXValues); free(filteredYValues); free(filteredZValues);
    return bestZeroCrossingCount / 2;

    
}
/*
    Low pass filter a set of sensor readings
    @param{rawValues} unfiltered accelerometer readings
*/
- (float*) filterAccelerationData: (float*)rawValues length: (unsigned long) count {
    
    //Implement low pass filter
    double rate = 6; //Sampling Arduino at approximately 10 HZ
    double freq = 0.8; // Empirically determined cutoff frequency ~ 1.0
    double dt = 1.0 / rate;
    double RC = 1.0 / freq;
    double filterConstant = dt / (dt + RC);
    
    float* filteredValues = (float *) malloc (count * sizeof(float));
    filteredValues[0] = rawValues[0] * filterConstant;
    for (int i = 1; i < count; i++) {
        float filteredValue = rawValues[i] * filterConstant + rawValues[i-1] * (1.0 - filterConstant);
        filteredValues[i] = filteredValue;
    }
    return filteredValues;
}

/*
    Given a filtered signal, determines its periodicity by counting the number of times zero was crossed
    to within a given threshold
    @param {signal} filtered input signal
    @param {threshold} magnitude of sign flip required to constitute a zero crossing
*/
- (int) countZeroCrossings: (float*) signal length: (unsigned long) count threshold: (float) threshold {
    float lastValue = signal[0];
    float currentValue;
    int numZeroCrossings = 0;
    bool smallDelta = FALSE;
    for (int i = 1; i < count; i++) {
        currentValue = signal[i];
        smallDelta = FALSE;
        
        //check if we crossed zero to a significant degree and increment
        if ((currentValue > 0 && lastValue < 0) || (currentValue < 0 && lastValue > 0)) {
            if (ABS(currentValue - lastValue) > threshold) {
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