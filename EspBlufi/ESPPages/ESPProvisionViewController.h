//
//  ESPProvisionViewController.h
//  EspBlufi
//
//  Created by fanbaoying on 2020/6/11.
//  Copyright © 2020 espressif. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlufiConfigureParams.h"
#import "BlufiConstants.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ESPProvisionParamsDelegate <NSObject>

@required
- (void)provisionDidSetParams:(BlufiConfigureParams *)params;

@end

typedef enum {
    OPEN_Mode = 0x00,
    WEP_Mode = 0x01,
    WPA_PSK_Mode = 0x02,
    WPA2_PSK_Mode = 0x03,
    WPA_WPA2_PSK_Mode = 0X04,
} SoftAPAuthenticationMode;

typedef enum {
    Pwd_None = 0x00,
    Pwd_Required,
} SoftAPPasswordMode;

@interface ESPProvisionViewController : UIViewController

@property (nonatomic, weak) id<ESPProvisionParamsDelegate> paramsDelegate;

// action from category
- (void)onSubmitForm:(NSDictionary *)formParams;


// shared view properties with catgegory
@property (nonatomic, strong) UIScrollView *scrollview;
@property (nonatomic, strong) UITextField *currentTextfield;

@property (nonatomic, strong) UIView *softapView;
@property (nonatomic, strong) UIView *softapPasswordView;
@property (nonatomic, strong) UIView *wifiView;
@property (nonatomic, strong) UIButton *okBtn;

@property (nonatomic, assign) UIButton *DeviceModeBtn;
@property (nonatomic, assign) UIButton *SoftAPSecurityBtn;
@property (nonatomic, assign) UIButton *SotAPChannelBtn;
@property (nonatomic, assign) UIButton *SoftAPSMax_ConnectBtn;

@property (nonatomic, strong) UITextField *SoftAPSSidTextfield;
@property (nonatomic, strong) UITextField *SoftAPPasswordTextfield;
@property (nonatomic, strong) UITextField *WifiSSidTextfield;
@property (nonatomic, strong) UITextField *WifiPasswordTextfiled;


@end

NS_ASSUME_NONNULL_END
