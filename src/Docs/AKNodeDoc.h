//
//  AKNodeDoc.h
//  AppKiDo
//
//  Created by Andy Lee on 8/24/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKDoc.h"

@class AKTokenItem;

@interface AKNodeDoc : AKDoc
{
@private
    AKTokenItem *_tokenItem;
}

@property (nonatomic, readonly) AKTokenItem *tokenItem;

#pragma mark -
#pragma mark Init/awake/dealloc

/*! Designated initializer. */
- (instancetype)initWithNode:(AKTokenItem *)tokenItem NS_DESIGNATED_INITIALIZER;

@end
