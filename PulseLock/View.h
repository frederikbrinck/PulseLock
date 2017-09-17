//
//  BlurView.h
//  PulseLock
//
//  Created by Frederik Jensen on 12/11/16.
//  Copyright (c) 2016 Brinck10. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface View : NSView
{
    NSColor *fillColor;
}

- (void) setColor:(NSColor *)color;

@end