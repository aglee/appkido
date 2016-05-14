//
//  AKNamed.h
//  AppKiDo
//
//  Created by Andy Lee on 5/14/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AKNamed <NSObject>

@required

@property (copy, readonly) NSString *name;
@property (copy, readonly) NSString *sortName;
@property (copy, readonly) NSString *displayName;

@end
