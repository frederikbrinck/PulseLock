//
//  Overlay.m
//  PulseLock
//
//  Created by Frederik Jensen on 12/11/16.
//  Copyright (c) 2016 Brinck10. All rights reserved.
//

#import "Overlay.h"
#import "View.h"
#include <Carbon/Carbon.h>
#import <QuartzCore/QuartzCore.h>

@implementation Overlay

@synthesize heartRate, goalReached, dataCounter;

- (void)windowDidBecomeMain:(NSNotification *)notification
{
    static BOOL shouldGoFullScreen = YES;
    if (shouldGoFullScreen) {
        if (!([self styleMask] & NSFullScreenWindowMask))
            [self toggleFullScreen:nil];
        shouldGoFullScreen = NO;
    }
    
    // open port to microcontroller whose serial port must be changed
    // whenever adding a new device. The device used for this project
    // was the MAXREFDES117 from Maxim Intregrated
    NSLog(@"Reading port...");
    self.port = [ORSSerialPort serialPortWithPath:@"/dev/tty.usbmodem1a1212"];
    self.port.baudRate = @115200;
    [self.port setDelegate:self];
    [self.port open];
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
    self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:bufferingType defer:flag];
    
    // set settings for blurry overlay
    if ( self ) {
        [self setOpaque:NO];
        [self setHasShadow:NO];
        [self setLevel:NSFloatingWindowLevel];
        [self setAlphaValue:1.0];
    }
    contentRect.origin.x=0;
    contentRect.origin.y=0;
    
    // set statusbar and simple vars
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.heartRate = 60.0;
    self.dataCounter = 0;
    
    return self;
}


- (void)awakeFromNib {
    // setup blur
    blur = [[NSWindow alloc] initWithContentRect:self.frame styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES screen:self.screen];
    [blur setHasShadow:NO];
    [blur setLevel:NSFloatingWindowLevel];
    [blur setIgnoresMouseEvents:YES];

    // add blur to view
    blurView = [[View alloc] initWithFrame:self.frame];
    [blur setContentView:blurView];
    [(View *)blurView setColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.5]];
    [blur orderFront:self];
    [self addChildWindow:blur ordered:NSWindowAbove];
    
    // make blur hack into the private apis. Note that this would get
    // rejected from the appstore
    typedef void * CGSConnection;
    extern OSStatus CGSSetWindowBackgroundBlurRadius(CGSConnection connection, NSInteger windowNumber, int radius);
    extern CGSConnection CGSDefaultConnectionForThread();
    [blur setOpaque:NO];
    [blur setAlphaValue:0.0];
    blur.backgroundColor = [NSColor colorWithCalibratedWhite:0.5 alpha:0.5];
    
    // set blur radius
    CGSConnection connection = CGSDefaultConnectionForThread();
    CGSSetWindowBackgroundBlurRadius(connection, [blur windowNumber], 20);
}

// handle data from microcontroller
- (void)serialPort:(ORSSerialPort *)serialPort didReceiveData:(NSData *)data {
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    // retrieve non-buffered data
    if ([string containsString:@"HR="]) {
        NSRange range = [string rangeOfString:@"HR="];
        NSString *halfHeartRate = [[string substringFromIndex:NSMaxRange(range)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
       
        // scan string to isolate heart rate
        NSString *rate;
        NSScanner *scanner = [NSScanner scannerWithString:halfHeartRate];
        NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
       
        // throw away numbers and collect
        [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
        [scanner scanCharactersFromSet:numbers intoString:&rate];
       
        // simple modification of heart rate algorithm
        // to avoid weird spikes
        float number = [rate floatValue];
        if (self.heartRate == 0.0 && number >= 30 && number <= 220) {
            self.heartRate = number;
        } else if (number < (self.heartRate + 20.0) && number > (self.heartRate - 20.0)) {
            self.heartRate = number;
        }
    
        // check that the target heart rate has been reached
        float goal = [[[NSUserDefaults standardUserDefaults] objectForKey:@"goal"] floatValue];
        // NSLog(@"Rate: %f, Goal %f", self.heartRate, goal);
        if (self.heartRate > goal && self.goalReached == NO) {
            self.goalReached = YES;

            // reset blur
            [NSAnimationContext beginGrouping];
            [[NSAnimationContext currentContext] setDuration:1.5];
            [[blur animator] setAlphaValue:0.0];
            [NSAnimationContext endGrouping];

            // enqueue next do blur
            [self.port close];
            float interval = [[[NSUserDefaults standardUserDefaults] objectForKey:@"interval"] floatValue];
            NSLog(@"Goal reached with heart rate %f! Next blur in %f seconds", self.heartRate, interval);
            self.heartRate = 60.0;
            [self performSelector:@selector(doBlur:) withObject:[NSNumber numberWithFloat:10.0] afterDelay:interval];
        }
       
        // increment data counter and notify user about progress
        self.dataCounter++;
        if (self.dataCounter >= 1000) {
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            notification.title = [NSString stringWithFormat:@"Heart Rate is at %.00f", self.heartRate];
            notification.informativeText = [NSString stringWithFormat:@"Get your heart rate above %.00f", [[[NSUserDefaults standardUserDefaults] objectForKey:@"goal"] floatValue]];
            notification.contentImage = [NSImage imageNamed:@"applogo.png"];
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
            self.dataCounter = 0;
        }
    }
}

- (void)serialPortWasClosed:(ORSSerialPort *)serialPort {
    [self.port open];
}

- (void) serialPortWasRemovedFromSystem:(ORSSerialPort * __nonnull)serialPort { }

- (void) doBlur:(NSNumber*)duration {
    self.goalReached = NO;
    
    // start listening to the microcontroller
    NSString *key = @"KeyPress";
    NSData *dataToSend = [key dataUsingEncoding:NSUTF8StringEncoding];
    [self.port sendData:dataToSend];

    // notify user about blur challenge
    NSLog(@"doBlur...");
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"Blurring...";
    notification.informativeText = [NSString stringWithFormat:@"Get your heart rate above %.00f", [[[NSUserDefaults standardUserDefaults] objectForKey:@"goal"] floatValue]];
    notification.contentImage = [NSImage imageNamed:@"applogo.png"];
    notification.soundName = NSUserNotificationDefaultSoundName;
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    // blur the screen slowly
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:[duration floatValue]];
    [[blur animator] setAlphaValue:1.0];
    [NSAnimationContext endGrouping];
}

@end