/*
 NSObject+REObserver.h
 
 Copyright ©2012 Kazki Miura. All rights reserved.
*/

#import <Foundation/Foundation.h>


// Keys for observingInfo and observedInfo
//extern NSString* const REObserverObservedObjectPointerValueKey; // Observed object is observed. Only observingInfo contains this entry.
//extern NSString* const REObserverObservingObjectPointerValueKey; // Observing object is observing. Only observedInfo contains this entry.
//extern NSString* const REObserverKeyPathKey;
//extern NSString* const REObserverOptionsKey;
//extern NSString* const REObserverContextPointerValueKey;
//extern NSString* const REObserverBlockKey;
//extern NSString* const REObserverContainerKey; // Container of observed object. When you use [array addObserver:toObjectsAtIndexes:forKeyPath:options:context:], array is set to this entry.

#define kObservingInfosAssociationKey 					@"REObserver_observingInfos"
#define kObservedInfosAssociationKey					@"REObserver_observedInfos"

// Keys for observing/observedInfo
#define REObserverObservedObjectPointerValueKey	 	@"observedObjectPointerValue"
#define REObserverObservingObjectPointerValueKey	@"observingObjectPointerValue"
#define REObserverKeyPathKey								@"keyPath"
#define REObserverOptionsKey								@"options"
#define REObserverContextPointerValueKey 				@"contextPointerValue"
#define REObserverBlockKey 								@"block"
#define REObserverContainerKey	 						@"container"

// REObserverHandler
typedef void (^REObserverHandler)(NSDictionary *change);

@interface NSObject (REObserver)
- (id)addObserverForKeyPath:(NSString*)keyPath options:(NSKeyValueObservingOptions)options usingBlock:(REObserverHandler)block;
- (NSArray*)observingInfos;
- (NSArray*)observedInfos;
- (void)stopObserving;
@end
