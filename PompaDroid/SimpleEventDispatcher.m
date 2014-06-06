//
//  MessageDispatcher.m
//  PompaDroid
//
//  Created by kid143 on 14-5-30.
//  Copyright (c) 2014年 kid143. All rights reserved.
//

#import "SimpleEventDispatcher.h"

@interface Event (Private)

@property (nonatomic, strong, readwrite) NSArray *receivers;

@end

@implementation Event

+ (instancetype)newMessageWithName:(NSString *)name
                      dispatchTime:(NSDate *)dispatchTime
                         extraInfo:(id)extra
{
    return [[self alloc] initWithName:name
                         dispatchTime:dispatchTime
                            extraInfo:extra];
}

- (instancetype)initWithName:(NSString *)name
                      dispatchTime:(NSDate *)dispatchTime
                         extraInfo:(id)extra
{
    if ((self = [super init])) {
        self.name = name;
        self.dispatchTime = dispatchTime;
        self.extraInfo = extra;
    }
    return self;
}

@end

@implementation SimpleEventDispatcher

+ (id)sharedInstance
{
    static SimpleEventDispatcher *instance;
    if (!instance) {
        instance = [[self alloc] init];
    }
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _priorityQ = [NSMutableSet set];
        _registeredHandlers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)registerHandler:(id<EventHandler>)handler forEvent:(NSString *)eventName
{
    NSMutableSet *eventHandlers = [_registeredHandlers objectForKey:eventName];
    if (!eventHandlers) {
        eventHandlers = [NSMutableSet set];
        [_registeredHandlers setObject:eventHandlers forKey:eventName];
    }
    [eventHandlers addObject:handler];
}

- (void)removeHandler:(id<EventHandler>)handler forEvent:(NSString *)eventName
{
    NSMutableSet *eventHandlers = [_registeredHandlers objectForKey:eventName];
    if (!eventHandlers || [eventHandlers count] == 0) {
        return;
    }
    [eventHandlers removeObject:handler];
}

- (void)discharge:(Event *)event
{
    NSMutableSet *eventHandlers = [_registeredHandlers objectForKey:event.name];
    if (!eventHandlers || [eventHandlers count] == 0) {
        return;
    }
    
    for (id <EventHandler> handler in eventHandlers) {
        if (![handler handleEvent:event]) {
#ifdef DEBUG
            NSLog(@"Event handler does not handle current event.");
#endif
        }
    }
}

- (void)dispatchEvent:(NSString *)name
         delay:(NSTimeInterval)delay
            extraInfo:(id)extra
{
    NSDate *nowDate = [NSDate date];
    Event *newEvent = [Event newMessageWithName:name dispatchTime:nowDate extraInfo:extra];
    
    if (!newEvent) {
        NSLog(@"Event message receivers must conform to protocol EventHandler.");
    }
    
    if (delay > 0.0f) {
        newEvent.dispatchTime = [newEvent.dispatchTime dateByAddingTimeInterval:delay];
        [_priorityQ addObject:newEvent];
    } else {
        [self discharge:newEvent];
    }
}

- (void)dispatchDelayedEvents
{
    NSDate *nowDate = [NSDate date];
    for (Event *event in _priorityQ) {
        if ([event.dispatchTime compare:nowDate] == NSOrderedDescending ||
            [event.dispatchTime compare:nowDate] == NSOrderedSame) {
            [self discharge:event];
            [_priorityQ removeObject:event];
        }
    }
}

@end
