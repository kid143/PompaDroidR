//
//  Hero.m
//  PompaDroid
//
//  Created by kid143 on 14-5-28.
//  Copyright (c) 2014年 kid143. All rights reserved.
//

#import "Hero.h"
#import "Robot.h"
#import "CCAnimation.h"

@implementation Hero

- (id)init
{
    if ((self = [super initWithSpriteFrame:
                 [[CCSpriteFrameCache sharedSpriteFrameCache]
                  spriteFrameByName:@"hero_idle_00.png"]]))
    {
        // idle action
        int i;
        NSMutableArray *idleFrames = [NSMutableArray arrayWithCapacity:6];
        for (i = 0; i < 6; i++) {
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"hero_idle_%02d.png", i]];
            [idleFrames addObject:frame];
        }
        CCAnimation *idleAnimation = [CCAnimation animationWithSpriteFrames:idleFrames
                                                                      delay:1.0/12.0];
        self.idleAction = [CCActionRepeatForever actionWithAction:[CCActionAnimate
                                        actionWithAnimation:idleAnimation]];
        
        // attack action
        NSMutableArray *attackFrames = [NSMutableArray arrayWithCapacity:3];
        for (i = 0; i < 3; i++) {
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache]
                                    spriteFrameByName:[NSString
                                                       stringWithFormat:@"hero_attack_00_%02d.png", i]];
            [attackFrames addObject:frame];
        }
        CCAnimation *attackAnimation = [CCAnimation animationWithSpriteFrames:attackFrames
                                                                        delay:1.0/24.0];
        self.attackAction = [CCActionAnimate actionWithAnimation:attackAnimation];
        
        // walk action
        NSMutableArray *walkFrames = [NSMutableArray arrayWithCapacity:8];
        for (i = 0; i < 8; i++) {
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache]
                                    spriteFrameByName:[NSString
                                                       stringWithFormat:@"hero_walk_%02d.png", i]];
            [walkFrames addObject:frame];
        }
        CCAnimation *walkAnimation = [CCAnimation animationWithSpriteFrames:walkFrames delay:1.0/12.0];
        self.walkAction = [CCActionRepeatForever
                      actionWithAction:[CCActionAnimate
                                        actionWithAnimation:walkAnimation]];
        
        // hurt action
        NSMutableArray *hurtFrames = [NSMutableArray arrayWithCapacity:3];
        for (i = 0; i < 3; i++) {
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache]
                                    spriteFrameByName:[NSString
                                                       stringWithFormat:@"hero_hurt_%02d.png", i]];
            [hurtFrames addObject:frame];
        }
        CCAnimation *hurtAnimation = [CCAnimation animationWithSpriteFrames:hurtFrames delay:1.0/12.0];
        self.hurtAction =  [CCActionAnimate actionWithAnimation:hurtAnimation];
        
        // knockedout action
        NSMutableArray *knockedOutFrames = [NSMutableArray arrayWithCapacity:5];
        for (i = 0; i < 5; i++) {
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache]
                                    spriteFrameByName:[NSString
                                                       stringWithFormat:@"hero_knockout_%02d.png", i]];
            [knockedOutFrames addObject:frame];
        }
        CCAnimation *knockedOutAnimation = [CCAnimation animationWithSpriteFrames:knockedOutFrames
                                                                            delay:1.0/12.0];
        CCActionFiniteTime *knockoutActionSeq = [CCActionSequence
                                                 actions:[CCActionAnimate
                                                          actionWithAnimation:knockedOutAnimation],
                [CCActionBlink actionWithDuration:2.0 blinks:10.0], nil];
        self.knockedOutAction = [CCActionSpawn actionOne:knockoutActionSeq
                                                     two:[CCActionCallBlock actionWithBlock:^{
            [[OALSimpleAudio sharedInstance] playEffect:@"pd_herodeath.caf"];
        }]];
        
        self.idleState = [Idle stateWithAction:self.idleAction];
        self.attackState = [Attack stateWithAction:self.attackAction];
        self.walkState = [Walk stateWithAction:self.walkAction];
        self.hurtState = [Hurt stateWithAction:self.hurtAction];
        self.knockedOutState = [KnockedOut stateWithAction:self.knockedOutAction];
        
        self.currentState = self.idleState;
        
        self.centerToBottom = 39.0;
        self.centerToSides = 29.0;
        self.hitPoints = 100.0;
        self.direction = CGPointZero;
        self.damage = 20.0;
        self.walkSpeed = 80;
        
        self.hitBox = [self createBoundingBoxWithOrigin:ccp(-self.centerToSides,
                                                            -self.centerToBottom)
                                                   size:CGSizeMake(self.centerToSides * 2,
                                                                   self.centerToBottom * 2)];
        self.attackBox = [self createBoundingBoxWithOrigin:ccp(self.centerToSides, -10)
                                                      size:CGSizeMake(20, 20)];
        
        [[SimpleEventDispatcher sharedInstance] registerHandler:self forEvent:@"attack"];
    }
    return self;
}

- (void)dealloc
{
    // used for clean up event dispatcher queue.
    [[SimpleEventDispatcher sharedInstance] removeHandler:self forEvent:@"attack"];
}

- (BOOL)handleEvent:(Event *)event
{
    if ([event.name isEqualToString:@"attack"] && ![self isInState:self.knockedOutState]) {
        if (![event.extraInfo isMemberOfClass:[self class]]) {
            Robot *robot = event.extraInfo;
            if (fabsf(self.position.y - robot.position.y) < 10) {
                if (CGRectIntersectsRect(self.hitBox.actual, robot.attackBox.actual)) {
                    self.hurtState.damage = robot.damage;
                    self.hurtState.hitDirection = robot.scaleX;
                    [self changeState:self.hurtState];
                }
            }
        }
        return true;
    }
    return false;
}

- (void)update:(CCTime)delta
{
    [self.currentState execute:self];
    [[SimpleEventDispatcher sharedInstance] dispatchEvent:@"hero_position"
                                                    delay:SEND_IMMEDIATELY
                                                extraInfo:[NSValue valueWithCGPoint:self.position]];
    if ([self isInState:self.walkState]) {
        self.desiredPosition = ccpAdd(self.position, ccpMult(self.velocity, delta));
    }
}

@end
