//
//  RoleStates.h
//  PompaDroid
//
//  Created by kid143 on 14-5-28.
//  Copyright (c) 2014年 kid143. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class ActionSprite;

@interface RoleState : NSObject

@property (nonatomic, strong) CCAction *stateAction;

+ (instancetype)state;
+ (instancetype)stateWithAction:(CCAction *)action;
- (void)enter:(ActionSprite *)sprite;
- (void)execute:(ActionSprite *)sprite;
- (void)exit:(ActionSprite *)sprite;

@end

@interface Idle : RoleState

@end

@interface Attack : RoleState

@end

@interface Walk : RoleState

@end

@interface Hurt : RoleState

@property (nonatomic, assign) float damage;
@property (nonatomic, assign) int hitDirection; // less than 0 means hit from right to left.

@end

@interface KnockedOut : RoleState

@end
