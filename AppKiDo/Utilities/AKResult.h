//
//  AKResult.h
//  AppKiDo
//
//  Created by Andy Lee on 5/18/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

//TODO: Consider using generics for the object property.

/*!
 * self.object is or self.error is non-nil, not both.  Both may be nil.
 */
@interface AKResult : NSObject

@property (strong, readonly) id object;
@property (strong, readonly) NSError *error;

/*! obj may be nil.  The returned result */
+ (AKResult *)successResultWithObject:(id)obj;

/*! error must not be nil. */
+ (AKResult *)failureResultWithError:(NSError *)error;
+ (AKResult *)failureResultWithErrorDomain:(NSString *)domain
									  code:(NSInteger)code
							   description:(NSString *)desc;

@end
