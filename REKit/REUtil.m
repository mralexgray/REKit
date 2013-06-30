/* REUtil.m Copyright ©2012 Kazki Miura. All rights reserved.	*/

#import "REUtil.h"
#if __has_feature(objc_arc)
	#error This code needs compiler option -fno-objc-arc
#endif
#pragma mark - NSString
NSString* REUUIDString()	{
#if (__MAC_OS_X_VERSION_MIN_REQUIRED >= 1080 || __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000)
	return [[NSUUID UUID] UUIDString];
#else
	CFUUIDRef uuid = CFUUIDCreate(NULL);
	NSString* uuidString  = (NSString*)CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
	CFRelease(uuid);
	return uuidString;
#endif
}
#pragma mark Block
const char* REBlockGetObjCTypes(id _block)	{
	// Get descriptor of block
	struct Block *block = (struct Block*)_block;
	struct BlockDescriptor *descriptor = block->descriptor;
	// Get index of rest
	int index = 0;
	if (block->flags & BLOCK_HAS_COPY_DISPOSE) index += 2;
	return descriptor->rest[index];
}
void* REBlockGetImplementation (id  block)	{	return ((struct Block*)block)->invoke;	}
#pragma mark - NSMethodSignature
@implementation NSMethodSignature (REUtil)
- (const char*)objCTypes	{
	NSMutableString *objCTypes = NSMutableString.string;
	[objCTypes appendString:[NSString stringWithCString:self.methodReturnType encoding:NSUTF8StringEncoding]];
	for (NSUInteger i = 0; i < self.numberOfArguments; i++)
		[objCTypes appendString:[NSString stringWithCString:[self getArgumentTypeAtIndex:i] encoding:NSUTF8StringEncoding]];
	return objCTypes.UTF8String;
}
- (NSString*)description	{
	return [NSString stringWithFormat:@"<%@: %p> %s", NSStringFromClass(self.class), self, self.objCTypes];
}																								@end
#pragma mark - NSObject
@implementation NSObject (REUtil)
- (void)willChangeClass:(Class)toClass		{	// Post notification
	[NSNotificationCenter.defaultCenter postNotificationName:REObjectWillChangeClassNotification object:self userInfo:@{
		REObjectOldClassNameKey : NSStringFromClass(self.class),	REObjectNewClassNameKey : NSStringFromClass(toClass)}];
}
- (void)didChangeClass: (Class)fromClass	{	// Post notification
	[NSNotificationCenter.defaultCenter postNotificationName:REObjectDidChangeClassNotification object:self userInfo:@{
		REObjectOldClassNameKey : NSStringFromClass(fromClass), REObjectNewClassNameKey : NSStringFromClass(self.class) }];
}
- (void)associateValue: (id)value forKey:(void*)key policy:(objc_AssociationPolicy)policy	{
	objc_setAssociatedObject(self, key, value, policy);
}
- (id)associatedValueForKey:(void*)key		{	return objc_getAssociatedObject(self, key);	}																			@end
#pragma mark - NSObject (REKitPrivate)
@implementation NSObject (REKitPrivate)
+ (void)exchangeClassMethodWithOriginalSelector:	 (SEL)originalSelector newSelector:(SEL)newSelector															{
	// Exchange
	Method originalMethod = NULL; 	originalMethod = class_getClassMethod(self, originalSelector);
	Method newMethod = NULL;			newMethod	 	= class_getClassMethod(self, newSelector);
	if (newMethod != NULL && originalMethod != NULL) method_exchangeImplementations(originalMethod, newMethod);
}
+ (void)exchangeInstanceMethodWithOriginalSelector: (SEL)originalSelector newSelector:(SEL)newSelector														{
	// Exchange
	Method originalMethod = NULL; originalMethod = class_getInstanceMethod(self, originalSelector);
	Method newMethod = NULL;			  newMethod = class_getInstanceMethod(self, newSelector);
	if (newMethod != NULL && originalMethod != NULL) method_exchangeImplementations(originalMethod, newMethod);
}
+ (void)exchangeClassMethodsWithAdditiveSelectorPrefix:   (NSString*)prefix selectors:(SEL)originalSelector, ... NS_REQUIRES_NIL_TERMINATION		{
	// Enumerate selectors
	SEL aSelector;
	va_list args;
	va_start(args, originalSelector);
	aSelector = originalSelector;
	while (aSelector) {
		// Exchange
		Method originalMethod = NULL; originalMethod = class_getClassMethod(self, aSelector);
		Method newMethod = NULL;			  newMethod = class_getClassMethod(self, NSSelectorFromString([prefix stringByAppendingString:NSStringFromSelector(aSelector)]));
		if (newMethod != NULL && originalMethod != NULL) method_exchangeImplementations(originalMethod, newMethod);
		// Get next selector
		aSelector = va_arg(args, SEL);
	}
	va_end(args);
}
+ (void)exchangeInstanceMethodsWithAdditiveSelectorPrefix:(NSString*)prefix selectors:(SEL)originalSelector, ... NS_REQUIRES_NIL_TERMINATION	{
	// Enumerate selectors
	SEL aSelector;
	va_list args;
	va_start(args, originalSelector);
	aSelector = originalSelector;
	while (aSelector) {
		// Exchange
		Method originalMethod = NULL; originalMethod = class_getInstanceMethod(self, aSelector);
		Method newMethod = NULL;			  newMethod = class_getInstanceMethod(self, NSSelectorFromString([prefix stringByAppendingString:NSStringFromSelector(aSelector)]));
		if (newMethod != NULL && originalMethod != NULL) method_exchangeImplementations(originalMethod, newMethod);
		
		// Get next selector
		aSelector = va_arg(args, SEL);
	}
	va_end(args);
}
																																		@end

//// Notifications
//NSString* const REObjectWillChangeClassNotification = @"REObjectWillChangeClassNotification";
//NSString* const REObjectDidChangeClassNotification = @"REObjectDidChangeClassNotification";
//// Keys for userInfo of notifications above
//NSString* const REObjectOldClassNameKey = @"REObjectOldClassNameKey";
//NSString* const REObjectNewClassNameKey = @"REObjectNewClassNameKey";
