//
//  AKDatabase+ImportFrameworks.m
//  AppKiDo
//
//  Created by Andy Lee on 5/28/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKDatabase+Private.h"
#import "AKFramework.h"
#import "AKManagedObjectQuery.h"
#import "AKNamedObjectGroup.h"
#import "AKRegexUtils.h"
#import "AKResult.h"
#import "DIGSLog.h"
#import "NSString+AppKiDo.h"

@implementation AKDatabase (ImportFrameworks)

#pragma mark - Importing frameworks

- (void)_importFrameworks
{
	AKManagedObjectQuery *query = [self _queryWithEntityName:@"Header"];
	query.keyPaths = @[ @"frameworkName" ];
	query.predicate = [NSPredicate predicateWithFormat:@"frameworkName != NULL"];

	AKResult *result = [query fetchDistinctObjects];  //TODO: Handle error.
	if (result.error) {
		return;
	}

	NSArray *fetchedObjects = result.object;
	for (NSDictionary *dict in fetchedObjects) {
		(void)[self _getOrAddFrameworkWithName:dict[@"frameworkName"]];
	}
}

#pragma mark - Inferring framework info

- (AKFramework *)_getOrAddFrameworkWithName:(NSString *)frameworkName
{
	if (frameworkName == nil) {
		return nil;
	}
	
	AKFramework *framework = [self frameworkWithName:frameworkName];
	if (framework == nil) {
		framework = [[AKFramework alloc] initWithName:frameworkName];
		[self.frameworksGroup addNamedObject:framework];
		//QLog(@"+++ Added framework %@.", frameworkName);
	}
	return framework;
}

@end
