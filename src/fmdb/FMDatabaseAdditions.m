//
//  FMDatabaseAdditions.m
//  fmkit
//
//  Created by August Mueller on 10/30/05.
//  Copyright 2005 Flying Meat Inc.. All rights reserved.
//

#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

@implementation FMDatabase (FMDatabaseAdditions)

- (NSString*) stringForQuery:(NSString*)objs, ...; {
    
    FMResultSet *rs = [self executeQuery:objs];
    
    if (![rs next]) {
        return nil;
    }
    
    NSString *ret = [rs stringForColumnIndex:0];
    
    // clear it out.
    [rs close];
    
    return ret;
}

- (int) intForQuery:(NSString*)objs, ...; {
    
    FMResultSet *rs = [self executeQuery:objs];
    
    if (![rs next]) {
        return 0;  // [agl] handle end-of-resultset better
    }
    
    int ret = [rs intForColumnIndex:0];
    
    // clear it out.
    [rs close];
    
    return ret;
}

- (long) longForQuery:(NSString*)objs, ...; {
    
    FMResultSet *rs = [self executeQuery:objs];
    
    if (![rs next]) {
        return 0;  // [agl] handle end-of-resultset better
    }
    
    long ret = [rs longForColumnIndex:0];
    
    // clear it out.
    [rs close];
    
    return ret;
}

- (BOOL) boolForQuery:(NSString*)objs, ...; {
    
    FMResultSet *rs = [self executeQuery:objs];
    
    if (![rs next]) {
        return 0;  // [agl] handle end-of-resultset better
    }
    
    BOOL ret = [rs boolForColumnIndex:0];
    
    // clear it out.
    [rs close];
    
    return ret;
}

- (double) doubleForQuery:(NSString*)objs, ...; {
    
    FMResultSet *rs = [self executeQuery:objs];
    
    if (![rs next]) {
        return 0;  // [agl] handle end-of-resultset better
    }
    
    double ret = [rs doubleForColumnIndex:0];
    
    // clear it out.
    [rs close];
    
    return ret;
}

- (NSData*) dataForQuery:(NSString*)objs, ...; {
    
    FMResultSet *rs = [self executeQuery:objs];
    
    if (![rs next]) {
        return nil;
    }
    
    NSData *data = [rs dataForColumnIndex:0];
    
    // clear it out.
    [rs close];
    
    return data;
}

@end
