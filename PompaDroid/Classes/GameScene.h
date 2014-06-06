//
//  HelloWorldScene.h
//  PompaDroid
//
//  Created by kid143 on 14-5-28.
//  Copyright kid143 2014年. All rights reserved.
//
// -----------------------------------------------------------------------

// Importing cocos2d.h and cocos2d-ui.h, will import anything you need to start using Cocos2D v3
#import "cocos2d.h"
#import "cocos2d-ui.h"

// -----------------------------------------------------------------------

#import "HudLayer.h"
#import "GameLayer.h"

// -----------------------------------------------------------------------

/**
 *  The main scene
 */
@interface GameScene : CCScene

// -----------------------------------------------------------------------

@property (nonatomic, strong) HudLayer *hudLayer;
@property (nonatomic, strong) GameLayer *gameLayer;

// -----------------------------------------------------------------------

+ (GameScene *)scene;
- (id)init;

// -----------------------------------------------------------------------
@end