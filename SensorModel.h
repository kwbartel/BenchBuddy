//
//  BLEMananger.h
//  Anteater
//
//  Created by Sam Madden on 1/13/16.
//  Copyright © 2016 Sam Madden. All rights reserved.
//

#import <Foundation/Foundation.h>

//#import "BLESensorReading.h"
@import CoreBluetooth;

@protocol SensorModelDelegate <NSObject>

-(void) bleDidConnect;
-(void) bleDidDisconnect;
//-(void) bleGotSensorReading:(BLESensorReading*)reading;

@end

@interface SensorModel : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

+(SensorModel *)instance;

@property(atomic,strong) id<SensorModelDelegate> delegate;
@property(atomic) NSArray *sensorReadings;
@property CBCentralManager* CM;
@property bool shouldScan;
@property NSString* message;
@property(atomic) CBPeripheral* currentPeripheral;
-(void)startScanning;
-(void)stopScanning;
-(BOOL)isConnected;
-(NSString *)currentSensorId;
-(NSString *)getReadingsList;

@end

