//
//  BleDeviceListViewController+UI.h
//  EspBlufi
//
//  Created by cty on 2025/6/4.
//  Copyright © 2025 espressif. All rights reserved.
//

#import "BleDeviceListViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BleDeviceListViewController (UI) <UITableViewDataSource, UITableViewDelegate>

- (void)setupUI;

@end

NS_ASSUME_NONNULL_END
