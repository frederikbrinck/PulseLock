//
//  Setup.m
//  PulseLock
//
//  Created by Frederik Jensen on 12/11/16.
//  Copyright (c) 2016 Brinck10. All rights reserved.
//

#import "Preferences.h"

@implementation Preferences
@synthesize parentWindow, intervalSlider, startButton, intervalText, userAge, interval;

- (void)awakeFromNib {
    // setup ui components
    [self setBackgroundColor:[NSColor whiteColor]];
    [intervalSlider setMinValue:10];
    [intervalSlider setIntegerValue:30];
    self.interval = 30.0;
    self.baseRate = 60;
    self.goal = 100;
    NSLog(@"Set interval to %f seconds", self.interval);
    [intervalText setStringValue:[NSString stringWithFormat:@"Seconds between blur: %ld", (long)[intervalSlider integerValue]]];
    [intervalSlider setMaxValue:90];
}

- (IBAction)performSlide:(id)sender {
    // update slider values
    NSLog(@"Value %ld", (long)[intervalSlider integerValue]);
    [intervalText setStringValue:[NSString stringWithFormat:@"Seconds between blur: %ld", (long)[intervalSlider integerValue]]];
    self.interval = [intervalSlider floatValue];
    [self saveDefaults];
}

- (IBAction)startButtonDown:(id)sender {
    // start button clicked meaning that
    // setup has been done
    [self.startButton setTitle:@"Update"];
    float age = [[userAge stringValue] floatValue];
    self.goal = (220 - age) * 0.6;
    
    if (![self.startButton  isEqual: @"Update"]) {
        [(Overlay *)self.delegate performSelector:@selector(doBlur:) withObject:[NSNumber numberWithFloat:10.0] afterDelay:self.interval];
        NSLog(@"Calling blur in %f seconds with goal %f", self.interval, self.goal);
    }
    [self saveDefaults];
    [self close];
}

- (void) saveDefaults {
    // save to NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self.goal] forKey:@"goal"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self.baseRate] forKey:@"baseRate"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self.interval] forKey:@"interval"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
