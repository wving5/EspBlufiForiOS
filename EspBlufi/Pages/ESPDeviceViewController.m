//
//  ESPDeviceViewController.m
//  EspBlufi
//
//  Created by fanbaoying on 2020/6/10.
//  Copyright © 2020 espressif. All rights reserved.
//

#import "ESPDeviceViewController.h"
#import "ESPDeviceViewController+UI.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "ESPProvisionViewController.h"
#import "BlufiClient.h"

@interface ESPDeviceViewController () <CBCentralManagerDelegate, CBPeripheralDelegate, BlufiDelegate, ESPProvisionParamsDelegate>

@property (strong, nonatomic) ESPPeripheral *device;

@property (strong, nonatomic) BlufiClient *blufiClient;  // reset before each connect, nil protection NOT needed for objc
@property (assign, atomic) BOOL connected;

@end

@implementation ESPDeviceViewController

- (instancetype)initWithDevice:(ESPPeripheral *)device
{
    if (self = [super init]) {
        _device = device;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.connected = NO;
    [self setupUIWith: self.device.name];
}

#pragma mark - Button Actions

- (void)onButtonAction:(ButtonTag)buttonTag {
    switch (buttonTag) {
        case Btn_Connect:
            [self connect];
            break;
        case Btn_Disconnect:
            [_blufiClient requestCloseConnection];
            break;
        case Btn_Security:
            [self setButton:self.encryptionBtn enable:NO];
            [_blufiClient negotiateSecurity];
            break;
        case Btn_Version:
            [self setButton:self.versionBtn enable:NO];
            [_blufiClient requestDeviceVersion];
            break;
        case Btn_Configure:
            [self goToProvisionVC];
            break;
        case Btn_State:
            [self setButton:self.stateBtn enable:NO];
            [_blufiClient requestDeviceStatus];
            break;
        case Btn_Scan:
            [self setButton:self.scanBtn enable:NO];
            [_blufiClient requestDeviceScan];
            break;
        case Btn_Custom:
            [self setButton:self.customBtn enable:NO];
            [self handleCustomDataInput];
            break;
        default:
            break;
    }
}

#pragma mark - BluFi Connection

- (void)handleCustomDataInput {
    [self
        showCustomDataAlertWithOKHandler:^(NSString *inputText) {
        // FIXME: 根据 alert 回调来启用/禁用 btn 没啥意义 ?
            [self setButton:self.customBtn enable:self.connected];

            if (inputText && inputText.length > 0 && self.blufiClient) {
                NSData *data = [inputText dataUsingEncoding:NSUTF8StringEncoding];
                [self.blufiClient postCustomData:data];
            }
        }
        cancelHandler:^{
            [self setButton:self.customBtn enable:self.connected];
        }];
}

- (void)connect {
    [self setButton:_connectBtn enable:NO];

    [self resetBlufiClient];
    [_blufiClient connect:_device.uuid.UUIDString];
}

- (void)onDisconnected {
    [_blufiClient close];

    [self updateAllButtonsForConnectionState:NO];
}

- (void)onBlufiPrepared {
    [self updateAllButtonsForConnectionState:YES];
}

- (void)resetBlufiClient {
    [_blufiClient close];
    _blufiClient = nil;

    _blufiClient = [[BlufiClient alloc] init];
    _blufiClient.centralManagerDelete = self;
    _blufiClient.peripheralDelegate = self;
    _blufiClient.blufiDelegate = self;
}

#pragma mark - provision VC related
- (void)goToProvisionVC {
    ESPProvisionViewController *pvc = [ESPProvisionViewController new];
    pvc.paramsDelegate = self;
    [self.navigationController pushViewController:pvc animated:YES];
}

- (void)provisionDidSetParams:(BlufiConfigureParams *)params {
    if (_blufiClient && _connected) {
        [_blufiClient configure:params];
    }
}

#pragma mark - CoreBluetooth Delegate Methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [self updateMessage:@"Connected device"];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [self updateMessage:@"Connet device failed"];
    self.connected = NO;
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [self onDisconnected];
    [self updateMessage:@"Disconnected device"];
    self.connected = NO;
}

#pragma mark - BluFi Delegate Methods

- (void)blufi:(BlufiClient *)client
    gattPrepared:(BlufiStatusCode)status
         service:(CBService *)service
       writeChar:(CBCharacteristic *)writeChar
      notifyChar:(CBCharacteristic *)notifyChar {
    DLog(@"Blufi gattPrepared status:%d", status);
    if (status == StatusSuccess) {
        self.connected = YES;
        [self updateMessage:@"BluFi connection has prepared"];
        [self onBlufiPrepared];
    } else {
        [self onDisconnected];
        if (!service) {
            [self updateMessage:@"Discover service failed"];
        } else if (!writeChar) {
            [self updateMessage:@"Discover write char failed"];
        } else if (!notifyChar) {
            [self updateMessage:@"Discover notify char failed"];
        }
    }
}

- (void)blufi:(BlufiClient *)client didNegotiateSecurity:(BlufiStatusCode)status {
    DLog(@"Blufi didNegotiateSecurity %d", status);
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self setButton:self.encryptionBtn enable:self.connected];
    }];
    if (status == StatusSuccess) {
        [self updateMessage:@"Negotiate security complete"];
    } else {
        [self updateMessage:[NSString stringWithFormat:@"Negotiate security failed: %d", status]];
    }
}

- (void)blufi:(BlufiClient *)client didReceiveDeviceVersionResponse:(BlufiVersionResponse *)response status:(BlufiStatusCode)status {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self setButton:self.versionBtn enable:self.connected];
    }];
    if (status == StatusSuccess) {
        [self updateMessage:[NSString stringWithFormat:@"Receive device version: %@", response.getVersionString]];
    } else {
        [self updateMessage:[NSString stringWithFormat:@"Receive device version error: %d", status]];
    }
}

- (void)blufi:(BlufiClient *)client didPostConfigureParams:(BlufiStatusCode)status {
    if (status == StatusSuccess) {
        [self updateMessage:@"Post configure params complete"];
    } else {
        [self updateMessage:[NSString stringWithFormat:@"Post configure params failed: %d", status]];
    }
}

- (void)blufi:(BlufiClient *)client didReceiveDeviceStatusResponse:(BlufiStatusResponse *)response status:(BlufiStatusCode)status {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self setButton:self.stateBtn enable:self.connected];
    }];
    if (status == StatusSuccess) {
        [self updateMessage:[NSString stringWithFormat:@"Receive device status:\n%@", response.getStatusInfo]];
    } else {
        [self updateMessage:[NSString stringWithFormat:@"Receive device status error: %d", status]];
    }
}

- (void)blufi:(BlufiClient *)client didReceiveDeviceScanResponse:(NSArray<BlufiScanResponse *> *)scanResults status:(BlufiStatusCode)status {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self setButton:self.scanBtn enable:self.connected];
    }];
    if (status == StatusSuccess) {
        NSMutableString *info = [[NSMutableString alloc] init];
        [info appendString:@"Receive device scan results:\n"];
        for (BlufiScanResponse *response in scanResults) {
            [info appendFormat:@"SSID: %@, RSSI: %d\n", response.ssid, response.rssi];
        }
        [self updateMessage:info];
    } else {
        [self updateMessage:[NSString stringWithFormat:@"Receive device scan results error: %d", status]];
    }
}

- (void)blufi:(BlufiClient *)client didPostCustomData:(nonnull NSData *)data status:(BlufiStatusCode)status {
    if (status == StatusSuccess) {
        [self updateMessage:@"Post custom data complete"];
    } else {
        [self updateMessage:[NSString stringWithFormat:@"Post custom data failed: %d", status]];
    }
}

- (void)blufi:(BlufiClient *)client didReceiveCustomData:(NSData *)data status:(BlufiStatusCode)status {
    NSString *customString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self updateMessage:[NSString stringWithFormat:@"Receive device custom data: %@", customString]];
}

@end
