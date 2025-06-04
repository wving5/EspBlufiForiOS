
#import "ESPDetailViewController.h"

@interface ESPDetailViewController (UI) <UITableViewDelegate, UITableViewDataSource>

- (void)setupUI;

- (void)setButton:(UIButton *)button enable:(BOOL)enable;
- (void)setButton:(UIButton *)button touchDown:(BOOL)pressed;
- (void)updateAllButtonsForConnectionState:(BOOL)connected;

- (void)updateMessage:(NSString *)message;

- (void)showCustomDataAlertWithOKHandler:(void(^)(NSString *inputText))onOK
                           cancelHandler:(void(^)(void))onCancel;

@end
