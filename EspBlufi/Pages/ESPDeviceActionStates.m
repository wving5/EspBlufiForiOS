#import "ESPDeviceActionStates.h"

NSString *ButtonTagToString(ButtonTag tag) {
    switch (tag) {
        case Btn_Connect:
            return @"Btn_Connect";
        case Btn_Disconnect:
            return @"Btn_Disconnect";
        case Btn_Security:
            return @"Btn_Security";
        case Btn_Version:
            return @"Btn_Version";
        case Btn_Configure:
            return @"Btn_Configure";
        case Btn_State:
            return @"Btn_State";
        case Btn_Scan:
            return @"Btn_Scan";
        case Btn_Custom:
            return @"Btn_Custom";
        default:
            return @"Unknown";
    }
}


NSString *ESPActionStateToString(ESPActionState state) {
    switch (state) {
        case ESPActionState_Idle:
            return @"Idle";
        case ESPActionState_InProgress:
            return @"InProgress";
        case ESPActionState_Success:
            return @"Success";
        case ESPActionState_Failed:
            return @"Failed";
        default:
            return @"Unknown";
    }
}



@implementation ESPDeviceActionStates {
    dispatch_queue_t _syncQueue;

    ESPActionState _connect;
    ESPActionState _security;
    ESPActionState _version;
    ESPActionState _configure;
    ESPActionState _state;
    ESPActionState _scan;
    ESPActionState _custom;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _syncQueue = dispatch_queue_create("com.myapp.deviceState.queue", DISPATCH_QUEUE_CONCURRENT);
        _connect = ESPActionState_Idle;
        _security = ESPActionState_Idle;
        _version = ESPActionState_Idle;
        _configure = ESPActionState_Idle;
        _state = ESPActionState_Idle;
        _scan = ESPActionState_Idle;
        _custom = ESPActionState_Idle;
    }
    return self;
}

// Thread-safe getters and setters using dispatch_barrier for writing
- (BOOL)isConnected {
    // computed property for single source of truth
    __block BOOL value;
    dispatch_sync(_syncQueue, ^{
        value = _connect == ESPActionState_Success;
    });
    return value;
}

- (ESPActionState)connect {
    __block ESPActionState value;
    dispatch_sync(_syncQueue, ^{
        value = _connect;
    });
    return value;
}

- (void)setConnect:(ESPActionState)value {
    dispatch_barrier_async(_syncQueue, ^{
        self->_connect = value;
    });
}

- (ESPActionState)security {
    __block ESPActionState value;
    dispatch_sync(_syncQueue, ^{
        value = _security;
    });
    return value;
}

- (void)setSecurity:(ESPActionState)value {
    dispatch_barrier_async(_syncQueue, ^{
        self->_security = value;
    });
}

- (ESPActionState)version {
    __block ESPActionState value;
    dispatch_sync(_syncQueue, ^{
        value = _version;
    });
    return value;
}

- (void)setVersion:(ESPActionState)value {
    dispatch_barrier_async(_syncQueue, ^{
        self->_version = value;
    });
}

- (ESPActionState)configure {
    __block ESPActionState value;
    dispatch_sync(_syncQueue, ^{
        value = _configure;
    });
    return value;
}

- (void)setConfigure:(ESPActionState)value {
    dispatch_barrier_async(_syncQueue, ^{
        self->_configure = value;
    });
}

- (ESPActionState)state {
    __block ESPActionState value;
    dispatch_sync(_syncQueue, ^{
        value = _state;
    });
    return value;
}

- (void)setState:(ESPActionState)value {
    dispatch_barrier_async(_syncQueue, ^{
        self->_state = value;
    });
}

- (ESPActionState)scan {
    __block ESPActionState value;
    dispatch_sync(_syncQueue, ^{
        value = _scan;
    });
    return value;
}

- (void)setScan:(ESPActionState)value {
    dispatch_barrier_async(_syncQueue, ^{
        self->_scan = value;
    });
}

- (ESPActionState)custom {
    __block ESPActionState value;
    dispatch_sync(_syncQueue, ^{
        value = _custom;
    });
    return value;
}

- (void)setCustom:(ESPActionState)value {
    dispatch_barrier_async(_syncQueue, ^{
        self->_custom = value;
    });
}

- (void)reset {
    dispatch_barrier_async(_syncQueue, ^{
        self->_connect = ESPActionState_Idle;
        self->_security = ESPActionState_Idle;
        self->_version = ESPActionState_Idle;
        self->_configure = ESPActionState_Idle;
        self->_state = ESPActionState_Idle;
        self->_scan = ESPActionState_Idle;
        self->_custom = ESPActionState_Idle;
    });
}

- (NSString *)description {
    __block NSString *desc;
    dispatch_sync(_syncQueue, ^{
        BOOL connected = (_connect == ESPActionState_Success);
        desc = [NSString stringWithFormat:@"ActionStates{isConnected:%d, connect:%@, security:%@, version:%@, configure:%@, state:%@, scan:%@, custom:%@, }",
                connected,
                ESPActionStateToString(_connect),
                ESPActionStateToString(_security),
                ESPActionStateToString(_version),
                ESPActionStateToString(_configure),
                ESPActionStateToString(_state),
                ESPActionStateToString(_scan),
                ESPActionStateToString(_custom)
                ];
    });
    return desc;
}

@end
