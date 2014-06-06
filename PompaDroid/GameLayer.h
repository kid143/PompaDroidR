//
//  GameLayer.h
//  PompaDroid
//
//  Created by kid143 on 14-5-28.
//  Copyright 2014年 kid143. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SimpleDPad.h"
#import "HudLayer.h"
#import "Hero.h"

@interface GameLayer : CCNode <SimpleDPadDelegate> {
    CCSpriteBatchNode *_actors;
    
    Hero *_hero;
}

@property (nonatomic, strong) CCTiledMap *tileMap;
@property (nonatomic, weak) HudLayer *hud;
@property (nonatomic, strong) NSMutableArray *robots;

@end
