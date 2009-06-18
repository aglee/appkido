//
// AKProtocolNode.h
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKBehaviorNode.h"

/*!
 * @class       AKProtocolNode
 * @abstract    Represents an Objective-C protocol.
 * @discussion  Represents an Objective-C protocol.  The protocol can be
 *              either formal or informal.  A protocol is assumed to be
 *              informal if no header file has been specified for it.
 *
 *              An AKProtocolNode's -nodeName is the name of the protocol
 *              it represents.
 */
@interface AKProtocolNode : AKBehaviorNode
{
}

- (BOOL)isInformal;

@end
