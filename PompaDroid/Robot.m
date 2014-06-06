//
//  Robot.m
//  PompaDroid
//
//  Created by kid143 on 14-5-30.
//  Copyright (c) 2014年 kid143. All rights reserved.
//

#import "Robot.h"
#import "Hero.h"
#import "CCAnimation.h"
#import "GameLayer.h"

@implementation Robot

{
    CGPoint _heroPosition;
    double _nextDecisionTime;
}

- (instancetype)init
{
    self = [super initWithSpriteFrame:
                   [[CCSpriteFrameCache sharedSpriteFrameCache]
                    spriteFrameByName:@"robot_idle_00.png"]];
    if (self) {
        // idle action
        NSMutableArray *idleFrames = [NSMutableArray arrayWithCapacity:5];
        for (int i = 0; i < 5; i++) {
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache]
                                    spriteFrameByName:[NSString
                                                       stringWithFormat:@"robot_idle_%02d.png", i]];
            [idleFrames addObject:frame];
        }
        CCAnimation *idleAnimation = [CCAnimation animationWithSpriteFrames:idleFrames delay:1.0/12.0];
        self.idleAction = [CCActionRepeatForever
                                     actionWithAction:[CCActionAnimate
                                                       actionWithAnimation:idleAnimation]];
        
        // attack action
        NSMutableArray *attackFrames = [NSMutableArray arrayWithCapacity:5];
        for (int i = 0; i < 5; i++) {
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache]
                                    spriteFrameByName:[NSString
                                                       stringWithFormat:@"robot_attack_%02d.png", i]];
            [attackFrames addObject:frame];
        }
        CCAnimation *attackAnimation = [CCAnimation
                                        animationWithSpriteFrames:attackFrames delay:1.0/24.0];
        self.attackAction = [CCActionAnimate actionWithAnimation:attackAnimation];
        
        // walk action
        NSMutableArray *walkFrames = [NSMutableArray arrayWithCapacity:6];
        for (int i = 0; i < 6; i++) {
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache]
                                    spriteFrameByName:[NSString
                                                       stringWithFormat:@"robot_walk_%02d.png", i]];
            [walkFrames addObject:frame];
        }
        CCAnimation *walkAnimation = [CCAnimation animationWithSpriteFrames:walkFrames delay:1.0/12.0];
        self.walkAction = [CCActionRepeatForever
                                     actionWithAction:[CCActionAnimate
                                                       actionWithAnimation:walkAnimation]];
        
        // hurt action
        NSMutableArray *hurtFrames = [NSMutableArray arrayWithCapacity:3];
        for (int i = 0; i < 3; i++) {
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache]
                                    spriteFrameByName:[NSString
                                                       stringWithFormat:@"robot_hurt_%02d.png", i]];
            [hurtFrames addObject:frame];
        }
        CCAnimation *hurtAnimation = [CCAnimation animationWithSpriteFrames:hurtFrames delay:1.0/12.0];
        self.hurtAction = [CCActionAnimate actionWithAnimation:hurtAnimation];
        
        // knockedout action
        NSMutableArray *knockedOutFrames = [NSMutableArray arrayWithCapacity:5];
        for (int i = 0; i < 5; i++) {
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache]
                                    spriteFrameByName:[NSString
                                                       stringWithFormat:@"robot_knockout_%02d.png", i]];
            [knockedOutFrames addObject:frame];
        }
        CCAnimation *knockedOutAnimation = [CCAnimation animationWithSpriteFrames:knockedOutFrames
                                                                            delay:1.0/12.0];
        CCActionFiniteTime *knockoutActionSeq = [CCActionSequence actions:[CCActionAnimate
                                                           actionWithAnimation:knockedOutAnimation],
                [CCActionBlink actionWithDuration:2.0 blinks:10.0], nil];
        self.knockedOutAction = [CCActionSpawn actionOne:knockoutActionSeq
                                                     two:[CCActionCallBlock actionWithBlock:^{
            [[OALSimpleAudio sharedInstance] playEffect:@"pd_botdeath.caf"];
        }]];
        
        self.idleState = [Idle stateWithAction:self.idleAction];
        self.attackState = [Attack stateWithAction:self.attackAction];
        self.walkState = [Walk stateWithAction:self.walkAction];
        self.hurtState = [Hurt stateWithAction:self.hurtAction];
        self.knockedOutState = [KnockedOut stateWithAction:self.knockedOutAction];
        
        self.currentState = self.idleState;
        
        self.walkSpeed = 80;
        self.centerToBottom = 39.0;
        self.centerToSides = 29.0;
        self.hitPoints = 100;
        self.damage = 10;
        
        self.hitBox = [self createBoundingBoxWithOrigin:ccp(-self.centerToSides,
                                                            -self.centerToBottom)
                                                   size:CGSizeMake(self.centerToSides * 2,
                                                                   self.centerToBottom * 2)];
        self.attackBox = [self createBoundingBoxWithOrigin:ccp(self.centerToSides, -5)
                                                      size:CGSizeMake(25, 20)];
        
        _nextDecisionTime = 0.0f;
        
        [[SimpleEventDispatcher sharedInstance] registerHandler:self forEvent:@"hero_position"];
        [[SimpleEventDispatcher sharedInstance] registerHandler:self forEvent:@"attack"];
    }
    return self;
}

- (void)dealloc
{
    // used for cleanup event dispatcher queue.
    [[SimpleEventDispatcher sharedInstance] removeHandler:self forEvent:@"hero_position"];
    [[SimpleEventDispatcher sharedInstance] removeHandler:self forEvent:@"attack"];
}

- (BOOL)handleEvent:(Event *)event
{
    if (CURTIME > _nextDecisionTime && ![self isInState:self.knockedOutState]) {
        int randomChoice = 0;
        if ([event.name isEqualToString:@"hero_position"]) {
            _heroPosition = [event.extraInfo CGPointValue];
            double distanceSQ = ccpDistanceSQ(self.position, _heroPosition);
            if (![self isInState:self.walkState] && ![self isInState:self.attackState]
                && distanceSQ <= SCREEN.width * SCREEN.width) {
                _nextDecisionTime = CURTIME + frandom_range(0.5, 1.0);
                randomChoice = random_range(0, 2);
                if (randomChoice == 0) {
                    self.direction = ccpNormalize(ccpSub(_heroPosition, self.position));
                    [self changeState:self.walkState];
                } else {
                    [self changeState:self.idleState];
                }
            }
            
            return true;
        }
    }
    
    if ([event.name isEqualToString:@"attack"] && ![self isInState:self.knockedOutState]) {
        if ([event.extraInfo isMemberOfClass:[Hero class]]) {
            Hero *hero = event.extraInfo;
            if (fabs(hero.position.y - self.position.y) < 10) {
                if (CGRectIntersectsRect(self.hitBox.actual, hero.attackBox.actual)) {
                    self.hurtState.damage = hero.damage;
                    self.hurtState.hitDirection = hero.scaleX;
                    [self changeState:self.hurtState];
                }
            }
        }
        return true;
    }
    
    return false;
}

- (void)updatePostion
{
    GameLayer *layer = (GameLayer *)self.parent.parent;
    float posX = MIN(layer.tileMap.mapSize.width * layer.tileMap.tileSize.width - self.centerToSides,
                     MAX(self.centerToSides, self.desiredPosition.x));
    float posY = MIN(3 * layer.tileMap.tileSize.height + self.centerToBottom,
                     MAX(self.centerToBottom, self.desiredPosition.y));
    self.position = ccp(posX, posY);
}

- (void)update:(CCTime)delta
{
    [self.currentState execute:self];
    [self updatePostion];
    
    // update velocity direction
    if ((self.position.x - _heroPosition.x) * self.velocity.x > 0) {
        self.velocity = ccp(-self.velocity.x, self.velocity.y);
    }
    
    if ((self.position.y - _heroPosition.y) * self.velocity.y > 0) {
        self.velocity = ccp(self.velocity.x, -self.velocity.y);
    }
    
    // could use some random work.
    if (CURTIME > _nextDecisionTime && ![self isInState:self.knockedOutState]) {
        _nextDecisionTime = CURTIME + frandom_range(0.1, 0.5);
        int randomChoice = 0;
        if (ccpDistanceSQ(self.position, _heroPosition) <= 50 * 50 &&
            ![self isInState:self.attackState]) {
            randomChoice = random_range(0, 2);
            if (randomChoice == 0) {
                if (_heroPosition.x > self.position.x) {
                    self.scaleX = 1.0;
                } else {
                    self.scaleX = -1.0;
                }
                [self changeState:self.attackState];
            }
            
        }
    }
    
    if ([self isInState:self.walkState]) {
        self.desiredPosition = ccpAdd(self.position, ccpMult(self.velocity, delta));
    }
    
    if ([self isInState:self.knockedOutState] && [self numberOfRunningActions] == 0) {
        GameLayer *layer = (GameLayer *)self.parent.parent;
        [layer.robots removeObject:self];
        [self removeFromParent];
    }
}

@end
