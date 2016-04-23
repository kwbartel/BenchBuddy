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
    [central connectPeripheral:peripheral
                       options:[NSDictionary
                                dictionaryWithObject:[NSNumber numberWithBool:YES]
                                forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    NSLog(@"didDiscoverPeripheral...");
}

// Task 3
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [self.delegate bleDidConnect];
    [peripheral discoverServices:nil];
    NSLog(@"didConnectPeripheral...");
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
    self.currentPeripheral = nil;
    self.sensorReadings = [[NSArray alloc] init];
    self.message = @"";
    [self.delegate bleDidDisconnect];
    [central scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@RBL_SERVICE_UUID]] options:nil];
    NSLog(@"didDisconnectPeripheral...");
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
    self.currentPeripheral = nil;
    NSLog(@"didFailToConnectPeripheral...");
}

// Task 4 (a)
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    NSLog(@"didDiscoverServices...");
    for (CBService *s in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:s];
    }
}

//Taskl 4 (b)
- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error {
    NSLog(@"didDiscoverIncludedServicesForService...");
    if ([[[service UUID] UUIDString] isEqualToString:@RBL_SERVICE_UUID]) {
        for (CBCharacteristic *c in service.characteristics) {
            if ([[[c UUID] UUIDString] isEqualToString:@RBL_CHAR_TX_UUID]) {
                [peripheral setNotifyValue:YES forCharacteristic:c];
            }
            // TODO: put this as response to button press?
            else if ([[[c UUID] UUIDString] isEqualToString:@RBL_CHAR_RX_UUID]) {
                [peripheral writeValue:[@"Y" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:c type:CBCharacteristicWriteWithoutResponse];
            }
        }
    }
    NSLog(@"Discover characteristics for service...");
}

// Task 5
- (void)peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    // Append ASCII message to self.message
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

    SensorReading *reading = [[SensorReading alloc] initWithReadingsAccel:accelReadings andGyro:gyroReadings atTime: [NSDate date] andSensorId: peripheral.name];
    _sensorReadings = [_sensorReadings arrayByAddingObject:reading];
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
