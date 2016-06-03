//
//  AKClassDeclarationInfo.m
//  AppKiDo
//
//  Created by Andy Lee on 6/2/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKClassDeclarationInfo.h"

@implementation AKClassDeclarationInfo

#pragma mark - NSObject methods

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p -- %@ : %@ (%@)>",
			self.className, self,
			self.nameOfClass, self.nameOfSuperclass, self.frameworkName];
}

@end
