//
//  BleDeviceListViewController.m
//  EspBlufi
//
//  Created by fanbaoying on 2020/6/9.
//  Copyright © 2020 espressif. All rights reserved.
//

#import "BleDeviceListViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "ESPBLEHelper.h"
#import "ESPUserDefaults.h"
#import "BleDeviceListViewController+UI.h"
#import "MJRefresh.h"


@interface BleDeviceListViewController () <UITableViewDelegate>

@property (nonatomic, strong) NSString *filterContent;

@end

@implementation BleDeviceListViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.filterContent = [ESPUserDefaults loadBlufiScanFilter];
    [self scanDeviceInfo];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[ESPBLEHelper share] stopScan];
}

- (void)scanDeviceInfo {
    [self.dataSource removeAllObjects];
    [[ESPBLEHelper share] startScan:^(ESPPeripheral *_Nonnull device) {
        if ([self shouldAddToSource:device]) {
            [self.dataSource addObject:device];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.peripheralTableView reloadData];
            });
        }
    }];
}

- (void)MJRefresh_triggered {
    [self.peripheralTableView.mj_header beginRefreshing];
    
    [self scanDeviceInfo];
    
    int delayInSeconds = 3; // TODO: better than hardcode ?
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.peripheralTableView.mj_header endRefreshing];
        [self.peripheralTableView reloadData];
    });
}

#pragma mark - data methods
- (BOOL)shouldAddToSource:(ESPPeripheral *)device {
    NSArray *source = [self dataSource];
    
    // Check filter
    if (_filterContent && _filterContent.length > 0) {
        if (!device.name || ![device.name hasPrefix:_filterContent]) {
            // The device name has no filter prefix
            return NO;
        }
    }

    // Check if uuid exist
    for (int i = 0; i < source.count; i++) {
        ESPPeripheral *existDevice = source[i];
        if ([device.uuid isEqual:existDevice.uuid]) {
            // The device exists in source already
            return NO;
        }
    }

    return YES;
}

- (NSMutableArray *)dataSource {
    if (!_peripheralArray) {
        _peripheralArray = [[NSMutableArray alloc] init];
    }
    return _peripheralArray;
}

@end
