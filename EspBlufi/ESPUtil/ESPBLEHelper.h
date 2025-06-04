//
//  ESPBLEHelper.h
//  EspBlufi
//
//  Created by fanbaoying on 2020/6/11.
//  Copyright © 2020 espressif. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPPeripheral.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESPBLEHelper : NSObject
typedef void (^bleDeviceScanCallback)(ESPPeripheral *device);

@property (nonatomic, copy) bleDeviceScanCallback onBleScanSuccess;

+ (instancetype)share;

// 停止扫描
- (void)stopScan;
// 开始扫描
- (void)startScan:(bleDeviceScanCallback)device;

@end

NS_ASSUME_NONNULL_END
