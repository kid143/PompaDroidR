//
//  HelloWorldScene.m
//  PompaDroid
//
//  Created by kid143 on 14-5-28.
//  Copyright kid143 2014年. All rights reserved.
//
// -----------------------------------------------------------------------

#import "GameScene.h"
#import "SimpleEventDispatcher.h"

// -----------------------------------------------------------------------
#pragma mark - HelloWorldScene
// -----------------------------------------------------------------------

@implementation GameScene

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (GameScene *)scene
{
    return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    [self setUserInteractionEnabled:YES];
    
    _gameLayer = [GameLayer node];
    [self addChild:_gameLayer z:0];
    
    _hudLayer = [HudLayer node];
    [self addChild:_hudLayer z:1];

    _hudLayer.dPad.delegate = _gameLayer;
    _gameLayer.hud = _hudLayer;
    // done
	return self;
}

// -----------------------------------------------------------------------

- (void)dealloc
{
    // clean up code goes here
}

// -----------------------------------------------------------------------
#pragma mark - Update per frame
// -----------------------------------------------------------------------

- (void)update:(CCTime)delta
{
    [[SimpleEventDispatcher sharedInstance] dispatchDelayedEvents];
}

@end
