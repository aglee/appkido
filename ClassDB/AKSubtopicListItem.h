//
//  AKSubtopicListItem.h
//  AppKiDo
//
//  Created by Andy Lee on 5/15/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKNamed.h"

@protocol AKDocListItem;

@protocol AKSubtopicListItem <AKNamed>

@required

@property (copy, readonly) NSArray *docListItems;

/*! Returns -1 if none found. */
- (NSInteger)indexOfDocWithName:(NSString *)docName;
- (id<AKDocListItem>)docAtIndex:(NSInteger)docIndex;
- (id<AKDocListItem>)docWithName:(NSString *)docName;

@end
