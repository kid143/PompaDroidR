//
//  SimpleDPad.m
//  PompaDroid
//
//  Created by kid143 on 14-5-29.
//  Copyright 2014年 kid143. All rights reserved.
//

#import "SimpleDPad.h"

@implementation SimpleDPad

+(id)dPadWithFile:(NSString *)fileName radius:(float)radius
{
    return [[self alloc] initWithFile:fileName radius:radius];
}

-(id)initWithFile:(NSString *)filename radius:(float)radius
{
    if ((self = [super initWithImageNamed:filename])) {
        [self setUserInteractionEnabled:YES];
        _radius = radius;
        _direction = CGPointZero;
        _isHeld = NO;
    }
    return self;
}

- (void)update:(CCTime)delta
{
    if (_isHeld) {
        [self.delegate simpleDPad:self isHoldingDirection:_direction];
    }
}

- (void)updateDirectionForTouchLocation:(CGPoint)location
{
    float radians = ccpToAngle(ccpSub(location, self.position));
    float degrees = -1 * CC_RADIANS_TO_DEGREES(radians);
    
    // 8 directions
    if (degrees <= 22.5 && degrees >= -22.5) {
        //right
        _direction = ccp(1.0, 0.0);
    } else if (degrees > 22.5 && degrees < 67.5) {
        //bottomright
        _direction = ccp(1.0, -1.0);
    } else if (degrees >= 67.5 && degrees <= 112.5) {
        //bottom
        _direction = ccp(0.0, -1.0);
    } else if (degrees > 112.5 && degrees < 157.5) {
        //bottomleft
        _direction = ccp(-1.0, -1.0);
    } else if (degrees >= 157.5 || degrees <= -157.5) {
        //left
        _direction = ccp(-1.0, 0.0);
    } else if (degrees < -22.5 && degrees > -67.5) {
        //topright
        _direction = ccp(1.0, 1.0);
    } else if (degrees <= -67.5 && degrees >= -112.5) {
        //top
        _direction = ccp(0.0, 1.0);
    } else if (degrees < -112.5 && degrees > -157.5) {
        //topleft
        _direction = ccp(-1.0, 1.0);
    }
    
    [_delegate simpleDPad:self didChangeDirectionTo:_direction];
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
    
    float distanceSQ = ccpDistanceSQ(location, self.position);
    if (distanceSQ <= _radius * _radius) {
        //get angle 8 directions
        [self updateDirectionForTouchLocation:location];
        _isHeld = YES;
    }
}

- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
    [self updateDirectionForTouchLocation:location];
}

- (void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    _direction = CGPointZero;
    _isHeld = NO;
    [_delegate simpleDPadTouchEnded:self];
}

@end
