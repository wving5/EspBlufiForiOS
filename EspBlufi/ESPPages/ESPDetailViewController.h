//
//  ESPDetailViewController.h
//  EspBlufi
//
//  Created by fanbaoying on 2020/6/10.
//  Copyright © 2020 espressif. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESPPeripheral.h"

typedef enum {
    Btn_Connect = 6000,
    Btn_Disconnect,
    Btn_Security,
    Btn_Version,
    Btn_Configure,
    Btn_State,
    Btn_Scan,
    Btn_Custom,
} ButtonTag;

NS_ASSUME_NONNULL_BEGIN

@interface ESPDetailViewController : UIViewController

- (instancetype)initWithDevice:(ESPPeripheral *)device;

// action from category
- (void)onButtonAction:(ButtonTag)buttonTag;


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
