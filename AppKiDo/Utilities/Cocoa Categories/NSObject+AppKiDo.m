//
//  NSObject+AppKiDo.m
//  AppKiDo
//
//  Created by Andy Lee on 3/10/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import "NSObject+AppKiDo.h"
#import "NSString+AppKiDo.h"

@implementation NSObject (AppKiDo)

- (NSString *)ak_bareDescription
{
	return [NSString stringWithFormat:@"<%@: %p>", self.className, self];
}

- (void)ak_printSequenceWithValuesForKeyPaths:(NSArray *)keyPathsToPrint
							nextObjectKeyPath:(NSString *)nextObjectKeyPath
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

- (void)ak_printTreeWithValuesForKeyPaths:(NSArray *)keyPathsToPrint
					  childObjectsKeyPath:(NSString *)childObjectsKeyPath
{
	[self _printTreeWithValuesForKeyPaths:keyPathsToPrint
					  childObjectsKeyPath:childObjectsKeyPath
							  indentLevel:0];
}

#pragma mark - Private methods

- (void)_printTreeWithValuesForKeyPaths:(NSArray *)keyPathsToPrint
					childObjectsKeyPath:(NSString *)childObjectsKeyPath
							indentLevel:(NSUInteger)indentLevel
{
	// Print info for self.
	NSLog(@"%@", [self _stringToPrintForKeyPaths:keyPathsToPrint indentLevel:indentLevel]);

	// Print info for each of self's descendant objects.
	for (id childObject in [self valueForKeyPath:childObjectsKeyPath]) {
		[childObject _printTreeWithValuesForKeyPaths:keyPathsToPrint
								 childObjectsKeyPath:childObjectsKeyPath
										 indentLevel:(indentLevel + 1)];
	}
}

- (NSString *)_stringToPrintForKeyPaths:(NSArray *)keyPathsToPrint
							indentLevel:(NSUInteger)indentLevel
{
	NSMutableString *infoString = [NSMutableString string];

	// Indentation.
	[infoString appendString:[NSString ak_stringByRepeating:@"\t" times:indentLevel]];

	// Minimal info about self.
	[infoString appendFormat:@"%@: %p", self.className, self];

	// Values for the given key paths, if any.
	for (NSString *keyPath in keyPathsToPrint) {
		[infoString appendFormat:@" %@=%@", keyPath, [self valueForKeyPath:keyPath]];
	}

	return infoString;
}

@end
