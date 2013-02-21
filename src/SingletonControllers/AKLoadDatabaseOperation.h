//
//  AKLoadDatabaseOperation.h
//  AppKiDo
//
//  Created by Andy Lee on 2/16/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AKDatabaseDelegate.h>

@class AKDatabase;

/*!
 * This thing is itself an AKDatabaseDelegate. It forwards delegate messages to
 * the "real" delegate ([self databaseDelegate]) on the main thread.
 *
 * Note that we replace whatever delegate [self appDatabase] previously had. In
 * practice, there won't be any previous delegate because this class is used
 * exactly once during app startup. Just saying in case this changes.
 *
 * Also as part of our unholy relationship with AKAppController, we count on the
 * fact that nobody else is going to try to touch appDatabase concurrently with
 * us doing our thing.
 */
@interface AKLoadDatabaseOperation : NSOperation <AKDatabaseDelegate>
{
@private
    AKDatabase *_appDatabase;
    id <AKDatabaseDelegate> _databaseDelegate;
}

@property (nonatomic, strong) AKDatabase *appDatabase;
@property (nonatomic, strong) id <AKDatabaseDelegate> databaseDelegate;

@end
