//
//  ESPBleHelper.m
//  EspBlufi
//
//  Created by fanbaoying on 2020/6/11.
//  Copyright © 2020 espressif. All rights reserved.
//

#import "ESPBleHelper.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface ESPBleHelper () <CBCentralManagerDelegate, CBPeripheralDelegate>
// 中心管理者(管理设备的扫描和连接)
@property (nonatomic, strong) CBCentralManager *centralManager;
// 存储的设备
@property (nonatomic, strong) NSMutableArray *peripherals;

// 外设状态
@property (nonatomic, assign) CBManagerState peripheralState;

@end

@implementation ESPBleHelper

#pragma mark - Singleton
- (instancetype)init {
    // Prevent direct instantiation
    NSAssert(NO, @"Use +sharedInstance instead of -init");
    return nil;
}

- (instancetype)_init {
    if (self = [super init]) {
        // TODO: thread safe ?
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return self;
}

// 单例模式
+ (instancetype)share {
    static ESPBleHelper *share = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        share = [[ESPBleHelper alloc] _init];
    });
    return share;
}

// Override allocWithZone to ensure singleton behavior
+ (instancetype)allocWithZone:(NSZone *)zone {
    static ESPBleHelper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [super allocWithZone:zone];
    });
    return sharedInstance;
}

// Prevent copying
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

#pragma mark - methods
- (void)stopScan {
    [self.centralManager stopScan];
}

- (void)startScan:(bleDeviceScanCallback)callback {
    DLog(@"BLE 扫描设备");
    _onBleScanSuccess = callback;
    if (self.peripheralState == CBManagerStatePoweredOn) {
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    }
}

/**
 扫描到设备

 @param central 中心管理者
 @param peripheral 扫描到的设备
 @param advertisementData 广告信息
 @param RSSI 信号强度
 */
- (void)centralManager:(CBCentralManager *)central
    didDiscoverPeripheral:(CBPeripheral *)peripheral
        advertisementData:(NSDictionary<NSString *, id> *)advertisementData
                     RSSI:(NSNumber *)RSSI {
    ESPPeripheral *espPeripheral = [[ESPPeripheral alloc] initWithPeripheral:peripheral];
    espPeripheral.name = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
    espPeripheral.rssi = RSSI.intValue;
    if (self.onBleScanSuccess) {
        self.onBleScanSuccess(espPeripheral);
    }
}

// 状态更新时调用
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStateUnknown: {
            DLog(@"BLE 未知状态");
            self.peripheralState = central.state;
        } break;
        case CBManagerStateResetting: {
            DLog(@"BLE 重置状态");
            self.peripheralState = central.state;
        } break;
        case CBManagerStateUnsupported: {
            DLog(@"BLE 不支持的状态");
            self.peripheralState = central.state;
        } break;
        case CBManagerStateUnauthorized: {
            DLog(@"BLE 未授权的状态");
            self.peripheralState = central.state;
        } break;
        case CBManagerStatePoweredOff: {
            DLog(@"BLE 关闭状态");
            self.peripheralState = central.state;
        } break;
        case CBManagerStatePoweredOn: {
            self.peripheralState = central.state;
            DLog(@"BLE 开启状态－可用状态 %ld", (long)self.peripheralState);
            [self.centralManager scanForPeripheralsWithServices:nil options:nil];
        } break;
        default:
            break;
    }
}

@end
