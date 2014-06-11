//
//  GameLayer.m
//  PompaDroid
//
//  Created by kid143 on 14-5-28.
//  Copyright 2014年 kid143. All rights reserved.
//

#import "GameLayer.h"
#import "GameScene.h"
#import "Robot.h"


@implementation GameLayer

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

- (id)init
{
    if ((self = [super init])) {
        self.userInteractionEnabled = YES;
        
        [self initTiledMap];
        
        /** 
         * The layer content size is essential here because
         * if it is too small, the touch event will not be received.
         * This happens when the hero goes out.So we should set the layer
         * content size to the whole map size.
         */
        [self setContentSize:_tileMap.contentSize];
        [[CCSpriteFrameCache sharedSpriteFrameCache]
         addSpriteFramesWithFile:@"pd_sprites.plist"];
        _actors = [CCSpriteBatchNode batchNodeWithFile:@"pd_sprites.pvr.ccz"];
        _actors.texture.antialiased = NO;
        [self addChild:_actors z:-5];
        
        [self initHero];
        
        [self initRobots];
        
        // Load background music and sound effects
        /**
         * cocos2d-iphone v3 now use OpenAL
         */
        [[OALSimpleAudio sharedInstance] preloadBg:@"latin_industries.aifc"];
        [[OALSimpleAudio sharedInstance] preloadEffect:@"pd_botdeath.caf"];
        [[OALSimpleAudio sharedInstance] preloadEffect:@"pd_herodeath.caf"];
        [[OALSimpleAudio sharedInstance] preloadEffect:@"pd_hit0.caf"];
        [[OALSimpleAudio sharedInstance] preloadEffect:@"pd_hit1.caf"];
        
        [[OALSimpleAudio sharedInstance] playBgWithLoop:YES];
    }
    return self;
}

// -----------------------------------------------------------------------

- (void)dealloc
{
    [self unscheduleAllSelectors];
}

// -----------------------------------------------------------------------
#pragma mark - Game Logics
// -----------------------------------------------------------------------

-(void)updatePositions {
    float posX = MIN(_tileMap.mapSize.width * _tileMap.tileSize.width - _hero.centerToSides,
                     MAX(_hero.centerToSides, _hero.desiredPosition.x));
    float posY = MIN(3 * _tileMap.tileSize.height + _hero.centerToBottom,
                     MAX(_hero.centerToBottom, _hero.desiredPosition.y));
    _hero.position = ccp(posX, posY);
}

-(void)setViewpointCenter:(CGPoint) position {
    
    CGSize winSize = [[CCDirector sharedDirector] viewSize];
    
    int x = MAX(position.x, winSize.width / 2);
    int y = MAX(position.y, winSize.height / 2);
    x = MIN(x, (_tileMap.mapSize.width * _tileMap.tileSize.width)
            - winSize.width / 2);
    y = MIN(y, (_tileMap.mapSize.height * _tileMap.tileSize.height)
            - winSize.height/2);
    CGPoint actualPosition = ccp(x, y);
    
    CGPoint centerOfView = ccp(winSize.width/2, winSize.height/2);
    CGPoint viewPoint = ccpSub(centerOfView, actualPosition);
    self.position = viewPoint;
}

// -----------------------------------------------------------------------

- (void)initTiledMap
{
    _tileMap = [CCTiledMap tiledMapWithFile:@"pd_tilemap.tmx"];
    
    for (CCTiledMapLayer *child in _tileMap.children) {
        child.texture.antialiased = NO;
    }
    
    [self addChild:_tileMap z:-6];
}

// -----------------------------------------------------------------------

- (void)initHero
{
    _hero = [Hero node];
    [_actors addChild:_hero];
    _hero.position = ccp(_hero.centerToSides, 80);
    _hero.desiredPosition = _hero.position;
    
    [_hero.currentState enter:_hero];
}

// -----------------------------------------------------------------------

- (void)initRobots
{
    int robotsCount = 20;
    _robots = [NSMutableArray arrayWithCapacity:robotsCount];
    
    for (int i = 0; i < robotsCount; i++) {
        Robot *newRobot = [Robot node];
        [_actors addChild:newRobot];
        [_robots addObject:newRobot];
        
        int minX = SCREEN.width + newRobot.centerToSides;
        int maxX = _tileMap.mapSize.width * _tileMap.tileSize.width - newRobot.centerToSides;
        int minY = newRobot.centerToBottom;
        int maxY = 3 * _tileMap.tileSize.height + newRobot.centerToBottom;
        
        newRobot.scaleX = -1;
        newRobot.position = ccp(random_range(minX, maxX), random_range(minY, maxY));
        newRobot.desiredPosition = newRobot.position;
        
        [newRobot.currentState enter:newRobot];
    }
}

// -----------------------------------------------------------------------

- (void)reorderActors
{
    for (CCSprite *sprite in _actors.children) {
        sprite.zOrder = (_tileMap.mapSize.height * _tileMap.tileSize.height) - sprite.position.y;
    }
}

// -----------------------------------------------------------------------

- (void)endGame
{
    CCButton *restartButton = [CCButton buttonWithTitle:@"RESTART" fontName:@"Arial" fontSize:30];
    restartButton.block = ^(id sender) {
        [self restartGame];
    };
    
    CCLayoutBox *menu = [[CCLayoutBox alloc] init];
    menu.direction = CCLayoutBoxDirectionHorizontal;
    menu.position = CENTER;
    menu.anchorPoint = ccp(0.5, 0.5);
    menu.name = @"Game Menu";
    [menu addChild:restartButton];

    [_hud addChild:menu z:5];
}

// -----------------------------------------------------------------------

- (void)restartGame
{
    [[CCDirector sharedDirector] replaceScene:[GameScene node]];
}

// -----------------------------------------------------------------------
#pragma mark - Update
// -----------------------------------------------------------------------

- (void)update:(CCTime)delta
{
    [self updatePositions];
    [self reorderActors];
    [self setViewpointCenter:_hero.position];
    
    if ([_hero isInState:_hero.knockedOutState] &&
        [_hud getChildByName:@"Game Menu" recursively:NO] == nil) {
        [self endGame];
    }
    
    if ([self.robots count] == 0 &&
        [_hud getChildByName:@"Game Menu" recursively:NO] == nil) {
        [self endGame];
    }
}

// -----------------------------------------------------------------------
#pragma mark - SimpleDPadDelegate
// -----------------------------------------------------------------------

- (void)simpleDPad:(SimpleDPad *)simpleDPad didChangeDirectionTo:(CGPoint)direction
{
    if ([_hero isInState:_hero.knockedOutState]) {
        return;
    }
    _hero.direction = direction;
    [_hero changeState:_hero.walkState];
}

// -----------------------------------------------------------------------

- (void)simpleDPad:(SimpleDPad *)simpleDPad isHoldingDirection:(CGPoint)direction
{
    if ([_hero isInState:_hero.knockedOutState]) {
        return;
    }
    _hero.direction = direction;
    [_hero changeState:_hero.walkState];
}

// -----------------------------------------------------------------------

- (void)simpleDPadTouchEnded:(SimpleDPad *)simpleDPad
{
    if ([_hero isInState:_hero.knockedOutState]) {
        return;
    }
    [_hero changeState:_hero.idleState];
}

// -----------------------------------------------------------------------
#pragma mark - Touch Events
// -----------------------------------------------------------------------

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if ([_hero isInState:_hero.knockedOutState]) {
        return;
    }
    [_hero changeState:_hero.attackState];
}

// -----------------------------------------------------------------------
@end
