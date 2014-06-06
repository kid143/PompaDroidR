//
//  ActionSprite.h
//  PompaDroid
//
//  Created by kid143 on 14-5-28.
//  Copyright 2014年 kid143. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "RoleStates.h"

@interface ActionSprite : CCSprite {
}

//attributes
@property (nonatomic, assign) float walkSpeed;
@property (nonatomic, assign) float hitPoints;
@property (nonatomic, assign) float damage;

// state actions
@property (nonatomic, strong) CCAction *idleAction;
@property (nonatomic, strong) CCAction *attackAction;
@property (nonatomic, strong) CCAction *walkAction;
@property (nonatomic, strong) CCAction *hurtAction;
@property (nonatomic, strong) CCAction *knockedOutAction;

// state actions
@property (nonatomic, strong) Idle *idleState;
@property (nonatomic, strong) Attack *attackState;
@property (nonatomic, strong) Walk *walkState;
@property (nonatomic, strong) Hurt *hurtState;
@property (nonatomic, strong) KnockedOut *knockedOutState;

//current state
@property (nonatomic, strong) RoleState *currentState;

//movement
@property (nonatomic, assign) CGPoint velocity;
@property (nonatomic, assign) CGPoint desiredPosition;
@property (nonatomic, assign) CGPoint direction;

//measurements
@property (nonatomic, assign) float centerToSides;
@property (nonatomic, assign) float centerToBottom;

@property (nonatomic, assign) BoundingBox hitBox;
@property (nonatomic, assign) BoundingBox attackBox;

- (void)changeState:(RoleState *)state;
- (BOOL)isInState:(RoleState *)state;
- (BoundingBox)createBoundingBoxWithOrigin:(CGPoint)origin size:(CGSize)size;
- (void)hurtWithDamage:(float)damage;

@end
