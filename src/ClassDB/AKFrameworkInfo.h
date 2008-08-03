/*
 * AKFrameworkInfo.h
 *
 * Created by Andy Lee on Sun Jul 04 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

/*!
 * @class       AKFrameworkInfo
 * @discussion  Interface to the contents of the FrameworkInfo.plist file,
 *              which defines the universe of frameworks that AppKiDo can
 *              support.
 *
 *              AKFrameworkInfo and FrameworkInfo.plist should only be used
 *              if a SQLite docset index (docSet.dsidx) is not present.  If
 *              a docset index is present, AKDocSetIndex should be used.
 *              See the comments for AKDocSetIndex for more details.
 *
 *              In the world of AKFrameworkInfo, our concept of a framework
 *              is defined by a Foo.framework directory, typically
 *              /System/Library/Frameworks/Foo.framework.  The API
 *              constructs belonging to the framework are the ones declared
 *              in Foo.framework/Headers.  This is admittedly not a perfect
 *              model, which is why it is deprecated in Leopard in favor of
 *              docsets.
 */
@interface AKFrameworkInfo : NSObject
{
@private
    NSMutableArray *_allPossibleFrameworkNames;
    NSMutableDictionary *_frameworkClassNamesByFrameworkName;
    NSMutableDictionary *_frameworkPathsByFrameworkName;
    NSMutableDictionary *_docDirsByFrameworkName;
}

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

+ (AKFrameworkInfo *)sharedInstance;

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

/*!
 * Returns all framework names listed in FrameworkInfo.plist, regardless
 * of the actual availability of those frameworks.
 */
- (NSArray *)allPossibleFrameworkNames;

/*! Returns AKCocoaFramework or a descendant thereof. */
- (NSString *)frameworkClassNameForFrameworkNamed:(NSString *)fwName;

- (NSString *)headerDirForFrameworkNamed:(NSString *)fwName;

- (NSString *)docDirForFrameworkNamed:(NSString *)fwName;

/*! Returns YES if both header dir and doc dir exist. */
- (BOOL)frameworkDirsExist:(NSString *)fwName;

@end
