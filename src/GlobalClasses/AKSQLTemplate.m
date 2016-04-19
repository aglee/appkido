//
//  AKSQLTemplate.m
//  AppKiDo
//
//  Created by Andy Lee on 2/7/12.
//  Copyright 2012 Andy Lee. All rights reserved.
//

#import "AKSQLTemplate.h"

@implementation AKSQLTemplate

// For each line:
//  Removes leading and trailing whitespace.
//  If the resulting line begins with "--", discards the line.
// Joins the resulting lines with " ".
//+ (NSString *)_collapseSQL:(NSString *)sql
//{
//    NSMutableArray *trimmedLines = [NSMutableArray array];
//    
//    for (NSString *line in [sql componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]])
//    {
//        line = [line ak_trimWhitespace];
//        
//        if (![line hasPrefix:@"--"])
//        {
//            [trimmedLines addObject:line];
//        }
//    }
//    
//    return [trimmedLines componentsJoinedByString:@" "];
//}

+ (NSString *)templateNamed:(NSString *)templateName
{
    static NSMutableDictionary *s_sqlTemplatesByName = nil;
    
    if (s_sqlTemplatesByName == nil)
    {
        s_sqlTemplatesByName = [[NSMutableDictionary alloc] init];
    }
    
    NSString *sqlTemplate = s_sqlTemplatesByName[templateName];
    
    if (sqlTemplate == nil)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:templateName ofType:@"sql"];
        
        if (path)
        {
            sqlTemplate = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
            
            if (sqlTemplate)
            {
                s_sqlTemplatesByName[templateName] = sqlTemplate;
            }
        }
    }
    
    return sqlTemplate;
}

@end
