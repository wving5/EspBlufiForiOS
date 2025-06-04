//
//  BleDeviceListViewController+UI.m
//  EspBlufi
//
//  Created by cty on 2025/6/4.
//  Copyright © 2025 espressif. All rights reserved.
//

#import "BleDeviceListViewController+UI.h"
#import "FFDropDownMenuView.h"
#import "ESPDetailViewController.h"
#import "ESPSettingViewController.h"
#import "MJRefresh.h"


@implementation BleDeviceListViewController (UI)

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = INTER_STR(@"EspBlufi-nav-title");
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                           target:self
                                                                                           action:@selector(showDropDownMenu)];
    
    NSArray *modelsArray = [self getMenuModelsArray];
    self.dropDownMenu = [FFDropDownMenuView ff_DefaultStyleDropDownMenuWithMenuModelsArray:modelsArray
                                                                                 menuWidth:140
                                                                            eachItemHeight:50
                                                                           menuRightMargin:FFDefaultFloat
                                                                       triangleRightMargin:FFDefaultFloat];
    
    self.peripheralTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.peripheralTableView.delegate = self;
    self.peripheralTableView.dataSource = self;
    self.peripheralTableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.peripheralTableView];
    self.peripheralTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(MJRefresh_triggered)];
}

- (void)showDropDownMenu {
    [self.dropDownMenu showMenu];
}

- (NSArray *)getMenuModelsArray {
    __weak typeof(self) weakSelf = self;
    FFDropDownMenuModel *menuModel0 =
        [FFDropDownMenuModel ff_DropDownMenuModelWithMenuItemTitle:INTER_STR(@"EspBlufi-Setting")
                                                  menuItemIconName:nil
                                                         menuBlock:^{
                                                             ESPSettingViewController *svc = [ESPSettingViewController new];
                                                             [weakSelf.navigationController pushViewController:svc animated:YES];
                                                         }];
    NSArray *menuModelArr = @[ menuModel0 ];
    return menuModelArr;
}

#pragma mark - table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.peripheralArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    if (!ValidArray(self.peripheralArray)) {
        return cell;
    }

    ESPPeripheral *device = self.peripheralArray[indexPath.row];
    NSString *name = device.name;
    int rssi = device.rssi;
    NSString *uuid = device.uuid.UUIDString;

    UILabel *nameLab = [[UILabel alloc] init];
    nameLab.frame = CGRectMake(15, 0, CGRectGetWidth(tableView.frame), 40);
    NSString *deviceName = [NSString stringWithFormat:@"%@    %d", name, rssi];
    nameLab.text = deviceName;
    nameLab.font = [UIFont systemFontOfSize:16];
    [cell.contentView addSubview:nameLab];

    UILabel *uuidLab = [[UILabel alloc] init];
    uuidLab.frame = CGRectMake(15, 30, CGRectGetWidth(tableView.frame), 20);
    NSString *deviceInfo = [NSString stringWithFormat:@"%@", uuid];
    uuidLab.text = deviceInfo;
    uuidLab.textColor = [UIColor lightGrayColor];
    uuidLab.font = [UIFont systemFontOfSize:14];
    [cell.contentView addSubview:uuidLab];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!ValidArray(self.peripheralArray)) {
        return;
    }
    ESPDetailViewController *dvc = [ESPDetailViewController new];
    dvc.device = self.peripheralArray[indexPath.row];
    [self.navigationController pushViewController:dvc animated:YES];
}

@end
