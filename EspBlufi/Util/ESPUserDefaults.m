//
//  ESPUserDefaults.m
//  EspBlufi
//
//  Created by fanbaoying on 2020/6/12.
//  Copyright © 2020 espressif. All rights reserved.
//

#import "ESPUserDefaults.h"

#define SettingsFilter  @"filterContent"
#define DefaultFilter   @"BLUFI"

@implementation ESPUserDefaults

+ (void)saveBlufiScanFilter:(NSString *)filter {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:filter forKey:SettingsFilter];
    [defaults synchronize];
}

+ (NSString *)getBlufiScanFilter {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* filter = [defaults objectForKey:SettingsFilter];
    DLog(@"getBlufiScanFilter %@", filter);

    if (![filter isKindOfClass: NSString.class] || !filter.length) {
        return DefaultFilter;
    }
    return filter;
}

@end
