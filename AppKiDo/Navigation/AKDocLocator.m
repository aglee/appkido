/*
 * AKDocLocator.m
 *
 * Created by Andy Lee on Tue May 27 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKDocLocator.h"
#import "AKBehaviorToken.h"
#import "AKBehaviorTopic.h"
#import "AKFramework.h"
#import "AKFrameworkTopic.h"
#import "AKNamedObject.h"
#import "AKSubtopic.h"
#import "DIGSLog.h"

@implementation AKDocLocator
{
	NSString *_cachedDisplayName;
	NSString *_cachedSortName;
	id<AKDoc> _cachedDoc;
}

@synthesize topicToDisplay = _topicToDisplay;
@synthesize subtopicName = _subtopicName;
@synthesize docName = _docName;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithTopic:(AKTopic *)topic
				 subtopicName:(NSString *)subtopicName
					  docName:(NSString *)docName
{
	NSParameterAssert(topic != nil);
	NSParameterAssert(subtopicName != nil || docName == nil);
	self = [super init];
	if (self) {
		_topicToDisplay = topic;
		_subtopicName = subtopicName;
		_docName = docName;
	}
	return self;
}

- (instancetype)init
{
	DIGSLogError_NondesignatedInitializer();
	return [self initWithTopic:nil subtopicName:nil docName:nil];
}

#pragma mark - Getters and setters

-(NSString *)subtopicName
{
	return _subtopicName;
}

- (void)setSubtopicName:(NSString *)subtopicName
{
	if (![_subtopicName isEqualToString:subtopicName]) {
		[self _clearCachedObjects];
	}
	_subtopicName = subtopicName;
}

-(NSString *)docName
{
	return _docName;
}

- (void)setDocName:(NSString *)docName
{
	if (![_docName isEqualToString:docName]) {
		[self _clearCachedObjects];
	}
	_docName = docName;
}

- (NSString *)displayName
{
	if (_cachedDisplayName == nil) {
		_cachedDisplayName = [self.class _displayNameForDocLocator:self];
	}

	return _cachedDisplayName;
}

// As described by the Character Palette:
//		Name: LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
//		Unicode: 00AB
//		UTF8: C2 AB
static unichar kLeftDoubleAngle = 0x00AB;

// Doing this with class methods so I don't accidentally set an ivar.
// There are nine possibilities to account for:
// - The DocLocator may have topic, topic plus subtopic, or topic plus subtopic plus doc.
// - The topic may be a framework, a member group of a framework, or either a class or protocol.
+ (NSString *)_displayNameForDocLocator:(AKDocLocator *)docLocator
{
	NSAssert(docLocator.topicToDisplay != nil, @"+++ [ERROR] %@ has nil topic", docLocator);

	// Case 1: topic only.
	if (docLocator.subtopicName.length == 0) {
		NSAssert(docLocator.docName.length == 0,
				 @"+++ [ERROR] %@ -- subtopicName is empty/nil but docName is not.", self);

		// Topic is a framework.  Note that we check the AKFrameworkTopic case
		// *before* the AKFrameworkRelatedTopic case, because the former subclasses
		// from the latter.
		// Examples: "AppKit Framework", "Foundation Framework"
		if ([docLocator.topicToDisplay isKindOfClass:[AKFrameworkTopic class]]) {

			//QLog(@"+++ CHECKPOINT %zd, [%@] [%@] [%@]", 1000, docLocator.topicToDisplay, docLocator.subtopicName, docLocator.docName);

			return [NSString stringWithFormat:@"%@ Framework",
					docLocator.topicToDisplay.displayName];
		}

		// Topic is a framework member group.
		// Examples: "AppKit Protocols", "Foundation Data Types"
		if ([docLocator.topicToDisplay isKindOfClass:[AKFrameworkRelatedTopic class]]) {

			//QLog(@"+++ CHECKPOINT %zd, [%@] [%@] [%@]", 2000, docLocator.topicToDisplay, docLocator.subtopicName, docLocator.docName);

			return [NSString stringWithFormat:@"%@ %@",
					((AKFrameworkRelatedTopic *)docLocator.topicToDisplay).framework.name,
					docLocator.topicToDisplay.name];
		}

		// Topic is a class or protocol.
		// Examples: "NSView", "<NSTableViewDelegate>"
		NSAssert([docLocator.topicToDisplay isKindOfClass:[AKBehaviorTopic class]],
				 @"[ERROR] Unexpected kind of topic, %@.",
				 docLocator.topicToDisplay);

		//QLog(@"+++ CHECKPOINT %zd, [%@] [%@] [%@]", 3000, docLocator.topicToDisplay, docLocator.subtopicName, docLocator.docName);

		return docLocator.topicToDisplay.displayName;
	}

	// Case 2: topic and subtopic only.
	if (docLocator.docName.length == 0) {
		// Topic is a framework.  Note that we check the AKFrameworkTopic case
		// *before* the AKFrameworkRelatedTopic case, because the former subclasses
		// from the latter.
		if ([docLocator.topicToDisplay isKindOfClass:[AKFrameworkTopic class]]) {

			//QLog(@"+++ CHECKPOINT %zd, [%@] [%@] [%@]", 4000, docLocator.topicToDisplay, docLocator.subtopicName, docLocator.docName);

			return [NSString stringWithFormat:@"%@ %@",
					docLocator.topicToDisplay.displayName,
					docLocator.subtopicName];
		}

		// Topic is a framework member group.
		// "Speech Synthesis Manager << Application Services Constants"
		if ([docLocator.topicToDisplay isKindOfClass:[AKFrameworkRelatedTopic class]]) {

			//QLog(@"+++ CHECKPOINT %zd, [%@] [%@] [%@]", 5000, docLocator.topicToDisplay, docLocator.subtopicName, docLocator.docName);

			return [NSString stringWithFormat:@"%@  %C  %@ %@",
					docLocator.subtopicName,
					kLeftDoubleAngle,
					((AKFrameworkRelatedTopic *)docLocator.topicToDisplay).framework.name,
					docLocator.topicToDisplay.name];
		}

		// Topic is a class or protocol.
		// "Subtopic << Topic"
		NSAssert([docLocator.topicToDisplay isKindOfClass:[AKBehaviorTopic class]],
				 @"[ERROR] Unexpected kind of topic, %@.",
				 docLocator.topicToDisplay);

		//QLog(@"+++ CHECKPOINT %zd, [%@] [%@] [%@]", 6000, docLocator.topicToDisplay, docLocator.subtopicName, docLocator.docName);

		return [NSString stringWithFormat:@"%@  %C  %@",
				docLocator.subtopicName,
				kLeftDoubleAngle,
				docLocator.topicToDisplay.displayName];
	}

	// Case 3: topic, subtopic, and doc name are all specified.

	// Topic is a framework.  Note that we check the AKFrameworkTopic case
	// *before* the AKFrameworkRelatedTopic case, because the former subclasses
	// from the latter.
	// "doc << Framework Subtopic"
	if ([docLocator.topicToDisplay isKindOfClass:[AKFrameworkTopic class]]) {

		//QLog(@"+++ CHECKPOINT %zd, [%@] [%@] [%@]", 7000, docLocator.topicToDisplay, docLocator.subtopicName, docLocator.docName);

		return [NSString stringWithFormat:@"%@  %C  %@ %@",
				docLocator.docName,
				kLeftDoubleAngle,
				docLocator.topicToDisplay.name,
				docLocator.subtopicName];
	}

	// Topic is a framework member group.
	// "doc << Framework FrameworkMemberGroup"
	// "kSpeechCommandPrefix << Application Services Constants"
	if ([docLocator.topicToDisplay isKindOfClass:[AKFrameworkRelatedTopic class]]) {

		//QLog(@"+++ CHECKPOINT %zd, [%@] [%@] [%@]", 8000, docLocator.topicToDisplay, docLocator.subtopicName, docLocator.docName);

		return [NSString stringWithFormat:@"%@  %C  %@ %@",
				docLocator.docName,
				kLeftDoubleAngle,
				((AKFrameworkRelatedTopic *)docLocator.topicToDisplay).framework.name,
				docLocator.topicToDisplay.name];
	}

	// Topic is a class or protocol.
	// ".view << NSViewController Properties"
	// "-browser:isLeafItem: << <NSBrowserDelegate> Instance Methods
	NSAssert([docLocator.topicToDisplay isKindOfClass:[AKBehaviorTopic class]],
			 @"[ERROR] Unexpected kind of topic, %@.",
			 docLocator.topicToDisplay);

	//QLog(@"+++ CHECKPOINT %zd, [%@] [%@] [%@]", 9000, docLocator.topicToDisplay, docLocator.subtopicName, docLocator.docName);

	return [NSString stringWithFormat:@"%@  %C  %@ %@",
			docLocator.docToDisplay.displayName,
			kLeftDoubleAngle,
			docLocator.topicToDisplay.displayName,
			docLocator.subtopicName];
}

- (id<AKDoc>)docToDisplay
{
	if (_cachedDoc == nil) {
		AKSubtopic *subtopic = [self.topicToDisplay subtopicWithName:self.subtopicName];
		_cachedDoc = [subtopic docWithName:self.docName];
	}
	return _cachedDoc;
}

#pragma mark - Sorting

// We want this to mirror the logic of -displayName, which is
// too expensive to call directly.  That logic is:
// * If a doc locator has a doc name, then the string to display
//   (and therefore to sort on) is DocName+TopicName.
// * Otherwise, if the doc locator as a subtopic name, the string
//   to display is SubtopicName+TopicName.
// * Otherwise, the string to display is just TopicName.
//
// At most we'll have to do two string comparisons.  The work is in
// figuring out what two strings to compare first, and if those are equal,
// what two strings to compare next.
static
NSComparisonResult
compareDocLocators(AKDocLocator *locOne, AKDocLocator *locTwo, void *context)
{
	NSString *stringOne = nil;
	NSString *stringTwo = nil;

	// Get first shot at sOne.
	NSString *docNameOne = locOne.docName;
	NSString *subtopicNameOne = nil;
	NSString *topicNameOne = nil;

	if (docNameOne != nil) {
		stringOne = docNameOne;
	} else {
		subtopicNameOne = locOne.subtopicName;
		if (subtopicNameOne != nil) {
			stringOne = subtopicNameOne;
		} else {
			topicNameOne = locOne.topicToDisplay.sortName;
			stringOne = topicNameOne;
		}
	}

	// Get first shot at sTwo.
	NSString *docNameTwo = locTwo.docName;
	NSString *subtopicNameTwo = nil;
	NSString *topicNameTwo = nil;

	if (docNameTwo != nil) {
		stringTwo = docNameTwo;
	} else {
		subtopicNameTwo = locTwo.subtopicName;
		if (subtopicNameTwo != nil) {
			stringTwo = subtopicNameTwo;
		} else {
			topicNameTwo = locTwo.topicToDisplay.sortName;
			stringTwo = topicNameTwo;
		}
	}

	// Try the first comparison.
	NSComparisonResult result = [stringOne caseInsensitiveCompare:stringTwo];
	if (result != NSOrderedSame) {
		return result;
	}

	// If we got this far, we have to try the secondary comparison.
	if (stringOne == topicNameOne) {
		// There is no secondary comparison string for locOne, so locTwo is greater.
		return NSOrderedAscending;
	}
	if (stringTwo == topicNameTwo) {
		// There is no secondary comparison string for locTwo, so locOne is greater.
		return NSOrderedDescending;
	}

	// Both locOne and locTwo have a secondary comparison string, namely their respective topic names.
	if (topicNameOne == nil) {
		topicNameOne = locOne.topicToDisplay.sortName;
	}
	if (topicNameTwo == nil) {
		topicNameTwo = locTwo.topicToDisplay.sortName;
	}
	return [topicNameOne caseInsensitiveCompare:topicNameTwo];
}

+ (void)sortArrayOfDocLocators:(NSMutableArray *)array
{
	[array sortUsingFunction:&compareDocLocators context:NULL];
}

#pragma mark - AKPrefDictionary methods

+ (instancetype)fromPrefDictionary:(NSDictionary *)prefDict
{
	if (prefDict == nil) {
		return nil;
	}

	id topicPref = prefDict[AKTopicPrefKey];
	NSString *subtopicName = prefDict[AKSubtopicPrefKey];
	NSString *docName = prefDict[AKDocNamePrefKey];
	AKTopic *topic = [AKTopic fromPrefDictionary:topicPref];

	return [[self alloc] initWithTopic:topic subtopicName:subtopicName docName:docName];
}

- (NSDictionary *)asPrefDictionary
{
	NSMutableDictionary *prefDict = [NSMutableDictionary dictionary];

	if (self.topicToDisplay) {
		prefDict[AKTopicPrefKey] = [self.topicToDisplay asPrefDictionary];
	}

	if (self.subtopicName) {
		prefDict[AKSubtopicPrefKey] = self.subtopicName;
	}

	if (self.docName) {
		prefDict[AKDocNamePrefKey] = self.docName;
	}

	return prefDict;
}

#pragma mark - <AKSortable> methods

- (NSString *)sortName  //TODO: Do we ever use this, or is all sorting done with sortArrayOfDocLocators?
{
	if (_cachedSortName == nil) {
		NSString *topicName = self.topicToDisplay.sortName;

		if (self.subtopicName == nil) {
			_cachedSortName = topicName;
		} else  if (self.docName == nil) {
			_cachedSortName = [NSString stringWithFormat:@"%@-%@", self.subtopicName, topicName];
		} else {
			_cachedSortName = [NSString stringWithFormat:@"%@-%@", self.docName, topicName];
		}
	}
	return _cachedSortName;
}

#pragma mark - NSObject methods

- (BOOL)isEqual:(AKDocLocator *)otherDocLocator
{
	// The other object must be an AKDocLocator.
	if (![otherDocLocator isKindOfClass:[AKDocLocator class]]) {
		return NO;
	}

	// The "!=" tests take care of cases where both are nil.

	// See if the subtopics have the same name.
	if (otherDocLocator.subtopicName != self.subtopicName
		&& ![otherDocLocator.subtopicName isEqualToString:self.subtopicName]) {
		return NO;
	}

	// See if the docs have the same name.
	if (otherDocLocator.docName != self.docName
		&& ![otherDocLocator.docName isEqualToString:self.docName]) {
		return NO;
	}

	// See if the topics match.
	if (otherDocLocator.topicToDisplay != self.topicToDisplay
		&& ![otherDocLocator.topicToDisplay isEqual:self.topicToDisplay]) {
		return NO;
	}

	// If we got this far, the objects are equal.
	return YES;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p [%@] [%@] [%@]>",
			self.className,
			self,
			self.topicToDisplay.pathInTopicBrowser,
			self.subtopicName,
			self.docName];
}

#pragma mark - Private methods

- (void)_clearCachedObjects
{
	_cachedDisplayName = nil;
	_cachedSortName = nil;
	_cachedDoc = nil;
}

@end
