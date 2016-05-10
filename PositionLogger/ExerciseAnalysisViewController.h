//
//  ExerciseAnalysisViewController.h
//  WorkoutLogger
//
//  Created by Kwame Efah  on 5/6/16.
//  Copyright © 2016 Sam Madden. All rights reserved.
//

//#ifndef ExerciseAnalysisViewController_h
//#define ExerciseAnalysisViewController_h

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "SensorModel.h"

@interface ExerciseAnalysisViewController: UIViewController

@property (weak, nonatomic) IBOutlet UIButton *startExerciseButton;
@property (weak, nonatomic) IBOutlet UIButton *endExerciseButton;
@property (weak, nonatomic) IBOutlet UILabel *completedLabel;
@property (weak, nonatomic) IBOutlet UITextField *repetitionCount;
@property (weak, nonatomic) IBOutlet UILabel *repetitionLabel;
@property (weak, nonatomic) IBOutlet UITextField *recognizedActivity;

- (IBAction)startExercise:(id)sender;
- (IBAction)endExercise:(id)sender;

@end



//#endif /* ExerciseAnalysisViewController_h */

