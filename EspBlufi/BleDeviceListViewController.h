//
//  BleDeviceListViewController.h
//  EspBlufi
//
//  Created by fanbaoying on 2020/6/9.
//  Copyright © 2020 espressif. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESPPeripheral.h"

@class FFDropDownMenuView;

@interface BleDeviceListViewController : UIViewController

@property (nonatomic, strong) FFDropDownMenuView *dropDownMenu;
@property (nonatomic, strong) UITableView *peripheralTableView;
@property (nonatomic, copy) NSMutableArray<ESPPeripheral *> *peripheralArray;

- (void)MJRefresh_triggered;

@end
