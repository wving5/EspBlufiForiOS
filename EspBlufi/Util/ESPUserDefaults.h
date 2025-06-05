//
//  ESPUserDefaults.h
//  EspBlufi
//
//  Created by fanbaoying on 2020/6/12.
//  Copyright © 2020 espressif. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ESPUserDefaults : NSObject

+ (void)saveBlufiScanFilter:(NSString *)filter;
+ (NSString *)getBlufiScanFilter;

@end

NS_ASSUME_NONNULL_END
