//
//  ESPDeviceViewController.h
//  EspBlufi
//
//  Created by fanbaoying on 2020/6/10.
//  Copyright © 2020 espressif. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESPPeripheral.h"
#import "ESPDeviceActionStates.h"

NS_ASSUME_NONNULL_BEGIN


@interface ESPDeviceViewController : UIViewController

- (instancetype)initWithDevice:(ESPPeripheral *)device;

// action from category
- (void)onButtonTapped:(ESPActionType)buttonTag;

// UI Properties shared with category
// FIXME: 内部各种 callback 状态需要跟 btn 解耦，纯状态发送到分类去更新
@property (strong, nonatomic) UIButton *connectBtn;
@property (strong, nonatomic) UIButton *disconnectBtn;
@property (strong, nonatomic) UIButton *encryptionBtn;
@property (strong, nonatomic) UIButton *versionBtn;
@property (strong, nonatomic) UIButton *configureBtn;
@property (strong, nonatomic) UIButton *stateBtn;
@property (strong, nonatomic) UIButton *scanBtn;
@property (strong, nonatomic) UIButton *customBtn;

@property (strong, nonatomic) UITableView *messageView;
@property (strong, nonatomic) NSMutableArray *messageArray; // tableview datasource

@end

NS_ASSUME_NONNULL_END
