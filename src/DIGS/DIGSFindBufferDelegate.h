//
//  DIGSFindBufferDelegate.h
//  AppKiDo
//
//  Created by Andy Lee on 2/25/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DIGSFindBuffer;

@protocol DIGSFindBufferDelegate <NSObject>
@required
- (void)findBufferDidChange:(DIGSFindBuffer *)findBuffer;
@end
