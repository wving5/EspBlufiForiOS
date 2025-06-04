//
//  ESPDetailViewController+UI.m
//  EspBlufi
//
//  Created by cty on 2025/6/4.
//  Copyright © 2025 espressif. All rights reserved.
//

#import "ESPDetailViewController+UI.h"

@implementation ESPDetailViewController (UI)

- (void)setupUIWith:(NSString *)deviceName {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = deviceName;

    [self setupMessageTableView];
    [self setupOperationButtons];
}

#pragma mark - UI Setup Methods

- (void)setupMessageTableView {
    self.messageView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 130)];
    self.messageView.backgroundColor = [UIColor colorWithRed:80 / 255.0 green:80 / 255.0 blue:80 / 255.0 alpha:1.0];
    self.messageArray = [[NSMutableArray alloc] init];
    self.messageView.delegate = self;
    self.messageView.dataSource = self;
    [self.view addSubview:self.messageView];
}

- (void)setupOperationButtons {
    UIView *operationView = [self createOperationView];
    [self.view addSubview:operationView];

    NSArray *buttonConfigs = [self createButtonConfigurations];
    [self createButtonsInView:operationView withConfigurations:buttonConfigs];
}

- (UIView *)createOperationView {
    UIView *operationView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 120, SCREEN_WIDTH, 100)];
    return operationView;
}

- (NSArray *)createButtonConfigurations {
    return @[
        @{@"title" : INTER_STR(@"EspBlufi-operation-connect"), @"tag" : @(Btn_Connect)},
        @{@"title" : INTER_STR(@"EspBlufi-operation-disConnect"), @"tag" : @(Btn_Disconnect)},
        @{@"title" : INTER_STR(@"EspBlufi-operation-encryption"), @"tag" : @(Btn_Security)},
        @{@"title" : INTER_STR(@"EspBlufi-operation-version"), @"tag" : @(Btn_Version)},
        @{@"title" : INTER_STR(@"EspBlufi-operation-provision"), @"tag" : @(Btn_Configure)},
        @{@"title" : INTER_STR(@"EspBlufi-operation-state"), @"tag" : @(Btn_State)},
        @{@"title" : INTER_STR(@"EspBlufi-operation-scan"), @"tag" : @(Btn_Scan)},
        @{@"title" : INTER_STR(@"EspBlufi-operation-custom"), @"tag" : @(Btn_Custom)}
    ];
}

- (void)createButtonsInView:(UIView *)containerView withConfigurations:(NSArray *)configs {
    const CGFloat buttonMargin = 5.0;
    const CGFloat buttonHeight = 40.0;
    const CGFloat buttonsPerRow = 4;
    const CGFloat buttonWidth = (SCREEN_WIDTH - (buttonMargin * (buttonsPerRow + 1))) / buttonsPerRow;

    for (NSInteger i = 0; i < configs.count; i++) {
        NSDictionary *config = configs[i];
        UIButton *button = [self createButtonWithConfiguration:config
                                                       atIndex:i
                                                   buttonWidth:buttonWidth
                                                  buttonHeight:buttonHeight
                                                  buttonMargin:buttonMargin];
        [self assignButtonToProperty:button withTag:[config[@"tag"] integerValue]];
        [containerView addSubview:button];
    }
}

- (UIButton *)createButtonWithConfiguration:(NSDictionary *)config
                                    atIndex:(NSInteger)index
                                buttonWidth:(CGFloat)buttonWidth
                               buttonHeight:(CGFloat)buttonHeight
                               buttonMargin:(CGFloat)buttonMargin {
    // Calculate position
    NSInteger row = index / 4;
    NSInteger col = index % 4;
    CGFloat x = buttonMargin + col * (buttonWidth + buttonMargin);
    CGFloat y = buttonMargin + row * (buttonHeight + buttonMargin);

    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, y, buttonWidth, buttonHeight)];
    [button setTitle:config[@"title"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    button.tag = [config[@"tag"] integerValue];

    [self configureButtonAppearance:button];
    [self addButtonTargets:button];

    // Only connect button is enabled initially
    BOOL shouldEnable = (button.tag == Btn_Connect);
    [self setButton:button enable:shouldEnable];

    return button;
}

- (void)configureButtonAppearance:(UIButton *)button {
    button.layer.cornerRadius = 5.0;
    button.clipsToBounds = YES;
}

- (void)addButtonTargets:(UIButton *)button {
    [button addTarget:self action:@selector(onButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(onButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(onButtonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
}

- (void)assignButtonToProperty:(UIButton *)button withTag:(NSInteger)tag {
    switch (tag) {
        case Btn_Connect:
            self.connectBtn = button;
            break;
        case Btn_Disconnect:
            self.disconnectBtn = button;
            break;
        case Btn_Security:
            self.encryptionBtn = button;
            break;
        case Btn_Version:
            self.versionBtn = button;
            break;
        case Btn_Configure:
            self.configureBtn = button;
            break;
        case Btn_State:
            self.stateBtn = button;
            break;
        case Btn_Scan:
            self.scanBtn = button;
            break;
        case Btn_Custom:
            self.customBtn = button;
            break;
        default:
            break;
    }
}

#pragma mark - Button State Management

- (void)setButton:(UIButton *)button enable:(BOOL)enable {
    if (enable) {
        button.userInteractionEnabled = YES;
        button.backgroundColor = navColor;
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        button.userInteractionEnabled = NO;
        button.backgroundColor = UICOLOR_RGBA(221, 221, 221, 1);
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
}

- (void)setButton:(UIButton *)button touchDown:(BOOL)pressed {
    if (!button.userInteractionEnabled) {
        button.backgroundColor = UICOLOR_RGBA(221, 221, 221, 1);
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    } else {
        if (pressed) {
            button.backgroundColor = UICOLOR_RGBA(200, 40, 80, 1);
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        } else {
            button.backgroundColor = navColor;
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
}

- (void)updateAllButtonsForConnectionState:(BOOL)connected {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self setButton:self.connectBtn enable:!connected];
        [self setButton:self.disconnectBtn enable:connected];
        [self setButton:self.encryptionBtn enable:connected];
        [self setButton:self.versionBtn enable:connected];
        [self setButton:self.configureBtn enable:connected];
        [self setButton:self.stateBtn enable:connected];
        [self setButton:self.scanBtn enable:connected];
        [self setButton:self.customBtn enable:connected];
    }];
}

- (void)showCustomDataAlertWithOKHandler:(void (^)(NSString *inputText))onOK cancelHandler:(void (^)(void))onCancel {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:INTER_STR(@"EspBlufi-custom-data")
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:INTER_STR(@"cancel")
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                          if (onCancel) {
                                                              onCancel();
                                                          }
                                                      }]];

    [alertController addAction:[UIAlertAction actionWithTitle:INTER_STR(@"ok")
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                          UITextField *filterTextfield = alertController.textFields.firstObject;
                                                          NSString *text = filterTextfield.text;
                                                          if (onOK) {
                                                              onOK(text);
                                                          }
                                                      }]];

    [alertController addTextFieldWithConfigurationHandler:^(UITextField *_Nonnull textField) {
        textField.placeholder = INTER_STR(@"EspBlufi-custom-data-hint");
    }];

    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Button Actions

- (void)onButtonTouchDown:(UIButton *)sender {
    [self setButton:sender touchDown:YES];
}

- (void)onButtonTouchUpOutside:(UIButton *)sender {
    [self setButton:sender touchDown:NO];
}

- (void)onButtonTouchUpInside:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self setButton:sender touchDown:NO];

    // Callback to main view controller with the button tag
    [self onButtonAction:(ButtonTag)sender.tag];
}

#pragma mark - UITableView DataSource & Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    if (!ValidArray(self.messageArray)) {
        return cell;
    }

    NSString *message = self.messageArray[indexPath.row];
    cell.textLabel.text = message;
    cell.textLabel.numberOfLines = 0;
    return cell;
}

#pragma mark - Message Management

- (void)updateMessage:(NSString *)message {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.messageArray addObject:message];
        NSArray *insertIndexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.messageArray.count - 1 inSection:0]];
        [self.messageView beginUpdates];
        [self.messageView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationNone];
        [self.messageView endUpdates];
        [self.messageView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageArray.count - 1 inSection:0]
                                atScrollPosition:UITableViewScrollPositionTop
                                        animated:YES];
    }];
}

@end
