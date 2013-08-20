//
//  AKSQLTemplate.h
//  AppKiDo
//
//  Created by Andy Lee on 2/7/12.
//  Copyright 2012 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
 * Loads SQL query templates from .sql files in the application bundle.
 * Using .sql files is more convenient than using NSString literals because
 * they can be broken up into multiple lines and indented for readability.
 * Breaking up and manually indenting NSString literals means you have to
 * remember not to apply Xcode's autoindenting. Also you can't copy-paste
 * the broken-up NSString into, say the sqlite3 command line or a GUI that
 * executes sqlite queries. And you can open the .sql file in programs that
 * provide syntax-highlighting.
 */
@interface AKSQLTemplate : NSObject

+ (NSString *)templateNamed:(NSString *)templateName;

@end
