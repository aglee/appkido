//
//  AKNamedObject.h
//  AppKiDo
//
//  Created by Andy Lee on 5/12/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKNamed.h"

/*!
 * Trivial implementation of the AKNamed protocol.  Stores name in an ivar.
 * Both sortName and displayName return self.name.
 */
@interface AKNamedObject : NSObject <AKNamed>

- (instancetype)initWithName:(NSString *)name NS_DESIGNATED_INITIALIZER;

@end
