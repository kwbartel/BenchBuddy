//
//  ReadingsAnalyzer.h
//  WorkoutLogger
//
//  Created by Kwame Efah  on 5/6/16.
//  Copyright © 2016 Sam Madden. All rights reserved.
//

#ifndef ReadingsAnalyzer_h
#define ReadingsAnalyzer_h



@interface ReadingsAnalyzer : NSObject
+(ReadingsAnalyzer *) instance;

-(int) countRepetitionsFromLeft:(NSArray *)leftSensorReadings andRight: (NSArray*) rightSensorReadings;

@end

#endif /* ReadingsAnalyzer_h */
