/*
 * AKCocoaFunctionsDocParser.m
 *
 * Created by Andy Lee on Sun Mar 28 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKCocoaFunctionsDocParser.h"

#import <DIGSLog.h>

#import "AKTextUtils.h"
#import "AKDatabase.h"
#import "AKFunctionNode.h"
#import "AKGroupNode.h"
#import "AKFileSection.h"

//-------------------------------------------------------------------------
// Forward declarations of private methods
//-------------------------------------------------------------------------

@interface AKCocoaFunctionsDocParser (Private)
- (NSDictionary *)_mapFunctionNamesToGroupNames;
@end


@implementation AKCocoaFunctionsDocParser

//-------------------------------------------------------------------------
// AKDocParser methods
//-------------------------------------------------------------------------

- (void)applyParseResults
{
    // Make sure the current doc file has a "Functions" section.
    AKFileSection *functionsSection =
        [_rootSectionOfCurrentFile childSectionWithName:@"Functions"];
    
    if (functionsSection == nil)
    {
        return;
    }

//NSLog(@"\n\n\n---------- %@ ----------", [self currentPath]);  // [agl] REMOVE
    // Scan the "Functions by Task" section, and remember what group each
    // function belongs to.
    // Note that there may not *be* a "Functions by Task" section.  For example,
    // as of now, there isn't one in the AddressBook functions doc.  In that
    // case, we create a group named "Functions".
    // Note also that in theory the functions in a group may be spread across
    // multiple files.
    NSDictionary *groupNamesByFunctionName = [self _mapFunctionNamesToGroupNames];
    NSString *defaultGroupName = nil;

    if ([groupNamesByFunctionName count] == 0)
    {
        defaultGroupName =
            [@"Functions - "
                stringByAppendingString:
                    [[_rootSectionOfCurrentFile sectionName] ak_firstWord]];
//NSLog(@"using default '%@' group name", defaultGroupName);  // [agl] REMOVE
    }

    // Each subsection of the "Functions" section contains the documentation
    // for one function.
    NSEnumerator *functionSectionsEnum =
        [functionsSection childSectionEnumerator];
    AKFileSection *functionSection;
    
    while ((functionSection = [functionSectionsEnum nextObject]))
    {
        NSString *functionName = [functionSection sectionName];
        NSString *groupName =
            defaultGroupName
            ? defaultGroupName
            : [groupNamesByFunctionName objectForKey:functionName];

        if (groupName == nil)
        {
            DIGSLogWarning(@"couldn't find group name for function named %@",
                           functionName);
        }
        else
        {
            AKFunctionNode *functionNode =
                [[[AKFunctionNode alloc]
                    initWithNodeName:functionName
                    owningFramework:_frameworkName] autorelease];
            [functionNode setNodeDocumentation:functionSection];

            AKGroupNode *groupNode =
                [_databaseBeingPopulated
                    functionsGroupWithName:groupName
                    inFramework:_frameworkName];

            if (!groupNode)
            {
                groupNode =
                    [[AKGroupNode alloc]
                        initWithNodeName:groupName
                        owningFramework:_frameworkName];
                [groupNode setNodeDocumentation:functionSection];
                [_databaseBeingPopulated addFunctionsGroup:groupNode];
            }

            [groupNode addSubnode:functionNode];
        }
    }
}

@end


//-------------------------------------------------------------------------
// Private methods
//-------------------------------------------------------------------------

@implementation AKCocoaFunctionsDocParser (Private)

// Keys of the returned dictionary will be function names, values will be
// the group node the function needs to be added to.
- (NSDictionary *)_mapFunctionNamesToGroupNames
{
    NSMutableDictionary *groupNamesByFunctionName = [NSMutableDictionary dictionary];
    
    // Each subsection of the "Functions by Task" section corresponds to a
    // function group.
    AKFileSection *functionsByTaskSection =
        [_rootSectionOfCurrentFile childSectionWithName:@"Functions by Task"];
    
    if (functionsByTaskSection != nil)
    {
        NSEnumerator *functionGroupSectionsEnum =
            [functionsByTaskSection childSectionEnumerator];
        AKFileSection *functionGroupSection;
        
        while ((functionGroupSection = [functionGroupSectionsEnum nextObject]))
        {
            // Temporarily take over the _current and _dataEnd ivars for our own use.
            const char *originalCurrent = _current;
            const char *originalDataEnd = _dataEnd;
            _current = _dataStart + [functionGroupSection sectionOffset];
            _dataEnd = _current + [functionGroupSection sectionLength];
            
            // The function names are listed in a <ul> element.
            if ((_current = strnstr(_current, "<ul", _dataEnd - _current)))
            {
                // Each function name is the first <code> element in an <li> element.
                while ((_current = strnstr(_current, "<li", _dataEnd - _current)))
                {
                    if (!(_current = strnstr(_current, "<code", _dataEnd - _current)))
                    {
                        break;
                    }
                    else
                    {
                        if (![self parseNonMarkupToken])
                        {
                            break;
                        }
                        else
                        {
                            NSString *funcName = [NSString stringWithUTF8String:_token];
                            [groupNamesByFunctionName
                                setObject:[functionGroupSection sectionName]
                                forKey:funcName];
                        }
                    }
                }
            }
            
            // Restore _current and _dataEnd to their values when we entered this method.
            _current = originalCurrent;
            _dataEnd = originalDataEnd;
        }
    }
    
    return groupNamesByFunctionName;
}

@end


