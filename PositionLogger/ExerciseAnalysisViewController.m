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
    BOOL _isRecording;
    ReadingsAnalyzer* _readingsAnalyzer;
}


- (void) viewDidLoad {
    [super viewDidLoad];
    _readingsAnalyzer = [[ReadingsAnalyzer alloc] init];
    
    self.startExerciseButton.layer.borderWidth = 1.0;
    self.startExerciseButton.layer.cornerRadius = 5.0;
    
    self.endExerciseButton.layer.borderWidth = 1.0;
    self.endExerciseButton.layer.cornerRadius = 5.0;
    
    _isRecording = FALSE;
    [self.endExerciseButton setEnabled: NO];

    //[self changeLabelStatus: FALSE];
}


//hide or show labels and counts on the UI
- (void) changeLabelStatus : (bool) newStatus {
    self.completedLabel.hidden = newStatus;
    self.repetitionLabel.hidden = newStatus;
    self.repetitionCount.hidden = newStatus;
    self.recognizedActivity.hidden = newStatus;
}

- (IBAction)startExercise:(id)sender {
    if (!_isRecording) {
        //Signal to Arduinos to start recording
        [[SensorModel instance] sendSignal:@"Y"];
        [self.startExerciseButton setEnabled:NO];
        [self.endExerciseButton setEnabled:YES];
        _isRecording = TRUE;
    }
}

- (IBAction)endExercise:(id)sender {
    if (_isRecording) {
        // Tell arduino to stop recording
        [[SensorModel instance] sendSignal:@"N"];
        
        //save collected sensor readings

        NSArray* _leftSensorReadings = [[SensorModel instance] tmpLeftSensorReadings];
        NSArray* _rightSensorReadings = [[SensorModel instance] tmpRightSensorReadings];
        [self.endExerciseButton setEnabled:NO];
        [self.startExerciseButton setEnabled:YES];
        _isRecording = FALSE;
        
        // Count completed repetitions
        int completedReps = [[ReadingsAnalyzer instance] countRepetitionsFromLeft: _leftSensorReadings  andRight:_rightSensorReadings];
        
        //Reset array of readings to await next exercise
        [[[SensorModel instance] tmpLeftSensorReadings] removeAllObjects];
        [[[SensorModel instance] tmpRightSensorReadings] removeAllObjects];


        self.repetitionCount.text = [NSString stringWithFormat:@"%d", completedReps];
        
        
        //Perform activity recognition
        
    }
}

@end
