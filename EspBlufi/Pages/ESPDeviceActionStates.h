#import <Foundation/Foundation.h>


typedef enum {
    Btn_Connect = 6000,
    Btn_Disconnect,
    Btn_Security,
    Btn_Version,
    Btn_Configure,
    Btn_State,
    Btn_Scan,
    Btn_Custom,
} ButtonTag;

NSString *ButtonTagToString(ButtonTag tag);

typedef enum {
    ESPActionState_Idle = 0,
    ESPActionState_InProgress = 11, // just for test purpose
    ESPActionState_Success = 2,
    ESPActionState_Failed = 3
} ESPActionState;

NSString *ESPActionStateToString(ESPActionState state); 

// Thread-safe state management
@interface ESPDeviceActionStates : NSObject

// Thread-safe property accessors
@property (nonatomic, assign) ESPActionState connect;
@property (nonatomic, assign) ESPActionState security;
@property (nonatomic, assign) ESPActionState version;
@property (nonatomic, assign) ESPActionState configure;
@property (nonatomic, assign) ESPActionState state;
@property (nonatomic, assign) ESPActionState scan;
@property (nonatomic, assign) ESPActionState custom;
@property (nonatomic, assign, readonly) BOOL isConnected;

- (instancetype)init;
- (void)reset;
- (NSString *)description;

@end
