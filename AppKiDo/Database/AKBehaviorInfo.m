//
//  AKBehaviorInfo.m
//  AppKiDo
//
//  Created by Andy Lee on 5/23/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKBehaviorInfo.h"

@implementation AKBehaviorInfo

#pragma mark - NSObject methods

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p class='%@' category='%@' protocol='%@'>",
			self.className, self, self.nameOfClass, self.nameOfCategory, self.nameOfProtocol];
}

@end
