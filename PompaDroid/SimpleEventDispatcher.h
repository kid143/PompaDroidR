//
//  MessageDispatcher.h
//  PompaDroid
//
//  Created by kid143 on 14-5-30.
//  Copyright (c) 2014年 kid143. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SEND_IMMEDIATELY 0
#define NO_ADDITIONAL_INFO nil

@class Event;

@protocol EventHandler <NSObject>

- (BOOL)handleEvent:(Event *)event;

@end

@interface Event : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSDate *dispatchTime;
@property (nonatomic, strong) id extraInfo;

+ (instancetype)newMessageWithName:(NSString *)name
                      dispatchTime:(NSDate *)dispatchTime
                         extraInfo:(id)extra;

@end

@interface SimpleEventDispatcher : NSObject

{
    NSMutableSet *_priorityQ;
    NSMutableDictionary *_registeredHandlers;
}

+ (id)sharedInstance;

- (void)registerHandler:(id <EventHandler>)handler
               forEvent:(NSString *)eventName;
- (void)removeHandler:(id <EventHandler>)handler
             forEvent:(NSString *)eventName;

- (void)discharge:(Event *)event;
- (void)dispatchEvent:(NSString *)name
         delay:(NSTimeInterval)delay
            extraInfo:extra;
- (void)dispatchDelayedEvents;

@end
