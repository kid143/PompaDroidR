//
//  ActionSprite.m
//  PompaDroid
//
//  Created by kid143 on 14-5-28.
//  Copyright 2014年 kid143. All rights reserved.
//

#import "ActionSprite.h"


@implementation ActionSprite

- (void)changeState:(RoleState *)state
{
    if (![self isInState:state]) {
        [self.currentState exit:self];
        self.currentState = state;
        [self.currentState enter:self];
    }
}

- (BOOL)isInState:(RoleState *)state
{
    if ([_currentState isMemberOfClass:[state class]]) {
        return true;
    }
    return false;
}

- (BoundingBox)createBoundingBoxWithOrigin:(CGPoint)origin size:(CGSize)size
{
    BoundingBox boundingBox;
    boundingBox.original.origin = origin;
    boundingBox.original.size = size;
    boundingBox.actual.origin = ccpAdd(self.position, origin);
    boundingBox.actual.size = size;
    return boundingBox;
}

- (void)transformBoundingBox
{
    _hitBox.actual.origin = ccpAdd(_position,
                            ccp(_hitBox.original.origin.x * _scaleX,
                                _hitBox.original.origin.y *_scaleY));
    _hitBox.actual.size = CGSizeMake(_hitBox.original.size.width * _scaleX,
                                     _hitBox.original.size.height * _scaleY);
    _attackBox.actual.origin = ccpAdd(_position,
                                   ccp(_attackBox.original.origin.x * _scaleX,
                                       _attackBox.original.origin.y *_scaleY));
    _attackBox.actual.size = CGSizeMake(_attackBox.original.size.width * _scaleX,
                                     _attackBox.original.size.height * _scaleY);
}

- (void)setPosition:(CGPoint)position
{
    [super setPosition:position];
    [self transformBoundingBox];
}

- (void)hurtWithDamage:(float)damage {
    int randomSound = random_range(0, 1);
    [[OALSimpleAudio sharedInstance] playEffect:[NSString
                                                 stringWithFormat:@"pd_hit%d.caf", randomSound]];
    Hurt *hurtState = [Hurt stateWithAction:self.hurtAction];
    hurtState.damage = damage;
    [self changeState:hurtState];
        
    if (_hitPoints <= 0.0) {
        [self changeState:self.knockedOutState];
    }
}

@end
