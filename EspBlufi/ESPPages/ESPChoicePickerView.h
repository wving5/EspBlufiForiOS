//
//  ESPChoicePickerView.h
//  EspBlufi
//
//  Created by fanbaoying on 2020/6/11.
//  Copyright © 2020 espressif. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ESPChoicePickerView;
@protocol ESPChoicePickerDelegate <NSObject>

@optional
- (void)espPickerView:(ESPChoicePickerView *)picker didSelect:(NSString *)str;
- (void)espPickerViewDidCancel:(ESPChoicePickerView *)picker;

@end

typedef NS_ENUM(NSInteger, ARRAYTYPE) {
    GenderArray,
    alldateArray,
    DeteArray,
    Tempmmol_L,
    Tempmg_dL,
    MeasureModeArray,
    tempdate,
    ASICClock,
    OSR,
    ILED,
    GainTrim,
    MeasureInterval,
    Meal,
    Exercise,
    Insulin,
    DeviceMode,
    Security,
    channel,
    max_connection,
};

typedef enum {
    Picker_DeviceMode = 0x00,
    Picker_Security,
    Picker_Channell,
    Picker_Max_Connection,
} PickerType;

@interface ESPChoicePickerView : UIView

@property (nonatomic, assign) PickerType type;

@property (nonatomic, assign) ARRAYTYPE arrayType;

@property (nonatomic, strong) NSArray *customArr;

@property (nonatomic, strong) UILabel *selectLb;

@property (nonatomic, strong) NSMutableArray *dateArray;

@property (nonatomic, assign) id<ESPChoicePickerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
