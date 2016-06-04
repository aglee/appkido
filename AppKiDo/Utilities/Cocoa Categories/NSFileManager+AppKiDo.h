//
//  NSFileManager+AppKiDo.h
//  AppKiDo
//
//  Created by Andy Lee on 6/3/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (AppKiDo)

- (BOOL)ak_isSymlink:(NSString *)path;

@end
