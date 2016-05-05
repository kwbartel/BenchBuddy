//
//  ViewController.m
//  PositionLogger
//
//  Created by Sam Madden on 2/3/16.
//  Copyright © 2016 Sam Madden. All rights reserved.
//

#import "ViewController.h"

#define kDATA_FILE_NAME @"log.csv"
#define kDATES_FILE_NAME @"exerciseEndTimes.json"

@interface ViewController ()
@end

@implementation ViewController {
    BOOL _isRecording;
    NSFileHandle *_f;
    UIAlertController *_alert;
    NSMutableDictionary *_exerciseEndDateMap;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [SensorModel instance].delegate = self;
    
    // UI setup
    self.recordingIndicator.hidesWhenStopped = TRUE;
    self.startStopButton.layer.borderWidth = 1.0;
    self.startStopButton.layer.cornerRadius = 5.0;
    [self.startStopButton setEnabled: NO];
    
    self.endWorkoutButton.layer.borderWidth = 1.0;
    self.endWorkoutButton.layer.cornerRadius = 5.0;
    [self.endWorkoutButton setEnabled: NO];
    
    //Open CSV file
    _f  = [self openFileForWriting];
    
    //Initialize exercise to end time map
    _exerciseEndDateMap  = [[NSMutableDictionary alloc] init];
    
    if (!_f)
        NSAssert(_f,@"Couldn't open file for writing.");
    [self logLineToDataFile:@"LTime, LSensorID, LAccelX, LAccelY, LAccelZ, LGyroX, LGyroY, LGyroZ,"];
    [self logLineToDataFile:@"RTime, RSensorID, RAccelX, RAccelY, RAccelZ, RGyroX, RGyroY, RGyroZ, \n"];
    // Do any additional setup after loading the view, typically from a nib.
}

// Delegate methods
- (void) peripheralsReadyForDataCollection {
    [self.startStopButton setEnabled: YES];
}

/* If one or both peripherals disconnect
        => Tell all peripherals to stop collecting data
        => Clear all sensor readings that were taken for the current exercise
        => Reset UI
*/
- (void) peripheralsForceDisconnected {
    [self.startStopButton setTitle:@"Start" forState:UIControlStateNormal];
    _isRecording = FALSE;
    [self.recordingIndicator stopAnimating];
    [[SensorModel instance] sendSignal: @"N"];
    [self.endWorkoutButton setEnabled:YES];
    
    [[[SensorModel instance] tmpLeftSensorReadings] removeAllObjects];
    [[[SensorModel instance] tmpRightSensorReadings] removeAllObjects];
    
    self.exerciseName.text = @"";
    
    [self.startStopButton setEnabled: NO];
}

-(NSString *)getPathToLogFile {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:kDATA_FILE_NAME];
    return filePath;
}

-(NSFileHandle *)openFileForWriting {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSFileHandle *f;
    [fileManager createFileAtPath:[self getPathToLogFile] contents:nil attributes:nil];
    f = [NSFileHandle fileHandleForWritingAtPath:[self getPathToLogFile]];
    return f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)logLineToDataFile:(NSString *)line {
    [_f writeData:[line dataUsingEncoding:NSUTF8StringEncoding]];
}

-(void)resetLogFile {
    [_f closeFile];
    _f = [self openFileForWriting];
    if (!_f)
        NSAssert(_f,@"Couldn't open file for writing.");
    
}

// Send message to peripheral to stop taking sensor readings
-(void)saveReadingsToCSV {
    //NSArray* readings = [[SensorModel instance] sensorReadings];
    NSArray* leftReadings = [[SensorModel instance] leftSensorReadings];
    NSArray* rightReadings = [[SensorModel instance] rightSensorReadings];
    
    long length = MIN([leftReadings count], [rightReadings count]);
    
    for (int i = 0; i < length; i++)
    {
        SensorReading* leftReading = leftReadings[i];
        SensorReading* rightReading = rightReadings[i];
        [self logLineToDataFile: [leftReading formattedValue]];
        [self logLineToDataFile:@","];
        [self logLineToDataFile: [rightReading formattedValue]];
        [self logLineToDataFile: @"\n"];
    }
    /*
    // For every reading, log formatted version to CSV
    for (SensorReading* r in readings) {
        [self logLineToDataFile: [r formattedValue]];
        [self logLineToDataFile: @"\n"];
    }*/
}

- (IBAction)endWorkoutButton:(UIButton *)sender {
    [self saveReadingsToCSV];
    [self.endWorkoutButton setEnabled:NO];
}

-(IBAction)hitRecordStopButton:(UIButton *)b {
    if (!_isRecording) {
        [b setTitle:@"Stop" forState:UIControlStateNormal];
        _isRecording = TRUE;
        [self.recordingIndicator startAnimating];
        [[SensorModel instance] sendSignal: @"Y"];
        [self.endWorkoutButton setEnabled:NO];
    } else {
        [b setTitle:@"Start" forState:UIControlStateNormal];
        _isRecording = FALSE;
        [self.recordingIndicator stopAnimating];
        [[SensorModel instance] sendSignal: @"N"];
        [self.endWorkoutButton setEnabled:YES];
        
        if ([self.includeExercise isOn]) {
            
            //NSDate *currDate = [NSDate date];
            NSArray* tmpLeftReadings = [[SensorModel instance] tmpLeftSensorReadings];
            NSArray* tmpRightReadings = [[SensorModel instance] tmpRightSensorReadings];
            
            [[[SensorModel instance] leftSensorReadings] addObjectsFromArray:tmpLeftReadings];
            
            [[[SensorModel instance] rightSensorReadings] addObjectsFromArray:tmpRightReadings];
            
            NSDate *currDate = [[tmpLeftReadings lastObject] time];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
            NSString *dateString = [dateFormatter stringFromDate:currDate];
            
            [_exerciseEndDateMap setValue:dateString forKey:[self.exerciseName text]];
        }
        
        [[[SensorModel instance] tmpLeftSensorReadings] removeAllObjects];
        [[[SensorModel instance] tmpRightSensorReadings] removeAllObjects];
        
        self.exerciseName.text = @"";
        
    }
}


-(IBAction)hitClearButton:(UIButton *)b {
    [self resetLogFile];
    [_exerciseEndDateMap removeAllObjects];
}

-(IBAction)emailLogFile:(UIButton *)b {
    
    if (![MFMailComposeViewController canSendMail]) {
        _alert = [UIAlertController alertControllerWithTitle:@"Can't send mail" message:@"Please set up an email account on this phone to send mail" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action)
                             {
                                 [self dismissViewControllerAnimated:YES completion:nil];
                             }];
        [_alert addAction:ok]; // add action to uialertcontroller
        [self presentViewController:_alert animated:YES completion:nil];
        return;
    }
    NSData *fileData = [NSData dataWithContentsOfFile:[self getPathToLogFile]];
    //NSData *timesData = [NSKeyedArchiver archivedDataWithRootObject:_exerciseEndDateMap];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_exerciseEndDateMap options: NSJSONWritingPrettyPrinted error:&error];
    
    if (!fileData || [fileData length] == 0)
        return;
    NSString *emailTitle = @"Position File";
    NSString *messageBody = @"Data from PositionLogger";
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    
    // Determine the MIME type
    NSString *mimeType = @"text/plain";
    
    //MIME type for secondary data
    NSString *timesMimeType  = @"application/javascript";
    
    // Add attachment
    [mc addAttachmentData:fileData mimeType:mimeType fileName:kDATA_FILE_NAME];
    
    [mc addAttachmentData:jsonData mimeType:timesMimeType fileName:kDATES_FILE_NAME];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
}

#pragma mark - MFMailComposeViewControllerDelegate Methods -

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}


@end
