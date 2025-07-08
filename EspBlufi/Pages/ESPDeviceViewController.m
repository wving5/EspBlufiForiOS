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

// Action states tracking
@property (strong, nonatomic) ESPDeviceActionStates *currentActionStates;

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

    [self initializeActionStates];
    [self setupUIWith: self.device.name];
}

#pragma mark - Button Actions

- (void)onButtonTapped:(ESPActionType)buttonTag {
    switch (buttonTag) {
        case ESPAction_Connect:
            [self updateActionState:ESPActionState_InProgress forAction:ESPAction_Connect];
            [self connect];
            break;
        case ESPAction_Disconnect:
            [_blufiClient requestCloseConnection];
            break;
        case ESPAction_Security:
            [self updateActionState:ESPActionState_InProgress forAction:ESPAction_Security];
            [_blufiClient negotiateSecurity];
            break;
        case ESPAction_Version:
            [self updateActionState:ESPActionState_InProgress forAction:ESPAction_Version];
            [_blufiClient requestDeviceVersion];
            break;
        case ESPAction_Configure:
            // TODO: 可能并不需要等待，先按照等待 didPost 回调处理
            [self goToProvisionVC];
            break;
        case ESPAction_Status:
            [self updateActionState:ESPActionState_InProgress forAction:ESPAction_Status];
            [_blufiClient requestDeviceStatus];
            break;
        case ESPAction_Scan:
            [self updateActionState:ESPActionState_InProgress forAction:ESPAction_Scan];
            [_blufiClient requestDeviceScan];
            break;
        case ESPAction_Custom:
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
            if (inputText && inputText.length > 0 && self.blufiClient) {
                // TODO: 可能并不需要等待，但原来的处理方式也不对
                [self updateActionState:ESPActionState_InProgress forAction:ESPAction_Custom];

                NSData *data = [inputText dataUsingEncoding:NSUTF8StringEncoding];
                [self.blufiClient postCustomData:data];
                // State will be updated in delegate callback
            } else {
                // No data to send, reset to idle state
                [self updateActionState:ESPActionState_Idle forAction:ESPAction_Custom];
            }
        }
        cancelHandler:^{
            // User cancelled, reset to idle state
            [self updateActionState:ESPActionState_Idle forAction:ESPAction_Custom];
        }];
}

- (void)connect {
    [self resetBlufiClient];
    [_blufiClient connect:_device.uuid.UUIDString];
}

- (void)onDisconnected {
//    DLog(@"skip close client"); return;
    [_blufiClient close];
}

- (void)onBlufiPrepared {
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
    DLog(@"设置参数 %@", params);
    if (self.currentActionStates.isConnected) {
        [self updateActionState:ESPActionState_InProgress forAction:ESPAction_Configure];
        DLog(@"# BlufiClient.configure %@", params);
        [_blufiClient configure:params];
    }
}

#pragma mark - CoreBluetooth Delegate Methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [self logMessage:@"#0 BLE Connected device"];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [self logMessage:@"#0 BLE Connet device failed"];
    [self updateActionState:ESPActionState_Failed forAction:ESPAction_Connect];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [self onDisconnected];
    [self logMessage:@"#0 BLE Disconnected device"];
    [self updateActionState:ESPActionState_Idle forAction:ESPAction_Connect];
}

#pragma mark - BluFi Delegate Methods

- (void)blufi:(BlufiClient *)client
    gattPrepared:(BlufiStatusCode)status
         service:(CBService *)service
       writeChar:(CBCharacteristic *)writeChar
      notifyChar:(CBCharacteristic *)notifyChar {
    DLog(@"#1 Blufi gattPrepared status:%d", status);
    if (status == StatusSuccess) {
        [self logMessage:@"#1 BluFi connection has prepared"];
        [self updateActionState:ESPActionState_Success forAction:ESPAction_Connect];
        [self onBlufiPrepared];
    } else {
        [self logMessage:@"#1 BluFi connection failed"];
        [self updateActionState:ESPActionState_Failed forAction:ESPAction_Connect];
        [self onDisconnected];
        if (!service) {
            [self logMessage:@"#1 Discover service failed"];
        } else if (!writeChar) {
            [self logMessage:@"#1 Discover write char failed"];
        } else if (!notifyChar) {
            [self logMessage:@"#1 Discover notify char failed"];
        }
    }
}

- (void)blufi:(BlufiClient *)client didNegotiateSecurity:(BlufiStatusCode)status {
    DLog(@"# Blufi didNegotiateSecurity %d", status);

    ESPActionState newState = (status == StatusSuccess) ? ESPActionState_Success : ESPActionState_Failed;
    [self updateActionState:newState forAction:ESPAction_Security];

    if (status == StatusSuccess) {
        [self logMessage:@"Negotiate security complete"];
    } else {
        [self logMessage:[NSString stringWithFormat:@"Negotiate security failed: %d", status]];
    }
}

- (void)blufi:(BlufiClient *)client didReceiveDeviceVersionResponse:(BlufiVersionResponse *)response status:(BlufiStatusCode)status {
    ESPActionState newState = (status == StatusSuccess) ? ESPActionState_Success : ESPActionState_Failed;
    [self updateActionState:newState forAction:ESPAction_Version];

    if (status == StatusSuccess) {
        [self logMessage:[NSString stringWithFormat:@"Receive device version: %@", response.getVersionString]];
    } else {
        [self logMessage:[NSString stringWithFormat:@"Receive device version error: %d", status]];
    }
}

- (void)blufi:(BlufiClient *)client didPostConfigureParams:(BlufiStatusCode)status {
    ESPActionState newState = (status == StatusSuccess) ? ESPActionState_Success : ESPActionState_Failed;
    [self updateActionState:newState forAction:ESPAction_Configure];
    
    if (status == StatusSuccess) {
        [self logMessage:@"Post configure params complete"];
    } else {
        [self logMessage:[NSString stringWithFormat:@"Post configure params failed: %d", status]];
    }
}

- (void)blufi:(BlufiClient *)client didReceiveDeviceStatusResponse:(BlufiStatusResponse *)response status:(BlufiStatusCode)status {
    ESPActionState newState = (status == StatusSuccess) ? ESPActionState_Success : ESPActionState_Failed;
    [self updateActionState:newState forAction:ESPAction_Status];

    if (status == StatusSuccess) {
        [self logMessage:[NSString stringWithFormat:@"Receive device status:\n%@", response.getStatusInfo]];
    } else {
        [self logMessage:[NSString stringWithFormat:@"Receive device status error: %d", status]];
    }
}

- (void)blufi:(BlufiClient *)client didReceiveDeviceScanResponse:(NSArray<BlufiScanResponse *> *)scanResults status:(BlufiStatusCode)status {
    ESPActionState newState = (status == StatusSuccess) ? ESPActionState_Success : ESPActionState_Failed;
    [self updateActionState:newState forAction:ESPAction_Scan];

    if (status == StatusSuccess) {
        NSMutableString *info = [[NSMutableString alloc] init];
        [info appendString:@"Receive device scan results:\n"];
        for (BlufiScanResponse *response in scanResults) {
            [info appendFormat:@"SSID: %@, RSSI: %d\n", response.ssid, response.rssi];
        }
        [self logMessage:info];
    } else {
        [self logMessage:[NSString stringWithFormat:@"Receive device scan results error: %d", status]];
    }
}

- (void)blufi:(BlufiClient *)client didPostCustomData:(nonnull NSData *)data status:(BlufiStatusCode)status {
    ESPActionState newState = (status == StatusSuccess) ? ESPActionState_Success : ESPActionState_Failed;
    [self updateActionState:newState forAction:ESPAction_Custom];

    if (status == StatusSuccess) {
        [self logMessage:@"Post custom data complete"];
    } else {
        [self logMessage:[NSString stringWithFormat:@"Post custom data failed: %d", status]];
    }
}

- (void)blufi:(BlufiClient *)client didReceiveCustomData:(NSData *)data status:(BlufiStatusCode)status {
    NSString *customString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self logMessage:[NSString stringWithFormat:@"Receive device custom data: %@", customString]];
}

#pragma mark - State Management

- (void)logMessage: (NSString *)msg {
    DLog(@"%@", msg);
    [self updateMessage:msg];
}

- (void)notifyActionStatesChanged {
    DLog(@"### states changed: %@", self.currentActionStates.description);
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self ui_updateButtonStatesWithActionStates:self.currentActionStates];
    }];
}

- (void)initializeActionStates {
    self.currentActionStates = [[ESPDeviceActionStates alloc] init];
}

- (void)updateActionState:(ESPActionState)state forAction:(ESPActionType)action {
    DLog(@"## updateState %@ = %@", ESPActionTypeToString(action), ESPActionStateToString(state));
    switch (action) {
        case ESPAction_Connect:
            self.currentActionStates.connect = state;
            break;
        case ESPAction_Security:
            self.currentActionStates.security = state;
            break;
        case ESPAction_Version:
            self.currentActionStates.version = state;
            break;
        case ESPAction_Configure:
            self.currentActionStates.configure = state;
            break;
        case ESPAction_Status:
            self.currentActionStates.state = state;
            break;
        case ESPAction_Scan:
            self.currentActionStates.scan = state;
            break;
        case ESPAction_Custom:
            self.currentActionStates.custom = state;
            break;
        default:
            break;
    }
    [self notifyActionStatesChanged];
}

@end
