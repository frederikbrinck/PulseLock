//
//  AppDelegate.h
//  PulseLock
//
//  Created by Frederik Jensen on 12/11/16.
//  Copyright (c) 2016 Brinck10. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate>

@property (strong, nonatomic) NSStatusItem *statusBar;
@property (weak) IBOutlet NSMenu *statusMenu;

@end

