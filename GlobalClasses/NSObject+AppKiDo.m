//
//  NSObject+AppKiDo.m
//  AppKiDo
//
//  Created by Andy Lee on 3/10/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import "NSObject+AppKiDo.h"

@implementation NSObject (AppKiDo)

- (NSString *)ak_bareDescription
{
	return [NSString stringWithFormat:@"<%@: %p>", self.className, self];
}

- (void)ak_printSequenceWithKeyPath:(NSString *)nextObjectKeyPath
{
	NSMutableSet *pointersToVisitedObjects = [NSMutableSet set];

	NSLog(@"BEGIN %@ sequence:", nextObjectKeyPath);
	for (NSObject *obj = self; obj != nil; obj = [obj valueForKeyPath:nextObjectKeyPath]) {
		// Log the object.
		NSLog(@"  <%@: %p>", obj.className, obj);

		// Have we encountered this object before?
		NSValue *objWrapper = [NSValue valueWithNonretainedObject:obj];
		if ([pointersToVisitedObjects containsObject:objWrapper]) {
			NSLog(@"END %@ sequence -- sequence contains a loop", nextObjectKeyPath);
			return;
		}

		// Remember that we encountered this object.
		[pointersToVisitedObjects addObject:objWrapper];
	}
	NSLog(@"END %@ sequence -- sequence ends with nil", nextObjectKeyPath);
}

- (void)ak_printTreeWithSelfKeyPaths:(NSArray *)selfKeyPaths
				 childObjectsKeyPath:(NSString *)childObjectsKeyPath
{
	[self _printTreeWithSelfKeyPaths:selfKeyPaths
				 childObjectsKeyPath:childObjectsKeyPath
							   depth:0];
}

#pragma mark - Private methods

- (void)_printTreeWithSelfKeyPaths:(NSArray *)selfKeyPaths
			   childObjectsKeyPath:(NSString *)childObjectsKeyPath
							 depth:(NSUInteger)depth
{
	// Print info for self.
	NSMutableString *selfString = [NSMutableString string];
	for (NSUInteger indentCount = 0; indentCount < depth; indentCount++) {
		[selfString appendString:@"\t"];
	}
	[selfString appendString:self.className];
	for (NSString *keyPath in selfKeyPaths) {
		[selfString appendFormat:@" %@=%@", keyPath, [self valueForKeyPath:keyPath]];
	}
	NSLog(@"%@", selfString);

	// Print each of self's child objects.
	for (id childObject in [self valueForKeyPath:childObjectsKeyPath]) {
		[childObject _printTreeWithSelfKeyPaths:selfKeyPaths
							childObjectsKeyPath:childObjectsKeyPath
										  depth:(depth + 1)];
	}
}

@end
