//
//  BLEMananger.h
//  Anteater
//
//  Created by Sam Madden on 1/13/16.
//  Copyright © 2016 Sam Madden. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RBL_SERVICE_UUID                         "713D0000-503E-4C75-BA94-3148F18D941E"
#define RBL_CHAR_TX_UUID                         "713D0002-503E-4C75-BA94-3148F18D941E"
#define RBL_CHAR_RX_UUID                         "713D0003-503E-4C75-BA94-3148F18D941E"

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

@end

