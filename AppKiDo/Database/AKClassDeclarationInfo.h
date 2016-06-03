//
//  AKClassDeclarationInfo.h
//  AppKiDo
//
//  Created by Andy Lee on 6/2/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AKClassDeclarationInfo : NSObject
@property (copy) NSString *nameOfClass;
@property (copy) NSString *nameOfSuperclass;
@property (copy) NSString *frameworkName;
@property (copy) NSString *headerPath;
@property (assign) BOOL headerPathIsRelativeToSDK;
@end
