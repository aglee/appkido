//
//  AKFunctionTokenCluster.m
//  AppKiDo
//
//  Created by Andy Lee on 5/19/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKFunctionTokenCluster.h"
#import "AKFunctionToken.h"
#import "DocSetModel.h"

@implementation AKFunctionTokenCluster

- (AKToken *)tokenWithTokenMO:(DSAToken *)tokenMO
{
    return [[AKFunctionToken alloc] initWithTokenMO:tokenMO];
}

@end
