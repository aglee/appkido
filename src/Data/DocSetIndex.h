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

#pragma mark - Init/awake/dealloc

/*! docSetPath should be a path to a .docset bundle. */
- (instancetype)initWithDocSetPath:(NSString *)docSetPath NS_DESIGNATED_INITIALIZER;

#pragma mark - Fetch requests

/*! sortSpecifiers must contain strings of the form "keyPath" or "keyPath asc" or "keyPath desc", with a space between the keyPath and the sort direction.  Spaces are the only acceptable whitespace.  Extra spaces are ignored.  The "asc"/"desc" is case-insensitive.  sortSpecifiers can be nil. */
- (NSArray *)fetchEntity:(NSString *)entityName sort:(NSArray *)sortSpecifiers predicateFormat:(NSString *)format va_args:(va_list)argList;

- (NSArray *)fetchEntity:(NSString *)entityName sort:(NSArray *)sortSpecifiers where:(NSString *)format, ...;

@end
