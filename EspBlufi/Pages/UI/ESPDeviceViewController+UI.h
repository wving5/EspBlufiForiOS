
#import "ESPDeviceViewController.h"

@interface ESPDeviceViewController (UI) <UITableViewDelegate, UITableViewDataSource>

- (void)setupUIWith:(NSString *)deviceName;

- (void)setButton:(UIButton *)button enable:(BOOL)enable;
- (void)setButton:(UIButton *)button touchDown:(BOOL)pressed;

- (void)ui_updateButtonStatesWithActionStates:(ESPDeviceActionStates *)states;

- (void)updateMessage:(NSString *)message;

- (void)showCustomDataAlertWithOKHandler:(void (^)(NSString *inputText))onOK cancelHandler:(void (^)(void))onCancel;

@end
