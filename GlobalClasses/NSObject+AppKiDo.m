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

- (void)ak_printSequenceUsingSelector:(SEL)nextObjectSelector
{
    NSString *selectorName = NSStringFromSelector(nextObjectSelector);
    NSObject *obj = self;
    NSMutableSet *pointersToVisitedObjects = [NSMutableSet set];

    NSLog(@"BEGIN %@ sequence:", selectorName);
    while (YES)
    {
        // Log the object.
        NSLog(@"  <%@: %p>", obj.className, obj);

        // Have we encountered this view before?
        NSValue *objWrapper = [NSValue valueWithNonretainedObject:obj];

        if ([pointersToVisitedObjects containsObject:objWrapper])
        {
            NSLog(@"END %@ sequence -- sequence contains a loop", selectorName);
            break;
        }

        [pointersToVisitedObjects addObject:objWrapper];

        // Have we reached the end of the chain?
        //disable warning:"PerformSelector may cause a leak because its selector is unknown"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        obj = [obj performSelector:nextObjectSelector];
#pragma clang diagnostic pop
        if (obj == nil)
        {
            NSLog(@"END %@ sequence -- sequence ends with nil", selectorName);
            break;
        }
    }
}

@end
