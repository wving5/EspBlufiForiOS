//
//  ESPPeripheral.h
//  EspBlufi
//
//  Created by AE on 2020/6/15.
//  Copyright © 2020 espressif. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface ESPPeripheral : NSObject

@property(strong, nonatomic)CBPeripheral *peripheral;
@property(strong, nonatomic)NSUUID *uuid;

// 增加
@property(strong, nonatomic)NSString *name;
@property(assign, nonatomic)int rssi;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral;

@end

NS_ASSUME_NONNULL_END
