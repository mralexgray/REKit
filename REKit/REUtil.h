/* REUtil.h Copyright ©2012 Kazki Miura. All rights reserved.	*/

#import <Foundation/Foundation.h>
#import <objc/runtime.h>


// Notifications
#define REObjectWillChangeClassNotification 	@"REObjectWillChangeClassNotification"
#define REObjectDidChangeClassNotification	@"REObjectDidChangeClassNotification"

// Keys for userInfo of notifications above
#define REObjectOldClassNameKey 	@"REObjectOldClassNameKey"
#define REObjectNewClassNameKey 	@"REObjectNewClassNameKey"
																					// Notifications
//extern NSString* const REObjectWillChangeClassNotification,
//					* const REObjectDidChangeClassNotification,
//																					// Keys for userInfo of notifications above
//					* const REObjectOldClassNameKey,
//					* const REObjectNewClassNameKey;

#pragma mark   Block
struct BlockDescriptor	{	unsigned long reserved;	unsigned long size;	void *rest[1];	}; 					// BlockDescriptor
struct Block				{	void *isa;	int flags;	int reserved;	void *invoke;	struct BlockDescriptor *descriptor;	}; // Block
typedef NS_ENUM(NSUInteger, BLOCK_FLAG) { 																					// Flags of Block
	BLOCK_HAS_COPY_DISPOSE 	= (1 << 25),	BLOCK_HAS_CTOR 			= (1 << 26), // helpers have C++ code
	BLOCK_IS_GLOBAL			= (1 << 28),	BLOCK_HAS_STRET 			= (1 << 29), // IFF BLOCK_HAS_SIGNATURE
	BLOCK_HAS_SIGNATURE 		= (1 << 30)
};
extern const char* REBlockGetObjCTypes(id block);		extern void* REBlockGetImplementation(id block);
#pragma mark - NSInvocation
@interface NSInvocation (REUtil)			- (void)invokeUsingIMP:(IMP)imp;																	@end
#pragma mark - NSMethodSignature
@interface NSMethodSignature (REUtil)	- (const char*)objCTypes;	- (NSString*)description;										@end
#pragma mark - NSObject
@interface NSObject (REUtil)
- (void)willChangeClass:(Class)toClass;	- (void)didChangeClass:(Class)fromClass;		// Class Exchange
// Association
- (void)associateValue:(id)v forKey:(void*)k policy:(objc_AssociationPolicy)p;	- (id)associatedValueForKey:(void*)k;	@end
#pragma mark - NSObject (REKitPrivate)
@interface NSObject (REKitPrivate)																								// Method Exchange
+ (void)exchangeClassMethodWithOriginalSelector:				(SEL)orig   newSelector:(SEL)newSel;
+ (void)exchangeInstanceMethodWithOriginalSelector:			(SEL)orig   newSelector:(SEL)newSel;
+ (void)exchangeClassMethodsWithAdditiveSelectorPrefix:	 (NSString*)prfx selectors:(SEL)orig, ... NS_REQUIRES_NIL_TERMINATION;
+ (void)exchangeInstanceMethodsWithAdditiveSelectorPrefix:(NSString*)prfx selectors:(SEL)orig, ... NS_REQUIRES_NIL_TERMINATION;
@end
#pragma mark - NSString
#define RE_LINE [NSString stringWithFormat:@"%s-l.%i", __PRETTY_FUNCTION__, __LINE__]
extern NSString* REUUIDString();
