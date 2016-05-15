/*
 * AKMembersSubtopic.h
 *
 * Created by Andy Lee on Tue Jul 09 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

/*!
 * This class is obsolete.  I'm keeping it around because I might want to use
 * the code in it for including all of a behavior's members of a given type,
 * including those inherited from ancestors.  Offhand I'm thinking that logic
 * should go into AKBehaviorToken and/or maybe its subclasses.
 */
@interface AKMembersSubtopic : NSObject
@end
