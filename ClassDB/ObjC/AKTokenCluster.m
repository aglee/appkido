//
//  AKTokenCluster.m
//  AppKiDo
//
//  Created by Andy Lee on 5/19/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKTokenCluster.h"
#import "AKToken.h"
#import "DocSetModel.h"

@implementation AKTokenCluster

- (AKToken *)tokenWithTokenMO:(DSAToken *)tokenMO
{
    return [[AKToken alloc] initWithTokenMO:tokenMO];
}

@end
