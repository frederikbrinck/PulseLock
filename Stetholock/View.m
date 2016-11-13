//
//  BlurView.m
//  PulseLock
//
//  Created by Frederik Jensen on 12/11/16.
//  Copyright (c) 2016 Brinck10. All rights reserved.
//

#import "View.h"
#import <QuartzCore/QuartzCore.h>

@implementation View

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    fillColor = [NSColor clearColor];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    fillColor = [NSColor clearColor];
    id view = [super initWithCoder:aDecoder];
    return view;
}

- (void)setColor:(NSColor *)color {
    fillColor = color;
}


- (void)drawRect:(NSRect)rect{
    [fillColor set];
    NSRectFill(rect);
}

@end