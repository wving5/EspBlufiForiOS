//
//  ESPSettingViewController+UI.h
//  EspBlufi
//
//  Created by Augment Agent on 2024/12/19.
//  Copyright © 2020 espressif. All rights reserved.
//

#import "ESPSettingViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESPSettingViewController (UI)

- (void)setupUI;

- (void)updateUI_filterText:(NSString *) filterText;

- (void)showDeviceFilterAlertWithOnOK:(void(^)(NSString *filterText))onOK onCancel:(void(^)(void))onCancel;

@end

NS_ASSUME_NONNULL_END
