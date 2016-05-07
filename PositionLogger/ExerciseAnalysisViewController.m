//
//  ExerciseAnalysisViewController.m
//  WorkoutLogger
//
//  Created by Kwame Efah  on 5/6/16.
//  Copyright © 2016 Sam Madden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExerciseAnalysisViewController.h"
#import "ReadingsAnalyzer.h"

@implementation ExerciseAnalysisViewController {
    NSArray* _leftSensorReadings;
    NSArray* _rightSensorReadings;
    BOOL _isRecording;
}


- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.startExerciseButton.layer.borderWidth = 1.0;
    self.startExerciseButton.layer.cornerRadius = 5.0;
    
    self.endExerciseButton.layer.borderWidth = 1.0;
    self.endExerciseButton.layer.cornerRadius = 5.0;
    
    _isRecording = FALSE;
    [self.endExerciseButton setEnabled: NO];
}

- (IBAction)startExercise:(id)sender {
    if (!_isRecording) {
        //Signal to Arduinos to start recording
        [[SensorModel instance] sendSignal:@"Y"];
        [self.startExerciseButton setEnabled: NO];
        _isRecording = TRUE;
    }
}

- (IBAction)endExercise:(id)sender {
    if (_isRecording) {
        // Tell arduino to stop recording
        [[SensorModel instance] sendSignal:@"N"];
        
        //save collected sensor readings
        _leftSensorReadings = [[SensorModel instance] tmpLeftSensorReadings];
        _rightSensorReadings = [[SensorModel instance] tmpRightSensorReadings];
        [self.endExerciseButton setEnabled:NO];
        _isRecording = FALSE;
        
        // Count reps completed
        NSInteger completedReps = [[ReadingsAnalyzer instance] countRepetitionsFromLeft: _leftSensorReadings  andRight:_rightSensorReadings];
        
        //Perform activity recognition
        
    }
}

@end
