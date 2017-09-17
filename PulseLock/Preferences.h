//
//  Setup.h
//  PulseLock
//
//  Created by Frederik Jensen on 12/11/16.
//  Copyright (c) 2016 Brinck10. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IntervalSlider.h"
#import "Overlay.h"

@interface Preferences : NSWindow {}

@property (weak) IBOutlet NSTextField *intervalText;
@property (weak) IBOutlet IntervalSlider *intervalSlider;
@property (weak) IBOutlet NSBox *goalBox;
@property (weak) IBOutlet NSButton *startButton;

@property float goal;
@property float baseRate;
@property float interval;
@property (weak) NSWindow *parentWindow;
@property (weak) IBOutlet NSTextField *userAge;

- (IBAction)performSlide:(id)sender;
- (IBAction)startButtonDown:(id)sender;
@end
