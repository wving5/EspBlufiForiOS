//
//  ESPSettingViewController.m
//  EspBlufi
//
//  Created by fanbaoying on 2020/6/10.
//  Copyright © 2020 espressif. All rights reserved.
//

#import "ESPSettingViewController.h"
#import "ESPSettingViewController+UI.h"
#import "ESPUserDefaults.h"
#import "BlufiClient.h"


@interface ESPSettingViewController ()
@property (nonatomic, copy) NSDictionary *uiInitData;
@end

@implementation ESPSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Initial data
    NSString* blufiVersion = BLUFI_VERSION;
    NSString *filterText = [ESPUserDefaults getBlufiScanFilter];
    self.uiInitData = @{
        @"blufiVersion" : blufiVersion,
        @"filterText" : filterText
    };
    
    // Setup UI
    [self setupUI];
    
}

#pragma mark - Business Logic

- (void)onDeviceFilterTapped {
    [self deviceFilter];
}

- (void)deviceFilter {
    [self showDeviceFilterAlertWithOnOK:^(NSString *filterText) {
        [ESPUserDefaults saveBlufiScanFilter:filterText];
        [self updateUI_filterText:filterText];
        DLog(@"更新过滤条件: %@", filterText);
    } onCancel:^{
        // Cancel action - no additional logic needed for now
    }];
}

@end
