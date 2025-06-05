//
//  ESPUserDefaults.m
//  EspBlufi
//
//  Created by fanbaoying on 2020/6/12.
//  Copyright © 2020 espressif. All rights reserved.
//

#import "ESPUserDefaults.h"

#define SettingsFilter  @"filterContent"
#define UseCustomFilter @"useCustomFilter"
#define DefaultFilter   @"BLUFI"

@implementation ESPUserDefaults

/**
 *  Defaults保存
 *
 *  @param value   要保存的数据
 *  @param key   关键字
 *  @return 保存结果
 */
+ (BOOL)saveNSUserDefaults:(id)value withKey:(NSString *)key {
    if ((!value) || (!key) || key.length == 0) {
        DLog(@"参数不能为空");
        return NO;
    }
    if (!([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSArray class]] ||
          [value isKindOfClass:[NSDictionary class]])) {
        DLog(@"参数格式不对");
        return NO;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:value forKey:key];
    [defaults synchronize];
    return YES;
}

/**
 *  Defaults取出
 *
 *  @param key     关键字
 *  return  返回已保存的数据
 */
+ (id)getNSUserDefaults:(NSString *)key {
    if (key == nil || key.length == 0) {
        DLog(@"参数不能为空");
        return nil;
    }

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:key];
}

+ (BOOL)saveBlufiScanFilter:(NSString *)filter {
    if (![self saveNSUserDefaults:filter withKey:SettingsFilter]) {
        return NO;
    }
    [self saveNSUserDefaults:@YES withKey:UseCustomFilter];
    return YES;
}

+ (NSString *)getBlufiScanFilter {
    id custom = [self getNSUserDefaults:UseCustomFilter];
    DLog(@"getBlufiScanFilter %@", custom);

    if (!custom || ![custom boolValue]) {
        return DefaultFilter;
    }
    return [self getNSUserDefaults:SettingsFilter];
}

@end
