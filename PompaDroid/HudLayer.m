//
//  HudLayer.m
//  PompaDroid
//
//  Created by kid143 on 14-5-28.
//  Copyright 2014年 kid143. All rights reserved.
//

#import "HudLayer.h"


@implementation HudLayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dPad = [SimpleDPad dPadWithFile:@"pd_dpad.png" radius:64];
        _dPad.position = ccp(64.0, 64.0);
        _dPad.opacity = 0.4;
        [self addChild:_dPad];
    }
    return self;
}

@end
