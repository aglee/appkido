/*
 * AKOldLinkResolver.m
 *
 * Created by Andy Lee on Sun Mar 07 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKOldLinkResolver.h"

#import "DIGSLog.h"

#import "AKFrameworkConstants.h"
#import "AKHTMLConstants.h"

#import "AKTextUtils.h"

#import "AKDatabase.h"
#import "AKFileSection.h"
#import "AKClassNode.h"
#import "AKProtocolNode.h"

#import "AKDocLocator.h"

#import "AKSubtopic.h"
#import "AKClassTopic.h"
#import "AKProtocolTopic.h"
#import "AKFunctionsTopic.h"
#import "AKGlobalsTopic.h"
#import "AKOverviewDoc.h"

@implementation AKOldLinkResolver

#pragma mark -
#pragma mark AKLinkResolver methods

- (AKDocLocator *)docLocatorForURL:(NSURL *)linkURL
{
    linkURL = [linkURL absoluteURL];
// [agl] MEMORY LEAK -- There seems to be a leak in -standardizedURL.
// It would *probably* be okay to comment out this line, but I don't want
// to take any chances.
    linkURL = [linkURL standardizedURL];
    NSString *filePath = [linkURL path];

    // Based on the file name and the name of the anchor within the file,
    // figure out what logical location we're trying to navigate to.

// * What framework does the file belong to?
// * Is the file a documentation file for a behavior (i.e., a class or
//   protocol), or not (i.e., for Functions or for Types & Constants)?

    NSString *fwName = [self _frameworkNameImpliedBy:filePath];
    AKBehaviorNode *behaviorNode = nil;
    AKFileSection *rootSection = nil;
    AKTopic *docTopic = nil;

    for (NSString *pathComponent in [filePath pathComponents])
    {
        NSString *possibleFrameworkName = (fwName
                                           ? nil
                                           : [self _frameworkNameImpliedBy:pathComponent]);
        NSString *upperPathComponent = [pathComponent uppercaseString];

        if (possibleFrameworkName != nil)
        {
            fwName = possibleFrameworkName;
        }
        else if ([upperPathComponent isEqualToString:@"CLASSES"])
        {
            AKClassNode *classNode = [[self database] classDocumentedInHTMLFile:filePath];

            behaviorNode = classNode;
            rootSection = [classNode documentationAssociatedWithFrameworkNamed:fwName];
            docTopic = [AKClassTopic topicWithClassNode:classNode];

            break;
        }
        else if ([upperPathComponent isEqualToString:@"PROTOCOLS"])
        {
            AKProtocolNode *protocolNode = [[self database] protocolDocumentedInHTMLFile:filePath];

            behaviorNode = protocolNode;
            rootSection = [protocolNode nodeDocumentation];
            docTopic = [AKProtocolTopic topicWithProtocolNode:protocolNode];

            break;
        }
// May06 -- In the May06 doc update, the functions are usually in a
// directory called <framework_name>_Functions.
//        else if ([upperPathComponent isEqualToString:@"FUNCTIONS"])
        else if ([upperPathComponent isEqualToString:@"FUNCTIONS"]
                 ||[upperPathComponent hasSuffix:@"_FUNCTIONS"])
        {
            behaviorNode = nil;
            rootSection = [[self database] rootSectionForHTMLFile:filePath];
            docTopic = [AKFunctionsTopic topicWithFrameworkNamed:fwName inDatabase:[self database]];

            break;
        }
// May06 -- In the May06 doc update, the types and constants are in *two*
// directories, called <framework_name>_Constants and <framework_name>_DataTypes.
//        else if ([upperPathComponent isEqualToString:@"TYPESANDCONSTANTS"])
        else if ([upperPathComponent isEqualToString:@"TYPESANDCONSTANTS"]
                 || [upperPathComponent hasSuffix:@"_CONSTANTS"]
                 || [upperPathComponent hasSuffix:@"_DATATYPES"])
        {
            behaviorNode = nil;
            rootSection = [[self database] rootSectionForHTMLFile:filePath];
            docTopic = [AKGlobalsTopic topicWithFrameworkNamed:fwName inDatabase:[self database]];

            break;
        }
    }

    return [self _docLocatorForLinkAnchor:[linkURL fragment]
                              rootSection:rootSection
                                    topic:docTopic
                             behaviorNode:behaviorNode
                            frameworkName:fwName];
}


#pragma mark -
#pragma mark Private methods

// Returns the name of the framework referred to by aString, or nil if
// there is no match.  aString can be a framework name that's in the
// AKDatabase (in which case it is returned as is), a string of the form
// "XXX.framework" (in which case XXX is returned), or the string
// "ApplicationKit" (in which case "AppKit" is returned).
- (NSString *)_frameworkNameImpliedBy:(NSString *)aString
{
    // Is it the name of a framework already in the database?
    if ([[self database] hasFrameworkWithName:aString])
    {
        return aString;
    }

    // Is it the long form of "AppKit"?
    if ([aString isEqualToString:@"ApplicationKit"])
    {
        return AKAppKitFrameworkName;
    }

    // Is it a known framework name followed by ".framework"?
    for (NSString *fwName in [[self database] frameworkNames])
    {
        NSString *fwDirName = [fwName stringByAppendingString:@".framework"];

        if ([aString isEqualToString:fwDirName])
        {
            return fwName;
        }
    }

/*
    // Is it a path name with a framework's mainDocDir as a prefix?
    en = [[[self database] namesOfAvailableFrameworks] objectEnumerator];
    id fw;
    while ((fw = [en nextObject]))
    {
        if ([fw isKindOfClass:[AKCocoaFramework class]]
            && [aString hasPrefix:[fw mainDocDir]])
        {
            return [fw frameworkName];
        }
    }
*/

    // Possibly nil.
    return [[self database] frameworkForHTMLFile:aString];
}

// Returns a byte offset within the HTML file that lies within the file
// element referred to by the given anchor string.  This byte offset can
// be passed to -_childSectionOf:containingOffset:.
- (NSInteger)_offsetOfAnchor:(NSString *)anchorString
    inFileSection:(AKFileSection *)fileSection
{
    NSInteger anchorOffset = [[self database] offsetOfAnchorString:anchorString
                                                  inHTMLFile:[fileSection filePath]];
    if (anchorOffset < 0)
    {
        return -1;
    }

    NSData *textBytes = [fileSection fileContents];
    const char *anchorPtr = (char *)[textBytes bytes] + anchorOffset;

    // [agl] KLUDGE
    // In the newer Apple docs, the anchor tag comes before the
    // <h#> element that it marks -- unless it is inside a table,
    // as in the tables of constant names in the Constants
    // sections.  This is different from older docs, where the
    // anchor tag is inside the <h#> element.
    //
    // To deal with both cases, we look for the closing </td> or
    // </h#> tag, whichever comes first.  That offset should be
    // guaranteed (for now) to be inside the file section the
    // anchor is associated with.
    //
    // [agl] KLUDGE ON TOP OF KLUDGE
    // Now, with Tiger, we search for a closing </div> as well.
    const char *dataEnd = (char *)[textBytes bytes] + [textBytes length] - 4;

    while (anchorPtr < dataEnd)
    {
        if ((anchorPtr[0] == '<') && (anchorPtr[1] == '/'))
        {
            if ((anchorPtr[2] == 't') && (anchorPtr[3] == 'd'))
            {
                break;
            }
            else if ((anchorPtr[2] == 'h')
                     && (anchorPtr[3] >= '1') && (anchorPtr[3] <= '9'))
            {
                break;
            }
            else if ((anchorPtr[2] == 'd') && (anchorPtr[3] == 'i')
                     && (anchorPtr[4] == 'v'))
            {
                break;
            }
        }

        // If we got this far in the loop body, prepare for the next
        // loop iteration.
        anchorPtr++;
    }

    return anchorPtr - (char *)[textBytes bytes];
}

// desc is a major section's -sectionName
- (NSString *)_subtopicNameImpliedBySectionName:(NSString *)sectionName
{
    NSArray *namePairs = (@[
                          AKProtocolDescriptionHTMLSectionName, AKOverviewSubtopicName,
                          AKClassDescriptionHTMLSectionName, AKOverviewSubtopicName,
                          AKClassAtAGlanceHTMLSectionName, AKOverviewSubtopicName,
                          AKProgrammingTopicsHTMLSectionName, AKOverviewSubtopicName,
                          AKAdoptedProtocolsHTMLSectionName, AKOverviewSubtopicName,
                          AKConstantsHTMLSectionName, AKOverviewSubtopicName,
                          AKMethodTypesHTMLSectionName, AKOverviewSubtopicName,
                          AKPropertiesHTMLSectionName, AKPropertiesSubtopicName,
                          AKClassMethodsHTMLSectionName, AKClassMethodsSubtopicName,
                          AKInstanceMethodsHTMLSectionName, AKInstanceMethodsSubtopicName,
                          AKDelegateMethodsHTMLSectionName, AKDelegateMethodsSubtopicName,
                          AKDelegateMethodsAlternateHTMLSectionName, AKDelegateMethodsSubtopicName,
                          AKNotificationsHTMLSectionName, AKNotificationsSubtopicName,
                          ]);
    NSString *uppercaseSectionName = [sectionName uppercaseString];
    NSInteger numStrings = [namePairs count];
    NSInteger i;

    for (i = 0; i < numStrings; i += 2)
    {
        NSString *sectionNameConstant = [[namePairs objectAtIndex:i] uppercaseString];
        NSString *subtopicNameConstant = [namePairs objectAtIndex:(i + 1)];

        // Do substring test instead of equality just in case.
        NSRange loc = [uppercaseSectionName rangeOfString:sectionNameConstant];
        if (loc.location != NSNotFound)
        {
            return subtopicNameConstant;
        }
    }

    // If we got this far, just return the section name.
    return sectionName;
}

- (AKDocLocator *)_docLocatorForLinkAnchor:(NSString *)linkAnchor
                               rootSection:(AKFileSection *)rootSection
                                     topic:(AKTopic *)docTopic
                              behaviorNode:(AKBehaviorNode *)behaviorNode
                             frameworkName:(NSString *)frameworkName
{
    // What major and minor sections of the file is the anchor located in?
    if ((!linkAnchor) || (!rootSection) || (!docTopic))
    {
        return nil;
    }

    NSInteger offset = [self _offsetOfAnchor:linkAnchor inFileSection:rootSection];

    if (offset < 0)
    {
        DIGSLogError_ExitingMethodPrematurely(([NSString stringWithFormat:@"couldn't find anchor \"%@\" in file %@",
                                               linkAnchor, [rootSection filePath]]));
        return nil;
    }

    AKFileSection *majorSection = [self _childSectionOf:rootSection containingOffset:offset];
    AKFileSection *minorSection = [self _childSectionOf:majorSection containingOffset:offset];

    // What subtopic name and doc name do the major and minor section
    // names imply?
    NSString *majorSectionName = [majorSection sectionName];
    NSString *minorSectionName = [minorSection sectionName];
    NSString *subtopicName = majorSectionName;
    NSString *docName = minorSectionName;

// ---> thanks Gerriet
	if ( [ subtopicName isEqualToString: @"Functions" ] )
	{
        BOOL okSoFar = YES;

		AKFileSection *a = [ rootSection childSectionWithName: @"Functions by Task" ];
		if ( a == nil )	//	error
		{
			NSLog(@"%s rootSection \"%@\" has no \"Functions by Task\"",__FUNCTION__, rootSection);
			okSoFar = NO;
		}

        AKFileSection *b = nil;
        if (okSoFar)
        {
            b = [ a childSectionContainingString: docName ];
            if ( b == nil )	//	error
            {
                NSLog(@"%s section \"%@\" contains no \"%@\"",__FUNCTION__, b, docName);
                okSoFar = NO;
            }
        }

        NSString *y = nil;
        if (okSoFar)
        {
            y = [ b sectionName ];
            if ( y == nil )	//	error
            {
                NSLog(@"%s section \"%@\" has no sectionName",__FUNCTION__, b);
                okSoFar = NO;
            }
        }

        if (okSoFar)
        {
#ifdef DEBUG
            if ( ![ y isEqualToString: subtopicName ] )
            {
                NSLog(@"%s changing subtopic \"%@\" -> \"%@\"",__FUNCTION__, subtopicName, y);
            }
#endif
            subtopicName = y;
        }
	}
// <--- thanks Gerriet


    if (behaviorNode)
    {
        subtopicName = [self _subtopicNameImpliedBySectionName:majorSectionName];

        // When the subtopic is "General", the doc name is actually the section name.
        if ([subtopicName isEqualToString:AKOverviewSubtopicName])
        {
            if ([frameworkName isEqualToString:[behaviorNode owningFrameworkName]])
            {
                docName = majorSectionName;
            }
            else
            {
                docName = [AKOverviewDoc qualifyDocName:majorSectionName withFrameworkName:frameworkName];
            }
        }
    }

    // Now that we've answered all our questions, we have everything we
    // need to put together the doc locator.
    return [AKDocLocator withTopic:docTopic subtopicName:subtopicName docName:docName];
}

// [agl] make a note of the assumptions about child sections that this
// relies on: same file, sequential, non-overlapping.
- (AKFileSection *)_childSectionOf:(AKFileSection *)fileSection
                  containingOffset:(NSUInteger)offset
{
    if (offset < [fileSection sectionOffset])
    {
        return nil;
    }

    if ([fileSection numberOfChildSections] == 0)
    {
        return nil;
    }

    AKFileSection *prevSub = nil;

    for (AKFileSection *sub in [fileSection childSections])
    {
        if (offset < [sub sectionOffset])
        {
            return prevSub;
        }

        prevSub = sub;
    }

    // Check for the case where the offset falls in our last child section.
    AKFileSection *lastDescendant = fileSection;
    AKFileSection *lastSub = fileSection;

    while ((lastSub = [lastSub lastChildSection]))
    {
        lastDescendant = lastSub;
    }

    NSUInteger totalSectionLength = ([lastDescendant sectionOffset]
                                     + [lastDescendant sectionLength]
                                     - [fileSection sectionLength]);
    NSUInteger endingOffset = [fileSection sectionOffset] + totalSectionLength;

    if (offset < endingOffset)
    {
        return prevSub;
    }

    // If we got this far, the offset we were given does not fall within
    // any of our child sections.
    return nil;
}

@end
