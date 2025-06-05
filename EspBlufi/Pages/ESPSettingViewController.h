//
//  ESPSettingViewController.h
//  EspBlufi
//
//  Created by fanbaoying on 2020/6/10.
//  Copyright © 2020 espressif. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ESPSettingViewController : UIViewController

// action from category
- (void)onDeviceFilterTapped;

@property (nonatomic, copy, readonly) NSDictionary *uiInitData;

// UI Properties shared with category
@property (nonatomic, strong) UILabel *filterContent;

@end

NS_ASSUME_NONNULL_END
