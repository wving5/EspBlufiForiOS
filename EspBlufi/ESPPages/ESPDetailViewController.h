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
    TagConnect = 6000,
    TagDisconnect,
    TagSecurity,
    TagVersion,
    TagConfigure,
    TagState,
    TagScan,
    TagCustom,
} TagButton;

NS_ASSUME_NONNULL_BEGIN

@interface ESPDetailViewController : UIViewController

@property (assign, atomic ,readonly) BOOL connected;
@property (strong, nonatomic) ESPPeripheral *device;

// UI Properties
@property (strong, nonatomic) UIButton *connectBtn;
@property (strong, nonatomic) UIButton *disConnectBtn;
@property (strong, nonatomic) UIButton *encryptionBtn;
@property (strong, nonatomic) UIButton *versionBtn;
@property (strong, nonatomic) UIButton *configureBtn;
@property (strong, nonatomic) UIButton *stateBtn;
@property (strong, nonatomic) UIButton *scanBtn;
@property (strong, nonatomic) UIButton *customBtn;

@property (strong, nonatomic) UITableView *messageView;
@property (strong, nonatomic) NSMutableArray *messageArray;

- (void)onButtonAction:(TagButton)buttonTag;

@end

NS_ASSUME_NONNULL_END
