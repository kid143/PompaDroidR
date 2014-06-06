//
//  RoleStates.m
//  PompaDroid
//
//  Created by kid143 on 14-5-28.
//  Copyright (c) 2014年 kid143. All rights reserved.
//

#import "RoleStates.h"
#import "ActionSprite.h"
#import "SimpleEventDispatcher.h"
#import "Hero.h"
#import "Robot.h"

static Idle *heroIdleState;
static Attack *heroAttackState;
static Walk *heroWalkState;


@implementation RoleState

+ (instancetype)state
{
    return [[self alloc] init];
}

+ (instancetype)stateWithAction:(CCAction *)action
{
    // override by subclasses.
    RoleState *instance = [self state];
    instance.stateAction = action;
    return instance;
}

- (void)enter:(ActionSprite *)sprite
{
    // override by subclasses.
}

- (void)execute:(ActionSprite *)sprite
{
    // override by subclasses.
}

- (void)exit:(ActionSprite *)sprite
{
    // override by subclasses.
}

@end

@implementation Idle

- (void)enter:(ActionSprite *)sprite
{
    [sprite runAction:self.stateAction];
    sprite.velocity = CGPointZero;
}

- (void)execute:(ActionSprite *)sprite
{
    
}

- (void)exit:(ActionSprite *)sprite
{
    [sprite stopAction:self.stateAction];
}

@end

@implementation Attack

- (void)enter:(ActionSprite *)sprite
{
    [sprite runAction:[CCActionSequence actionOne:(CCActionFiniteTime *)self.stateAction
                                              two:[CCActionCallBlock actionWithBlock:^{
        [sprite changeState:sprite.idleState];
    }]]];
    
    [[SimpleEventDispatcher sharedInstance] dispatchEvent:@"attack"
                                                    delay:SEND_IMMEDIATELY
                                                extraInfo:sprite];
}

- (void)execute:(ActionSprite *)sprite
{
    
}

- (void)exit:(ActionSprite *)sprite
{
    [sprite stopAction:self.stateAction];
}

@end

@implementation Walk

- (void)enter:(ActionSprite *)sprite
{
    [sprite runAction:self.stateAction];
}

- (void)execute:(ActionSprite *)sprite
{
    if ([sprite isInState:sprite.walkState]) {
        sprite.velocity = ccp(sprite.direction.x * sprite.walkSpeed,
                        sprite.direction.y * sprite.walkSpeed);
        if (sprite.velocity.x >= 0)
            sprite.scaleX = 1.0;
        else
            sprite.scaleX = -1.0;
    }
}

- (void)exit:(ActionSprite *)sprite
{
    [sprite stopAction:self.stateAction];
    sprite.velocity = CGPointZero;
    sprite.direction = CGPointZero;
}

@end

@implementation Hurt

- (instancetype)init
{
    if ((self = [super init])) {
        self.hitDirection = -1;
    }
    return self;
}

- (void)enter:(ActionSprite *)sprite
{
    CCActionFiniteTime *hitBackAction = [CCActionMoveBy actionWithDuration:0.2 position:ccp(self.hitDirection * 15, 0)];
    CCActionCallBlock *changeStateAction = [CCActionCallBlock actionWithBlock:^{
        if (sprite.hitPoints > 0) {
            [sprite changeState:sprite.idleState];
        } else {
            [sprite changeState:sprite.knockedOutState];
        }
    }];
    
    [sprite runAction:[CCActionSequence actionWithArray:@[self.stateAction, hitBackAction, changeStateAction]]];
    sprite.hitPoints -= self.damage;
}

- (void)execute:(ActionSprite *)sprite
{
    
}

- (void)exit:(ActionSprite *)sprite
{
    [sprite stopAction:self.stateAction];
}

@end

@implementation KnockedOut

- (void)enter:(ActionSprite *)sprite
{
    [sprite runAction:self.stateAction];
    sprite.hitPoints = 0.0;
}

- (void)execute:(ActionSprite *)sprite
{
    
}

- (void)exit:(ActionSprite *)sprite
{
    [sprite stopAllActions];
}

@end