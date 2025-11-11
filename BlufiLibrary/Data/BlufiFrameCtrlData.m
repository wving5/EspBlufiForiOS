//
//  BlufiFrameCtrlData.m
//  EspBlufi
//
//  Created by AE on 2020/6/9.
//  Copyright © 2020 espressif. All rights reserved.
//

#import "BlufiFrameCtrlData.h"

@interface BlufiFrameCtrlData ()

@property (assign, nonatomic, ) Byte value;

@end

@implementation BlufiFrameCtrlData

/// Frame Control
/// 帧控制字段，占 1 字节，每个位表示不同含义
/// 这里 0 表示最低字节位
enum {
    PositionEncrypted = 0, // 帧是否加密
    PositionChecksum, // 帧尾是否包含校验位
    PositionDataDirection, // 数据方向。0 表示传输方向是从手机到 ESP 设备。1 表示传输方向是从 ESP 设备到手机。
    PositionRequireAck, // 是否要求对方回复 ACK。
    PositionFrag, // 是否有后续的数据分片。
};

- (instancetype)initWithValue:(Byte)value {
    self = [super init];
    if (self) {
        _value = value;
    }
    return self;
}

- (BOOL)check:(uint32_t)position {
    return (_value >> position & 1) == 1;
}

- (BOOL)isEncrypted {
    return [self check:PositionEncrypted];
}

- (BOOL)isChecksum {
    return [self check:PositionChecksum];
}

- (BOOL)isAckRequirement {
    return [self check:PositionRequireAck];
}

- (BOOL)hasFrag {
    return [self check:PositionFrag];
}

+ (Byte)getFrameCtrlValueWithEncrypted:(BOOL)encrypted
                              checksum:(BOOL)checksum
                             direction:(DataDirection)direction
                            requireAck:(BOOL)ack
                               hasFrag:(BOOL)frag {
    Byte frame = 0;
    if (encrypted) {
        frame |= (1 << PositionEncrypted);
    }
    if (checksum) {
        frame |= (1 << PositionChecksum);
    }
    if (direction == DataInput) {
        frame |= (1 << PositionDataDirection);
    }
    if (ack) {
        frame |= (1 << PositionRequireAck);
    }
    if (frag) {
        frame |= (1 << PositionFrag);
    }
    return frame;
}

@end
