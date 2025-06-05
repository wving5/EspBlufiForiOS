//
//  ESPProvisionViewController+UI.m
//  EspBlufi
//
//  Created by Augment Agent on 2024/12/19.
//  Copyright © 2020 espressif. All rights reserved.
//

#import "ESPProvisionViewController+UI.h"
#import "UIWindow+keyWindow.h"

// UI Constants - moved from main class
#define offset    35
#define Height    40
#define labelFont 12

@implementation ESPProvisionViewController (UI)

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = INTER_STR(@"EspBlufi-operation-provision");

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillshow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillhidden:) name:UIKeyboardWillHideNotification object:nil];
    
    [self setupScrollView];
    [self setupDeviceModeSection];
    [self setupSoftAPSection];
    [self setupSoftAPPasswordSection];
    [self setupWiFiSection];
    [self setupConfigurationButton];
    
    self.scrollview.contentSize = CGSizeMake(SCREEN_WIDTH, CGRectGetMaxY(self.okBtn.frame));
    self.scrollview.scrollEnabled = YES;
    
    UITapGestureRecognizer *TapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [self.scrollview addGestureRecognizer:TapRecognizer];
}

- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer {
    [self.scrollview endEditing:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - keyboard handle

- (void)keyboardWillshow:(NSNotification *)notify {
    CGRect keyboardFrame = [notify.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardY = keyboardFrame.origin.y;
    CGFloat TextfieldY = [self.currentTextfield convertRect:self.view.bounds toView:nil].origin.y + Height;
    CGFloat space = keyboardY - TextfieldY;
    if (space < 0) {
        self.scrollview.frame = CGRectMake(0, space - Height - 10, SCREEN_WIDTH, SCREEN_HEIGHT);
    }
}

- (void)keyboardWillhidden:(NSNotification *)notify {
    self.scrollview.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
}

#pragma mark - textField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

// textField 代理
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.currentTextfield = textField;
    return YES;
}

#pragma mark - UX
- (void)showLocationAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"EspBlufi-location-title", nil)
                                                                   message:NSLocalizedString(@"EspBlufi-location-content", nil)
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"EspBlufi-cancel", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *_Nonnull action){
                                                    }];
    UIAlertAction *action2 =
        [UIAlertAction actionWithTitle:NSLocalizedString(@"EspBlufi-set", nil)
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *_Nonnull action) {
                                   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                                                      options:@{}
                                                            completionHandler:nil];
                               }];
    [alert addAction:action1];
    [alert addAction:action2];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)SoftAPpasswordhide {
    self.SoftAPPasswordTextfield.secureTextEntry = !self.SoftAPPasswordTextfield.secureTextEntry;
    UIButton *btn = (UIButton *)self.SoftAPPasswordTextfield.rightView;
    if (self.SoftAPPasswordTextfield.secureTextEntry == YES) {
        [btn setImage:[UIImage imageNamed:@"password"] forState:UIControlStateNormal];
    } else {
        [btn setImage:[UIImage imageNamed:@"nopassword"] forState:UIControlStateNormal];
    }
}
- (void)Wifipasswordhide {
    self.WifiPasswordTextfiled.secureTextEntry = !self.WifiPasswordTextfiled.secureTextEntry;
    UIButton *btn = (UIButton *)self.WifiPasswordTextfiled.rightView;
    if (self.WifiPasswordTextfiled.secureTextEntry == YES) {
        [btn setImage:[UIImage imageNamed:@"password"] forState:UIControlStateNormal];
    } else {
        [btn setImage:[UIImage imageNamed:@"nopassword"] forState:UIControlStateNormal];
    }
}

- (void)deviceModeBtnClick {
    [self.scrollview endEditing:YES];

    ESPChoicePickerView *picker = [[ESPChoicePickerView alloc] initWithFrame:self.view.bounds];
    picker.delegate = self;
    picker.arrayType = DeviceMode;
    picker.type = Picker_DeviceMode;

    UIWindow *currentWindow = [UIWindow keyWindow];
    [currentWindow addSubview:picker];
}

- (void)SoftAPMaxConnectBtnClick {
    [self.scrollview endEditing:YES];

    ESPChoicePickerView *picker = [[ESPChoicePickerView alloc] initWithFrame:self.view.bounds];
    picker.delegate = self;
    picker.arrayType = max_connection;
    picker.type = Picker_Max_Connection;

    UIWindow *currentWindow = [UIWindow keyWindow];
    [currentWindow addSubview:picker];
}

- (void)SoftAPchannelBtnClick {
    [self.scrollview endEditing:YES];

    ESPChoicePickerView *picker = [[ESPChoicePickerView alloc] initWithFrame:self.view.bounds];
    picker.delegate = self;
    picker.arrayType = channel;
    picker.type = Picker_Channell;
    
    UIWindow *currentWindow = [UIWindow keyWindow];
    [currentWindow addSubview:picker];
}

- (void)SoftAPSecurityBtnClick {
    [self.scrollview endEditing:YES];
    
    ESPChoicePickerView *picker = [[ESPChoicePickerView alloc] initWithFrame:self.view.bounds];
    picker.delegate = self;
    picker.arrayType = Security;
    picker.type = Picker_Security;

    UIWindow *currentWindow = [UIWindow keyWindow];
    [currentWindow addSubview:picker];
}

- (void)updateUI_espPickerView:(ESPChoicePickerView *)picker didSelect:(NSString *)str {
    if (picker.type == Picker_DeviceMode) {
        [self.DeviceModeBtn setTitle:str forState:UIControlStateNormal];
    } else if (picker.type == Picker_Security) {
        [self.SoftAPSecurityBtn setTitle:str forState:UIControlStateNormal];
    } else if (picker.type == Picker_Channell) {
        [self.SotAPChannelBtn setTitle:str forState:UIControlStateNormal];
    } else if (picker.type == Picker_Max_Connection) {
        [self.SoftAPSMax_ConnectBtn setTitle:str forState:UIControlStateNormal];
    }
}

- (void)updateUI_setDisplaymode:(OpMode)displaymode
             softapPasswordmode:(SoftAPPasswordMode)softapPasswordmode
                        staSsid:(NSString*) staSsid {
    self.WifiSSidTextfield.text = staSsid;
    
    switch (displaymode) {
        case OpModeNull: {
            self.softapView.frame = CGRectMake(0, CGRectGetMaxY(self.DeviceModeBtn.frame), [UIScreen mainScreen].bounds.size.width, 0);
            self.softapView.hidden = YES;
            
            self.softapPasswordView.frame = CGRectMake(0, CGRectGetMaxY(self.softapView.frame), [UIScreen mainScreen].bounds.size.width, 0);
            self.softapPasswordView.hidden = YES;
            self.wifiView.frame = CGRectMake(0, CGRectGetMaxY(self.softapPasswordView.frame), [UIScreen mainScreen].bounds.size.width, 0);
            self.wifiView.hidden = YES;
            
            self.okBtn.frame = CGRectMake(self.okBtn.frame.origin.x, CGRectGetMaxY(self.wifiView.frame) + offset, self.okBtn.bounds.size.width,
                                          self.okBtn.bounds.size.height);
            self.scrollview.contentSize = CGSizeMake(SCREEN_WIDTH, CGRectGetMaxY(self.okBtn.frame) + 100);
        }
            break;
        case OpModeSta: {
            self.softapView.frame = CGRectMake(0, CGRectGetMaxY(self.DeviceModeBtn.frame), [UIScreen mainScreen].bounds.size.width, 0);
            self.softapView.hidden = YES;

            self.softapPasswordView.frame = CGRectMake(0, CGRectGetMaxY(self.softapView.frame), [UIScreen mainScreen].bounds.size.width, 0);
            self.softapPasswordView.hidden = YES;

            self.wifiView.frame =
                CGRectMake(0, CGRectGetMaxY(self.softapPasswordView.frame), [UIScreen mainScreen].bounds.size.width, Height * 2 + offset * 2);
            self.wifiView.hidden = NO;

            self.okBtn.frame = CGRectMake(self.okBtn.frame.origin.x, CGRectGetMaxY(self.wifiView.frame) + offset, self.okBtn.bounds.size.width,
                                          self.okBtn.bounds.size.height);
            self.scrollview.contentSize = CGSizeMake(SCREEN_WIDTH, CGRectGetMaxY(self.okBtn.frame) + 100);
        }
            break;
        case OpModeSoftAP: {
            self.softapView.frame =
                CGRectMake(0, CGRectGetMaxY(self.DeviceModeBtn.frame), [UIScreen mainScreen].bounds.size.width, Height * 4 + offset * 4);
            self.softapView.hidden = NO;

            if (softapPasswordmode == Pwd_None) {
                self.softapPasswordView.frame = CGRectMake(0, CGRectGetMaxY(self.softapView.frame), SCREEN_WIDTH, 0);
                self.softapPasswordView.hidden = YES;
            } else {
                self.softapPasswordView.frame = CGRectMake(0, CGRectGetMaxY(self.softapView.frame), SCREEN_WIDTH, Height + offset);
                self.softapPasswordView.hidden = NO;
            }
            self.wifiView.frame = CGRectMake(0, CGRectGetMaxY(self.softapPasswordView.frame), [UIScreen mainScreen].bounds.size.width, 0);
            self.wifiView.hidden = YES;

            self.okBtn.frame = CGRectMake(self.okBtn.frame.origin.x, CGRectGetMaxY(self.wifiView.frame) + offset, self.okBtn.bounds.size.width,
                                          self.okBtn.bounds.size.height);
            self.scrollview.contentSize = CGSizeMake(SCREEN_WIDTH, CGRectGetMaxY(self.okBtn.frame) + 100);
        }
            break;
        case OpModeStaSoftAP: {
            self.softapView.frame =
                CGRectMake(0, CGRectGetMaxY(self.DeviceModeBtn.frame), [UIScreen mainScreen].bounds.size.width, Height * 4 + offset * 4);
            self.softapView.hidden = NO;

            if (softapPasswordmode == Pwd_None) {
                self.softapPasswordView.frame = CGRectMake(0, CGRectGetMaxY(self.softapView.frame), SCREEN_WIDTH, 0);
                self.softapPasswordView.hidden = YES;
            } else {
                self.softapPasswordView.frame = CGRectMake(0, CGRectGetMaxY(self.softapView.frame), SCREEN_WIDTH, Height + offset);
                self.softapPasswordView.hidden = NO;
            }
            self.wifiView.frame =
                CGRectMake(0, CGRectGetMaxY(self.softapPasswordView.frame), [UIScreen mainScreen].bounds.size.width, Height * 2 + offset * 2);
            self.wifiView.hidden = NO;

            self.okBtn.frame = CGRectMake(self.okBtn.frame.origin.x, CGRectGetMaxY(self.wifiView.frame) + offset, self.okBtn.bounds.size.width,
                                          self.okBtn.bounds.size.height);
            self.scrollview.contentSize = CGSizeMake(SCREEN_WIDTH, CGRectGetMaxY(self.okBtn.frame) + 100);

        }
            break;

        default:
            break;
    }
}

#pragma mark - setupUI
- (void)setupScrollView {
    UIScrollView *scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view addSubview:scrollview];
    self.scrollview = scrollview;
}

- (void)setupDeviceModeSection {
    CGFloat leftmargin = 10;
    CGFloat labelW = 120;
    CGFloat buttonW = [UIScreen mainScreen].bounds.size.width - labelW - leftmargin * 2;
    
    // device mode label
    UILabel *DeviceModeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, offset, labelW, Height)];
    DeviceModeLabel.textAlignment = NSTextAlignmentCenter;
    DeviceModeLabel.text = INTER_STR(@"EspBlufi-configure-opmode");
    DeviceModeLabel.textColor = APPTITLECOLOR;
    [self.scrollview addSubview:DeviceModeLabel];

    // device mode button
    UIButton *DeviceModeBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(DeviceModeLabel.frame) + leftmargin, offset, buttonW, Height)];
    [DeviceModeBtn setTitle:@"NULL" forState:UIControlStateNormal];
    DeviceModeBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    DeviceModeBtn.layer.cornerRadius = DeviceModeBtn.bounds.size.height / 2;
    DeviceModeBtn.layer.masksToBounds = YES;
    DeviceModeBtn.backgroundColor = UICOLOR_RGBA(239, 239, 239, 1);
    [DeviceModeBtn setTitleColor:navColor forState:UIControlStateNormal];
    [DeviceModeBtn addTarget:self action:@selector(deviceModeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.DeviceModeBtn = DeviceModeBtn;
    [self.scrollview addSubview:DeviceModeBtn];
}

- (void)setupSoftAPSection {
    CGFloat leftmargin = 10;
    CGFloat labelW = 120;
    CGFloat buttonW = [UIScreen mainScreen].bounds.size.width - labelW - leftmargin * 2;
    
    // softAPView container
    UIView *softAPView = [[UIView alloc]
        initWithFrame:CGRectMake(0, CGRectGetMaxY(self.DeviceModeBtn.frame), [UIScreen mainScreen].bounds.size.width, Height * 4 + offset * 4)];
    [self.scrollview addSubview:softAPView];
    self.softapView = softAPView;

    // SoftAP Security
    UILabel *SoftAPSecurityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, offset, labelW, Height)];
    SoftAPSecurityLabel.textAlignment = NSTextAlignmentCenter;
    SoftAPSecurityLabel.text = INTER_STR(@"EspBlufi-configure-security");
    SoftAPSecurityLabel.textColor = APPTITLECOLOR;
    [softAPView addSubview:SoftAPSecurityLabel];

    UIButton *SoftAPSecurityBtn = [[UIButton alloc]
        initWithFrame:CGRectMake(CGRectGetMaxX(SoftAPSecurityLabel.frame) + leftmargin, CGRectGetMinY(SoftAPSecurityLabel.frame), buttonW, Height)];
    [SoftAPSecurityBtn setTitle:@"OPEN" forState:UIControlStateNormal];
    SoftAPSecurityBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    SoftAPSecurityBtn.layer.cornerRadius = self.DeviceModeBtn.bounds.size.height / 2;
    SoftAPSecurityBtn.layer.masksToBounds = YES;
    SoftAPSecurityBtn.backgroundColor = UICOLOR_RGBA(239, 239, 239, 1);
    [SoftAPSecurityBtn setTitleColor:navColor forState:UIControlStateNormal];
    [SoftAPSecurityBtn addTarget:self action:@selector(SoftAPSecurityBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.SoftAPSecurityBtn = SoftAPSecurityBtn;
    [softAPView addSubview:SoftAPSecurityBtn];

    // SoftAP channel
    UILabel *SoftAPChannelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(SoftAPSecurityLabel.frame) + offset, labelW, Height)];
    SoftAPChannelLabel.textAlignment = NSTextAlignmentCenter;
    SoftAPChannelLabel.text = INTER_STR(@"EspBlufi-configure-channel");
    SoftAPChannelLabel.textColor = APPTITLECOLOR;
    [softAPView addSubview:SoftAPChannelLabel];

    UIButton *SoftAPchannelBtn = [[UIButton alloc]
        initWithFrame:CGRectMake(CGRectGetMaxX(SoftAPChannelLabel.frame) + leftmargin, CGRectGetMinY(SoftAPChannelLabel.frame), buttonW, Height)];
    [SoftAPchannelBtn setTitle:@"1" forState:UIControlStateNormal];
    SoftAPchannelBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    SoftAPchannelBtn.layer.cornerRadius = self.DeviceModeBtn.bounds.size.height / 2;
    SoftAPchannelBtn.layer.masksToBounds = YES;
    SoftAPchannelBtn.backgroundColor = UICOLOR_RGBA(239, 239, 239, 1);
    [SoftAPchannelBtn setTitleColor:navColor forState:UIControlStateNormal];
    [SoftAPchannelBtn addTarget:self action:@selector(SoftAPchannelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.SotAPChannelBtn = SoftAPchannelBtn;
    [softAPView addSubview:SoftAPchannelBtn];

    // SoftAP max connection
    UILabel *SoftAPMaxConnectLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(SoftAPChannelLabel.frame) + offset, labelW, Height)];
    SoftAPMaxConnectLabel.textAlignment = NSTextAlignmentCenter;
    SoftAPMaxConnectLabel.text = INTER_STR(@"EspBlufi-configure-max-connect");
    [softAPView addSubview:SoftAPMaxConnectLabel];
    SoftAPMaxConnectLabel.textColor = APPTITLECOLOR;

    UIButton *SoftAPMaxConnectBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(SoftAPMaxConnectLabel.frame) + leftmargin,
                                                                               CGRectGetMinY(SoftAPMaxConnectLabel.frame), buttonW, Height)];
    [SoftAPMaxConnectBtn setTitle:@"1" forState:UIControlStateNormal];
    SoftAPMaxConnectBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    SoftAPMaxConnectBtn.layer.cornerRadius = self.DeviceModeBtn.bounds.size.height / 2;
    SoftAPMaxConnectBtn.layer.masksToBounds = YES;
    SoftAPMaxConnectBtn.backgroundColor = UICOLOR_RGBA(239, 239, 239, 1);
    [SoftAPMaxConnectBtn setTitleColor:navColor forState:UIControlStateNormal];
    [SoftAPMaxConnectBtn addTarget:self action:@selector(SoftAPMaxConnectBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.SoftAPSMax_ConnectBtn = SoftAPMaxConnectBtn;
    [softAPView addSubview:SoftAPMaxConnectBtn];

    // softAP ssid
    UITextField *SoftAPSsidTextfield = [[UITextField alloc]
        initWithFrame:CGRectMake(leftmargin, CGRectGetMaxY(SoftAPMaxConnectBtn.frame) + offset, SCREEN_WIDTH - 2 * leftmargin, Height)];
    SoftAPSsidTextfield.placeholder = INTER_STR(@"EspBlufi-configure-softap-ssid");
    SoftAPSsidTextfield.borderStyle = UITextBorderStyleNone;
    [softAPView addSubview:SoftAPSsidTextfield];
    SoftAPSsidTextfield.delegate = self;
    SoftAPSsidTextfield.returnKeyType = UIReturnKeyDone;
    SoftAPSsidTextfield.textColor = APPTITLECOLOR;
    self.SoftAPSSidTextfield = SoftAPSsidTextfield;

    UIView *line =
        [[UIView alloc] initWithFrame:CGRectMake(0, self.SoftAPSSidTextfield.frame.size.height - 2, self.SoftAPSSidTextfield.frame.size.width, 1)];
    line.backgroundColor = [UIColor lightGrayColor];
    [self.SoftAPSSidTextfield addSubview:line];

    // SoftAP SSID label
    UILabel *SoftAPssidlabel = [[UILabel alloc] initWithFrame:CGRectMake(leftmargin, CGRectGetMinY(SoftAPSsidTextfield.frame) - 20, 150, 20)];
    SoftAPssidlabel.font = [UIFont systemFontOfSize:labelFont];
    SoftAPssidlabel.textColor = APPTITLECOLOR;
    SoftAPssidlabel.text = INTER_STR(@"EspBlufi-configure-softap-ssid");
    [self.softapView addSubview:SoftAPssidlabel];
}

- (void)setupSoftAPPasswordSection {
    CGFloat leftmargin = 10;

    UIView *softapPasswordView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.softapView.frame), SCREEN_WIDTH, Height + offset)];
    [self.scrollview addSubview:softapPasswordView];
    self.softapPasswordView = softapPasswordView;

    // softAP password
    UITextField *SoftAPPasswordTextfield = [[UITextField alloc] initWithFrame:CGRectMake(leftmargin, offset, SCREEN_WIDTH - 2 * leftmargin, Height)];
    SoftAPPasswordTextfield.placeholder = INTER_STR(@"EspBlufi-configure-softap-password");
    SoftAPPasswordTextfield.borderStyle = UITextBorderStyleNone;
    [softapPasswordView addSubview:SoftAPPasswordTextfield];
    SoftAPPasswordTextfield.delegate = self;
    SoftAPPasswordTextfield.returnKeyType = UIReturnKeyDone;
    SoftAPPasswordTextfield.secureTextEntry = YES;
    SoftAPPasswordTextfield.textColor = APPTITLECOLOR;

    // password visibility button
    UIButton *SoftAPbutton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, Height, Height)];
    [SoftAPbutton addTarget:self action:@selector(SoftAPpasswordhide) forControlEvents:UIControlEventTouchUpInside];
    [SoftAPbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [SoftAPbutton setImage:[UIImage imageNamed:@"password.png"] forState:UIControlStateNormal];
    SoftAPPasswordTextfield.rightView = SoftAPbutton;
    SoftAPPasswordTextfield.rightViewMode = UITextFieldViewModeAlways;
    self.SoftAPPasswordTextfield = SoftAPPasswordTextfield;

    // underline
    UIView *SoftAPPasswordline = [[UIView alloc]
        initWithFrame:CGRectMake(0, self.SoftAPPasswordTextfield.frame.size.height - 2, self.SoftAPPasswordTextfield.frame.size.width, 1)];
    SoftAPPasswordline.backgroundColor = [UIColor lightGrayColor];
    [self.SoftAPPasswordTextfield addSubview:SoftAPPasswordline];

    // password label
    UILabel *SoftAPpasswordlabel = [[UILabel alloc] initWithFrame:CGRectMake(leftmargin, CGRectGetMinY(SoftAPPasswordTextfield.frame) - 20, 150, 20)];
    SoftAPpasswordlabel.font = [UIFont systemFontOfSize:labelFont];
    SoftAPpasswordlabel.textColor = APPTITLECOLOR;
    SoftAPpasswordlabel.text = INTER_STR(@"EspBlufi-configure-softap-password");
    [self.softapPasswordView addSubview:SoftAPpasswordlabel];
}

- (void)setupWiFiSection {
    CGFloat leftmargin = 10;

    // Wifi container
    UIView *wifiView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.softapPasswordView.frame), SCREEN_WIDTH, Height * 2 + offset * 2)];
    [self.scrollview addSubview:wifiView];
    self.wifiView = wifiView;

    // Wifi ssid
    UITextField *WifiSsidTextfield = [[UITextField alloc] initWithFrame:CGRectMake(leftmargin, offset, SCREEN_WIDTH - 2 * leftmargin, Height)];
    WifiSsidTextfield.placeholder = INTER_STR(@"EspBlufi-configure-station-ssid");
    WifiSsidTextfield.borderStyle = UITextBorderStyleNone;
    [wifiView addSubview:WifiSsidTextfield];
    WifiSsidTextfield.delegate = self;
    WifiSsidTextfield.returnKeyType = UIReturnKeyDone;
    WifiSsidTextfield.textColor = APPTITLECOLOR;
    self.WifiSSidTextfield = WifiSsidTextfield;

    // WiFi SSID underline
    UIView *WifiSsidline =
        [[UIView alloc] initWithFrame:CGRectMake(0, self.WifiSSidTextfield.frame.size.height - 2, self.WifiSSidTextfield.frame.size.width, 1)];
    WifiSsidline.backgroundColor = [UIColor lightGrayColor];
    [self.WifiSSidTextfield addSubview:WifiSsidline];

    // WiFi SSID label
    UILabel *wifissidlabel = [[UILabel alloc] initWithFrame:CGRectMake(leftmargin, CGRectGetMinY(WifiSsidTextfield.frame) - 20, 150, 20)];
    wifissidlabel.font = [UIFont systemFontOfSize:labelFont];
    wifissidlabel.textColor = APPTITLECOLOR;
    wifissidlabel.text = INTER_STR(@"EspBlufi-configure-station-ssid");
    [self.wifiView addSubview:wifissidlabel];

    // wifi password
    UITextField *WifiPasswordTextfiled =
        [[UITextField alloc] initWithFrame:CGRectMake(leftmargin, CGRectGetMaxY(WifiSsidTextfield.frame) + offset,
                                                      [UIScreen mainScreen].bounds.size.width - 2 * leftmargin, Height)];
    WifiPasswordTextfiled.placeholder = INTER_STR(@"EspBlufi-configure-station-password");
    WifiPasswordTextfiled.borderStyle = UITextBorderStyleNone;
    [wifiView addSubview:WifiPasswordTextfiled];
    WifiPasswordTextfiled.delegate = self;
    WifiPasswordTextfiled.returnKeyType = UIReturnKeyDone;
    self.WifiPasswordTextfiled = WifiPasswordTextfiled;
    WifiPasswordTextfiled.returnKeyType = UIReturnKeyDone;
    WifiPasswordTextfiled.secureTextEntry = YES;

    // WiFi password visibility button
    UIButton *Wifibutton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, Height, Height)];
    Wifibutton.tag = 1;
    [Wifibutton addTarget:self action:@selector(Wifipasswordhide) forControlEvents:UIControlEventTouchUpInside];
    [Wifibutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [Wifibutton setImage:[UIImage imageNamed:@"password"] forState:UIControlStateNormal];
    WifiPasswordTextfiled.rightView = Wifibutton;
    WifiPasswordTextfiled.rightViewMode = UITextFieldViewModeAlways;

    // WiFi password underline
    UIView *WifiPasswordline = [[UIView alloc]
        initWithFrame:CGRectMake(0, self.WifiPasswordTextfiled.frame.size.height - 2, self.WifiPasswordTextfiled.frame.size.width, 1)];
    WifiPasswordline.backgroundColor = [UIColor lightGrayColor];
    [self.WifiPasswordTextfiled addSubview:WifiPasswordline];

    // WiFi password label
    UILabel *wifipasswordlabel = [[UILabel alloc] initWithFrame:CGRectMake(leftmargin, CGRectGetMinY(WifiPasswordTextfiled.frame) - 20, 150, 20)];
    wifipasswordlabel.font = [UIFont systemFontOfSize:labelFont];
    wifipasswordlabel.textColor = APPTITLECOLOR;
    wifipasswordlabel.text = INTER_STR(@"EspBlufi-configure-station-password");
    [self.wifiView addSubview:wifipasswordlabel];
}

- (void)setupConfigurationButton {
    CGFloat buttonW = [UIScreen mainScreen].bounds.size.width - 120 - 20; // labelW + leftmargin * 2

    // Configuration button
    UIButton *btn = [[UIButton alloc]
        initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - buttonW) / 2, CGRectGetMaxY(self.wifiView.frame) + offset, buttonW, Height)];
    btn.backgroundColor = navColor;
    [btn setTitle:INTER_STR(@"EspBlufi-configure") forState:UIControlStateNormal];
    btn.layer.cornerRadius = btn.bounds.size.height / 2;
    btn.layer.masksToBounds = YES;
    [btn addTarget:self action:@selector(okBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollview addSubview:btn];
    self.okBtn = btn;
}

- (void)okBtnClick {
    [self onSubmitForm: @{
        @"staSsid" :  self.WifiSSidTextfield.text,
        @"staPassword" :  self.WifiPasswordTextfiled.text,
        @"softApSsid" :  self.SoftAPSSidTextfield.text,
        @"softApPassword" :  self.SoftAPPasswordTextfield.text,
    }];
}

@end
