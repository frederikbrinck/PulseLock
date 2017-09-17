//
//  AppDelegate.m
//  PulseLock
//
//  Created by Frederik Jensen on 12/11/16.
//  Copyright (c) 2016 Brinck10. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
    @property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate
@synthesize statusBar = _statusBar;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification { }

- (void) awakeFromNib {
    // setup statusbar
    self.statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusBar.image = [NSImage imageNamed:@"statuslogo.png"];
    self.statusBar.menu = self.statusMenu;
    self.statusBar.highlightMode = YES;
}


@end
