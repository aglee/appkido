/*
 * AKFunctionsSubtopic.m
 *
 * Created by Andy Lee on Sun May 30 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import "AKFunctionsSubtopic.h"

#import "AKFileSection.h"
#import "AKGroupNode.h"
#import "AKFunctionDoc.h"

@implementation AKFunctionsSubtopic

//-------------------------------------------------------------------------
// AKSubtopic methods
//-------------------------------------------------------------------------

- (void)populateDocList:(NSMutableArray *)docList
{
    NSEnumerator *functionEnum = [[_groupNode subnodes] objectEnumerator];
    AKDatabaseNode *functionNode;

    while ((functionNode = [functionEnum nextObject]))
    {
        AKFileSection *functionSection = [functionNode nodeDocumentation];

        if (functionSection != nil)
        {
            AKDoc *newDoc =
                [[[AKFunctionDoc alloc] initWithFileSection:functionSection]
                    autorelease];
            
            [docList addObject:newDoc];
        }
    }


// In the Feb 2007 doc update (and maybe earlier), it's no longer the case
// that subsections of the group section contain individual function docs.
/*
    AKFileSection *fileSection = [_groupNode nodeDocumentation];
    int numChildSections = [fileSection numberOfChildSections];
 
    // In older versions of the ScreenSaver framework's Function docs,
    // the functions were not grouped -- each function was a section
    // unto itself.
    if (numChildSections == 0)
    {
        AKDoc *newDoc =
            [[[AKFunctionDoc alloc] initWithFileSection:fileSection]
                autorelease];

        [docList addObject:newDoc];
    }
    else
    {
        int i;

        for (i = 0; i < numChildSections; i++)
        {
            AKFileSection *childSection =
                [fileSection childSectionAtIndex:i];
            AKDoc *newDoc =
                [[[AKFunctionDoc alloc] initWithFileSection:childSection]
                    autorelease];

            [docList addObject:newDoc];
        }
    }
*/
}

@end
