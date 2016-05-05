//
//  BLEMananger.m
//  Anteater
//
//  Created by Sam Madden on 1/13/16.
//  Copyright © 2016 Sam Madden. All rights reserved.
//

#import "SensorModel.h"
#import "SensorReading.h"
//#import "AnteaterREST.h"
//#import "SettingsModel.h"

#define RBL_SERVICE_UUID "713D0000-503E-4C75-BA94-3148F18D941E"
#define RBL_CHAR_TX_UUID "713D0002-503E-4C75-BA94-3148F18D941E"
#define RBL_CHAR_RX_UUID "713D0003-503E-4C75-BA94-3148F18D941E"
#define MAX_PERIPHERALS 2

@import CoreBluetooth;

static id _instance;
@implementation SensorModel {
}

-(id) init {
    self = [super init];
    if (self) {
        self.CM = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        self.shouldScan = false;
        self.message = @"";
        self.sensorReadings = [[NSArray alloc] init];
        
        self.leftSensorReadings = [[NSMutableArray alloc] init];
        self.rightSensorReadings = [[NSMutableArray alloc] init];
        
        self.tmpLeftSensorReadings = [[NSMutableArray alloc] init];
        self.tmpRightSensorReadings = [[NSMutableArray alloc] init];
        
        self.peripherals = [[NSMutableArray alloc] init];
        self.rxCharacteristics = [[NSMutableArray alloc] init];
        self.readyPeripherals = 0;
    }
    return self;
}

- (void) centralManagerDidUpdateState:(CBCentralManager *) central {
    NSLog(@"Update state...");
    if (central.state == CBCentralManagerStatePoweredOn && self.shouldScan) {
        [central scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@RBL_SERVICE_UUID]] options:nil];
    }
}

// Task 2
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(nonnull CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    self.currentPeripheral = peripheral;
    peripheral.delegate = self;
    [self.peripherals addObject: peripheral];
    if ([self.peripherals count] == MAX_PERIPHERALS) {
    NSArray* connectedPeripherals =  [central retrieveConnectedPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@RBL_SERVICE_UUID]]];
        for (int i = 0; i < [self.peripherals count]; i++) {
            if (![connectedPeripherals containsObject:self.peripherals[i]]) {
                [central connectPeripheral: self.peripherals[i]
                                   options:[NSDictionary
                                            dictionaryWithObject:[NSNumber numberWithBool:YES]
                                            forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
            }
        }
    }
    NSLog(@"didDiscoverPeripheral...");
}

// Task 3
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *) peripheral {
    [peripheral discoverServices:nil];
    NSLog(@"didConnectPeripheral...");
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
    self.currentPeripheral = nil;
    [self.peripherals removeObject:peripheral];
    
    if (self.readyPeripherals > 0) {
        self.readyPeripherals--;
    }
    [self.delegate peripheralsForceDisconnected];
    [central scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@RBL_SERVICE_UUID]] options:nil];
    NSLog(@"didDisconnectPeripheral...");
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    self.currentPeripheral = nil;
    [self.peripherals removeObject:peripheral];
    NSLog(@"didFailToConnectPeripheral...");
}

// Task 4 (a)
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    NSLog(@"didDiscoverServices...");
    for (CBService *s in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:s];
    }
}

//Taskl 4(b)
- (void) peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error {
    NSLog(@"didDiscoverIncludedServicesForService...");
    if ([[[service UUID] UUIDString] isEqualToString:@RBL_SERVICE_UUID]) {
        for (CBCharacteristic *c in service.characteristics) {
            if ([[[c UUID] UUIDString] isEqualToString:@RBL_CHAR_TX_UUID]) {
                [peripheral setNotifyValue:YES forCharacteristic:c];
            }
        }
        self.readyPeripherals += 1;
        if (self.readyPeripherals == MAX_PERIPHERALS) {
            [self.delegate peripheralsReadyForDataCollection];
        }
    }
    
    NSLog(@"Discover characteristics for service...");
}

- (void) sendSignal :(NSString*) signal {
    //CBPeripheral *peripheral = self.peripherals[0];
    for (CBPeripheral *peripheral in self.peripherals) {
        for (CBService * service in peripheral.services) {
            if ([[[service UUID] UUIDString] isEqualToString:@RBL_SERVICE_UUID]) {
                for (CBCharacteristic *c in service.characteristics) {
                    if ([[[c UUID] UUIDString] isEqualToString:@RBL_CHAR_RX_UUID]) {
                        [peripheral writeValue:[signal dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:c type:CBCharacteristicWriteWithoutResponse];
                    }
                }
            }
        }
    }
}

// Task 5
- (void)peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    // Append ASCII message to self.message
    if (self.readyPeripherals == MAX_PERIPHERALS ) {
        unsigned char data[16];
        unsigned long data_len = MIN(16,characteristic.value.length);
        [characteristic.value getBytes:data length:data_len];
    
        //Accelerometer data
        short ax = data[1] | (data[2] << 8);
        short ay = data[3] | (data[4] << 8);
        short az = data[5] | (data[6] << 8);
        NSArray *accelReadings = @[[NSNumber numberWithShort:ax], [NSNumber numberWithShort:ay], [NSNumber numberWithShort:az]];
    
        //Gyroscope data
        short gx = data[9] | (data[10] << 8);
        short gy = data[11] | (data[12] << 8);
        short gz = data[13] | (data[14] << 8);
        NSArray *gyroReadings = @[[NSNumber numberWithShort:gx], [NSNumber numberWithShort:gy], [NSNumber numberWithShort:gz]];
        NSDate* date = [NSDate date];
        SensorReading *reading = [[SensorReading alloc] initWithReadingsAccel:accelReadings andGyro:gyroReadings atTime: [NSDate date] andSensorId: peripheral.name];
        
        if ([reading.sensorId isEqualToString:@"LC"]) {
           // _leftSensorReadings = [_leftSensorReadings arrayByAddingObject:reading];
            [_tmpLeftSensorReadings addObject:reading];
        } else if ([reading.sensorId isEqualToString:@"RC"]) {
            //_rightSensorReadings = [_rightSensorReadings arrayByAddingObject:reading];
            [_tmpRightSensorReadings addObject:reading];
        }
        _sensorReadings = [_sensorReadings arrayByAddingObject:reading];
    }
}

-(void)startScanning {
    NSLog(@"startScanning...");
    self.shouldScan = true;
}

-(void)stopScanning {
    [self.CM stopScan];
    NSLog(@"stopScanning...");
}

-(BOOL)isConnected {
    return self.currentPeripheral != nil;
}

-(NSString *)currentSensorId {
    return self.currentPeripheral.name;
}

+(SensorModel *) instance {
    if (!_instance) {
        _instance = [[SensorModel alloc] init];
    }
    return _instance;
}


@end
