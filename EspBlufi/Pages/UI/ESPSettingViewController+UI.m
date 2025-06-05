//
//  ESPSettingViewController+UI.m
//  EspBlufi
//
//  Created by Augment Agent on 2024/12/19.
//  Copyright © 2020 espressif. All rights reserved.
//

#import "ESPSettingViewController+UI.h"

#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@implementation ESPSettingViewController (UI)

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = INTER_STR(@"EspBlufi-Setting");
    
    [self setupHeaderView];
    [self setupContentView];
}

- (void)showDeviceFilterAlertWithOnOK:(void(^)(NSString *filterText))onOK onCancel:(void(^)(void))onCancel {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:INTER_STR(@"EspBlufi-filter-content")
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    // Cancel action
    [alertController addAction:[UIAlertAction actionWithTitle:INTER_STR(@"cancel")
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                          if (onCancel) {
                                                              onCancel();
                                                          }
                                                      }]];

    // OK action
    [alertController addAction:[UIAlertAction actionWithTitle:INTER_STR(@"ok")
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                          UITextField *filterTextfield = alertController.textFields.firstObject;
                                                          if (onOK) {
                                                              onOK(filterTextfield.text);
                                                          }
                                                      }]];

    // Add text field
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *_Nonnull textField) {
        textField.placeholder = INTER_STR(@"EspBlufi-filter-content");
    }];

    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UI Setup Methods

- (void)setupHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, statusHeight + 44, SCREEN_WIDTH, 130)];
    [self.view addSubview:headerView];

    UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, SCREEN_WIDTH - 20, 30)];
    headerTitle.textColor = UICOLOR_RGBA(141, 110, 99, 1);
    headerTitle.text = INTER_STR(@"EspBlufi-Setting-sign");
    [headerView addSubview:headerTitle];

    UILabel *filterName = [[UILabel alloc] initWithFrame:CGRectMake(15, 70, SCREEN_WIDTH - 20, 20)];
    filterName.text = INTER_STR(@"EspBlufi-Setting-filter");
    [filterName addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDeviceFilterTapped)]];
    filterName.userInteractionEnabled = YES;
    [headerView addSubview:filterName];

    self.filterContent = [[UILabel alloc] initWithFrame:CGRectMake(15, 90, SCREEN_WIDTH - 20, 20)];
    self.filterContent.textColor = [UIColor lightGrayColor];
    [self.filterContent addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDeviceFilterTapped)]];
    self.filterContent.userInteractionEnabled = YES;
    self.filterContent.font = [UIFont systemFontOfSize:16.0];
    [headerView addSubview:self.filterContent];

    UILabel *separator = [[UILabel alloc] initWithFrame:CGRectMake(0, 129, SCREEN_WIDTH, 1)];
    separator.backgroundColor = UICOLOR_RGBA(221, 221, 221, 1);
    [headerView addSubview:separator];
}

- (void)updateUI_filterText:(NSString *) filterText {
    self.filterContent.text = filterText;
}

- (void)setupContentView {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, statusHeight + 174, SCREEN_WIDTH, SCREEN_HEIGHT - statusHeight - 174)];
    [self.view addSubview:contentView];

    UILabel *contentTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, SCREEN_WIDTH - 20, 30)];
    contentTitle.textColor = UICOLOR_RGBA(141, 110, 99, 1);
    contentTitle.text = INTER_STR(@"EspBlufi-version");
    [contentView addSubview:contentTitle];

    [self setupVersionLabelsInView:contentView];
}

- (void)setupVersionLabelsInView:(UIView *)contentView {
    NSString *appversion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *updateStr = INTER_STR(@"EspBlufi-update-reminder");
    
    NSArray *titleArr = @[ INTER_STR(@"EspBlufi-app-version"), INTER_STR(@"EspBlufi-sdk-version"), INTER_STR(@"EspBlufi-update") ];
    
    NSString *BLUFI_VERSION = self.uiInitData[@"blufiVersion"];
    NSArray *contentArr = @[ appversion, BLUFI_VERSION, updateStr ];

    for (int i = 0; i < titleArr.count - 1; i++) {
        UILabel *version = [[UILabel alloc] initWithFrame:CGRectMake(15, 70 + (60 * i), SCREEN_WIDTH - 20, 20)];
        version.text = titleArr[i];
        version.userInteractionEnabled = NO;
        [contentView addSubview:version];

        UILabel *versionContent = [[UILabel alloc] initWithFrame:CGRectMake(15, 95 + (60 * i), SCREEN_WIDTH - 20, 20)];
        versionContent.textColor = [UIColor lightGrayColor];
        versionContent.font = [UIFont systemFontOfSize:16.0];
        versionContent.text = contentArr[i];
        [contentView addSubview:versionContent];
    }
}

@end
