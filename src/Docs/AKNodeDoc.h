//
//  AKNodeDoc.h
//  AppKiDo
//
//  Created by Andy Lee on 8/24/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKDoc.h"

@class AKDocSetTokenItem;

@interface AKNodeDoc : AKDoc
{
@private
    AKDocSetTokenItem *_tokenItem;
}

@property (nonatomic, readonly) AKDocSetTokenItem *tokenItem;

#pragma mark -
#pragma mark Init/awake/dealloc

/*! Designated initializer. */
- (instancetype)initWithNode:(AKDocSetTokenItem *)tokenItem NS_DESIGNATED_INITIALIZER;

@end
