//
//  DocSetIndex.h
//  AppKiDo
//
//  Created by Andy Lee on 4/17/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DocSetModel.h"

@interface DocSetIndex : NSObject

@property (readonly, copy, nonatomic) NSString *docSetPath;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, copy, nonatomic) NSURL *documentsBaseURL;
@property (readonly, copy, nonatomic) NSURL *headerFilesBaseURL;

#pragma mark - Init/awake/dealloc

/*! docSetPath must be a path to a .docset bundle. */
- (instancetype)initWithDocSetPath:(NSString *)docSetPath NS_DESIGNATED_INITIALIZER;

@end
