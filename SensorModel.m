//
//  BLEMananger.m
//  Anteater
//
//  Created by Sam Madden on 1/13/16.
//  Copyright © 2016 Sam Madden. All rights reserved.
//

#import "SensorModel.h"
//#import "AnteaterREST.h"
//#import "SettingsModel.h"

/*#define RBL_SERVICE_UUID                         "713D0000-503E-4C75-BA94-3148F18D941E"
#define RBL_CHAR_TX_UUID                         "713D0002-503E-4C75-BA94-3148F18D941E"
#define RBL_CHAR_RX_UUID                         "713D0003-503E-4C75-BA94-3148F18D941E"*/

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
    NSLog(@"Got another reading");
    // Append ASCII message to self.message
    unsigned char data[1024];
    unsigned long data_len = MIN(1024,characteristic.value.length);
    [characteristic.value getBytes:data length:data_len];
    NSData *d = [NSData dataWithBytes:data length:data_len];
    NSString* newMessage = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    self.message = [self.message stringByAppendingString: newMessage];

    // Handle completed message
    int d_index = [self.message rangeOfString:@"D"].location;
    if (d_index > -1) {
        NSString* parse = [self.message substringWithRange:NSMakeRange(0, d_index)];
        self.message = [self.message substringFromIndex:d_index+1];
        NSLog(parse);
        // TODO: make SensorReading from message, add to sensorReadings
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
