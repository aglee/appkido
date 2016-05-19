//
//  AKFramework.m
//  AppKiDo
//
//  Created by Andy Lee on 5/16/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKFramework.h"
#import "AKFunctionTokenCluster.h"
#import "AKToken.h"
#import "AKNamedObjectGroup.h"

@interface AKFramework ()
@property (strong) NSDictionary *tokenClustersByTokenType;
@end

@implementation AKFramework

#pragma mark - Init/awake/dealloc

- (instancetype)initWithName:(NSString *)name
{
    self = [super initWithName:name];
    if (self) {
        _protocolsGroup = [[AKNamedObjectGroup alloc] initWithName:@"Protocols"];
        _constantsCluster = [[AKTokenCluster alloc] initWithName:@"Constants"];
        _enumsCluster = [[AKTokenCluster alloc] initWithName:@"Enums"];
        _functionsCluster = [[AKFunctionTokenCluster alloc] initWithName:@"Functions"];
        _macrosCluster = [[AKTokenCluster alloc] initWithName:@"Macros"];
        _typedefsCluster = [[AKTokenCluster alloc] initWithName:@"Typedefs"];
        _tokenClustersByTokenType = @{
                                      @"data": _constantsCluster,
                                      @"econst": _enumsCluster,
                                      @"func": _functionsCluster,
                                      @"macro": _macrosCluster,
                                      @"tdef": _typedefsCluster,
                                      };
    }
    return self;
}

@end
