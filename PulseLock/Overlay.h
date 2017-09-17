//
//  Overlay.h
//  PulseLock
//
//  Created by Frederik Jensen on 12/11/16.
//  Copyright (c) 2016 Brinck10. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ORSSerial/ORSSerial.h>
#import "Preferences.h"

@interface Overlay : NSWindow <ORSSerialPortDelegate> {
    NSWindow *blur;
    NSView *blurView;
}

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (assign, nonatomic) BOOL darkModeOn;

@property (assign, nonatomic) NSDate *time;
@property (strong) ORSSerialPort *port;
@property float heartRate;
@property int dataCounter;
@property bool goalReached;

- (void) doBlur:(NSNumber*)duration;

@end
