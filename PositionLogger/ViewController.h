//
//  ViewController.h
//  PositionLogger
//
//  Created by Sam Madden on 2/3/16.
//  Copyright © 2016 Sam Madden. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "SensorModel.h"
#import "SensorReading.h"

@interface ViewController : UIViewController<MFMailComposeViewControllerDelegate, SensorModelDelegate>

@property IBOutlet UIButton *startStopButton;
@property IBOutlet UIActivityIndicatorView *recordingIndicator;
@property (weak, nonatomic) IBOutlet UIButton *endWorkoutButton;
@property (weak, nonatomic) IBOutlet UITextField *exerciseName;
@property (weak, nonatomic) IBOutlet UISwitch *includeExercise;


-(IBAction)endWorkoutButton:(UIButton *)sender;
-(IBAction)hitRecordStopButton:(UIButton *)b;
-(IBAction)hitClearButton:(UIButton *)b;
-(IBAction)emailLogFile:(UIButton *)b;


@end

