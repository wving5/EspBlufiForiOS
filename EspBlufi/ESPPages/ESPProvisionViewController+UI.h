//
//  ESPProvisionViewController+UI.h
//  EspBlufi
//
//  Created by Augment Agent on 2024/12/19.
//  Copyright © 2020 espressif. All rights reserved.
//

#import "ESPProvisionViewController.h"
#import "ESPChoicePickerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESPProvisionViewController (UI) <UITextFieldDelegate, ESPChoicePickerDelegate>

- (void)setupUI;

- (void)showLocationAlert;

- (void)updateUI_espPickerView:(ESPChoicePickerView *)picker didSelect:(NSString *)str;
- (void)updateUI_setDisplaymode:(OpMode)displaymode
             softapPasswordmode:(SoftAPPasswordMode)softapPasswordmode
                        staSsid:(NSString*) staSsid;

@end

NS_ASSUME_NONNULL_END
