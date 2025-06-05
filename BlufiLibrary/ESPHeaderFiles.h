//
//  ESPHeaderFiles.h
//  EspBlufi
//
//  Created by fanbaoying on 2020/6/24.
//  Copyright © 2020 espressif. All rights reserved.
//

#ifndef ESPHeaderFiles_h
#define ESPHeaderFiles_h

#define BluefiLog(fmt, ...) NSLog((@"[Bluefi] " fmt),  ##__VA_ARGS__)
//#define BluefiLog(fmt, ...)

#import <openssl/dh.h>
#import <CommonCrypto/CommonCrypto.h>
#import <openssl/rsa.h>
#import <openssl/pem.h>
#import <openssl/dh.h>
#import <openssl/bn.h>

#endif /* ESPHeaderFiles_h */
