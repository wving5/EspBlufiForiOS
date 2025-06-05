//
//  ESPProvisionViewController.m
//  EspBlufi
//
//  Created by fanbaoying on 2020/6/11.
//  Copyright © 2020 espressif. All rights reserved.
//

#import "ESPProvisionViewController.h"
#import "ESPProvisionViewController+UI.h"
#import <CoreLocation/CoreLocation.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "HUDTips.h"

#define offset    35
#define Height    40

@interface ESPProvisionViewController () <CLLocationManagerDelegate>

@property (nonatomic, assign) OpMode displaymode;
@property (nonatomic, assign) SoftAPPasswordMode softapPasswordmode;

@property (nonatomic, strong) NSMutableDictionary *pickersResultMap;
@property (nonatomic, strong) CLLocationManager *locationManagerSystem;

@end

@implementation ESPProvisionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // pre-flighgt location permission for get WiFi SSID
    if (![self getUserLocationAuth]) {
        self.locationManagerSystem = [[CLLocationManager alloc] init];
        self.locationManagerSystem.delegate = self;
        [self.locationManagerSystem requestWhenInUseAuthorization];
    }
        
    // initial state
    self.softapPasswordmode = Pwd_None;
    self.displaymode = OpModeNull;
    self.pickersResultMap = @{}.mutableCopy;
    
    [self setupUI];
}


- (void)onSubmitForm:(NSDictionary *)formParams {
    NSString * staSsid = formParams[@"staSsid"];
    NSString * staPassword = formParams[@"staPassword"];
    NSString * softApSsid = formParams[@"softApSsid"];
    NSString * softApPassword = formParams[@"softApPassword"];
    
    DLog(@"提交表单: %@", formParams);
    BlufiConfigureParams *params = [[BlufiConfigureParams alloc] init];
    if (self.displaymode == OpModeNull) {
        params.opMode = OpModeNull;
        if (self.paramsDelegate) {
            [self.paramsDelegate provisionDidSetParams:params];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else if (self.displaymode == OpModeSta) {
        params.opMode = OpModeSta;
        params.staSsid = staSsid;
        params.staPassword = staPassword;
        if (self.paramsDelegate) {
            [self.paramsDelegate provisionDidSetParams:params];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else if (self.displaymode == OpModeSoftAP) {
        if (self.softapPasswordmode != Pwd_None) {
            if (softApSsid.length <= 0) {
                [HUDTips ShowLabelTipsToView:self.view WithText:INTER_STR(@"EspBlufi-configure-softAp")];
                return;
            }
        }

        params.opMode = OpModeSoftAP;
        params.softApSsid = softApSsid;
        params.softApPassword = softApPassword;
        params.softApChannel = [self.pickersResultMap[@(Picker_Channell)] integerValue];
        params.softApMaxConnection = [self.pickersResultMap[@(Picker_Max_Connection)] integerValue];
        if ([self.pickersResultMap[@(Picker_Security)] isEqualToString:@"OPEN"]) {
            params.softApSecurity = SoftAPSecurityOpen;
        } else if ([self.pickersResultMap[@(Picker_Security)] isEqualToString:@"WPA_PSK"]) {
            params.softApSecurity = SoftAPSecurityWPA;
        } else if ([self.pickersResultMap[@(Picker_Security)] isEqualToString:@"WPA2_PSK"]) {
            params.softApSecurity = SoftAPSecurityWPA2;
        } else if ([self.pickersResultMap[@(Picker_Security)] isEqualToString:@"WPA_WPA2_PSK"]) {
            params.softApSecurity = SoftAPSecurityWPAWPA2;
        } else {
            NSAssert(false, @"unknown param");
            return;
        }

        if (self.paramsDelegate) {
            [self.paramsDelegate provisionDidSetParams:params];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else if (self.displaymode == OpModeStaSoftAP) {
        if (self.softapPasswordmode != Pwd_None) {
            if (softApPassword.length <= 0) {
                [HUDTips ShowLabelTipsToView:self.view WithText:INTER_STR(@"EspBlufi-configure-softAp")];
                return;
            }
        }
        params.opMode = OpModeStaSoftAP;
        params.softApSsid = softApSsid;
        params.softApPassword = softApPassword;
        params.softApChannel = [self.pickersResultMap[@(Picker_Channell)] integerValue];
        params.softApMaxConnection = [self.pickersResultMap[@(Picker_Max_Connection)] integerValue];
        if ([self.pickersResultMap[@(Picker_Security)] isEqualToString:@"OPEN"]) {
            params.softApSecurity = SoftAPSecurityOpen;
        } else if ([self.pickersResultMap[@(Picker_Security)] isEqualToString:@"WPA_PSK"]) {
            params.softApSecurity = SoftAPSecurityWPA;
        } else if ([self.pickersResultMap[@(Picker_Security)] isEqualToString:@"WPA2_PSK"]) {
            params.softApSecurity = SoftAPSecurityWPA2;
        } else if ([self.pickersResultMap[@(Picker_Security)] isEqualToString:@"WPA_WPA2_PSK"]) {
            params.softApSecurity = SoftAPSecurityWPAWPA2;
        } else {
            NSAssert(false, @"unknown param");
            return;
        }

        params.staSsid = staSsid;
        params.staPassword = staPassword;

        if (self.paramsDelegate) {
            [self.paramsDelegate provisionDidSetParams:params];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        NSAssert(false, @"unknown wifi mode");
    }
}

- (void)setDisplaymode:(OpMode)displaymode {
    _displaymode = displaymode;
    
    NSString* staSsid = [self getWifiName];
    [self updateUI_setDisplaymode:displaymode
               softapPasswordmode:self.softapPasswordmode
                          staSsid:staSsid];
}


# pragma mark - espPickerView delegate

- (void)espPickerView:(ESPChoicePickerView *)picker didSelect:(NSString *)str {
    [self updateUI_espPickerView:picker didSelect:str];
    
    self.pickersResultMap[@(picker.type)] = str;
    
    if (picker.type == Picker_DeviceMode) {
        if ([str isEqualToString:@"NULL"]) {
            self.displaymode = OpModeNull;
        } else if ([str isEqualToString:@"STA"]) {
            self.displaymode = OpModeSta;
        } else if ([str isEqualToString:@"SoftAP"]) {
            self.displaymode = OpModeSoftAP;
        } else if ([str isEqualToString:@"SoftAP&STA"]) {
            self.displaymode = OpModeStaSoftAP;
        } else {
            NSAssert(false, @"unknown device mode");
        }
    } else if (picker.type == Picker_Security) {
        if ([str isEqualToString:@"OPEN"]) {
            self.softapPasswordmode = Pwd_None;
        } else {
            self.softapPasswordmode = Pwd_Required;
        }
        self.displaymode = self.displaymode;
    } else if (picker.type == Picker_Channell) {
    } else if (picker.type == Picker_Max_Connection) {
    } else {
        NSAssert(false, @"unknown picker");
    }
}


#pragma mark - util

// 获取wifi名称
- (NSString *)getWifiName {
    NSString *wifiName = nil;
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    if (!wifiInterfaces) {
        return nil;
    }
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            DLog(@"network info -> %@", networkInfo);
            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            CFRelease(dictRef);
        }
    }
    CFRelease(wifiInterfaces);
    return wifiName;
}


- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    CLAuthorizationStatus status = manager.authorizationStatus;

    BOOL denied = NO;
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            break;
        case kCLAuthorizationStatusRestricted:
            break;
        case kCLAuthorizationStatusDenied:
            denied = YES;
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            break;

        default:
            break;
    }
    if (denied) {
        [self showLocationAlert];
    }
}

- (BOOL)getUserLocationAuth {
    BOOL authorized = NO;
    switch ([_locationManagerSystem authorizationStatus]) {
        case kCLAuthorizationStatusNotDetermined:
            break;
        case kCLAuthorizationStatusRestricted:
            break;
        case kCLAuthorizationStatusDenied:
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            authorized = YES;
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            authorized = YES;
            break;

        default:
            break;
    }
    return authorized;
}


@end
