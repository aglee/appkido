//
// AKProtocolNode.h
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKBehaviorItem.h"

/*!
 * Represents an Objective-C protocol, either formal or informal.  A protocol is
 * assumed to be informal if no header file has been specified for it.
 */
@interface AKProtocolNode : AKBehaviorItem

@property (nonatomic, readonly, assign)  BOOL isInformal;

@end
