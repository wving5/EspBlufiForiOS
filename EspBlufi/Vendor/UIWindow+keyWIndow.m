//
//  UIWindow+keyWIndow.m
//  EspBlufi
//
//  Created by cty on 2025/6/4.
//  Copyright © 2025 espressif. All rights reserved.
//

#import "UIWindow+keyWIndow.h"

#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@implementation UIWindow (keyWIndow)
+ (UIWindow *)esp_keyWindow {
    return [UIApplication sharedApplication].keyWindow;
}
@end
