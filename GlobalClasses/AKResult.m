//
//  AKResult.m
//  AppKiDo
//
//  Created by Andy Lee on 5/18/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKResult.h"
#import "QuietLog.h"

@interface AKSuccessResult : AKResult
@property (strong) id object;
@end

@implementation AKSuccessResult
@synthesize object = _object;
- (NSError *)error { return nil; }
@end

@interface AKFailureResult : AKResult
@property (strong) NSError *error;
@end

@implementation AKFailureResult
@synthesize error = _error;
- (id)object { return nil; }
@end

#pragma mark -

@implementation AKResult

+ (AKResult *)successResultWithObject:(id)obj
{
    AKSuccessResult *result = [[AKSuccessResult alloc] init];
    result.object = obj;
    return result;
}

+ (AKResult *)failureResultWithError:(NSError *)error
{
    NSParameterAssert(error != nil);
    QLog(@"+++ [ERROR] %@", error);
    AKFailureResult *result = [[AKFailureResult alloc] init];
    result.error = error;
    return result;
}

+ (AKResult *)failureResultWithErrorDomain:(NSString *)domain
                                      code:(NSInteger)code
                               description:(NSString *)desc
{
    NSError *error = [NSError errorWithDomain:domain
                                         code:code
                                     userInfo:@{ NSLocalizedDescriptionKey : desc }];
    return [self failureResultWithError:error];
}

@end
