//
//  AKTabChain.m
//  AppKiDo
//
//  Created by Andy Lee on 3/15/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import "AKTabChain.h"

#import "AKTabChainWindowDelegate.h"

#import "NSObject+AppKiDo.h"

@implementation AKTabChain

#pragma mark -
#pragma mark Event handling

+ (BOOL)handlePossibleTabChainEvent:(NSEvent *)anEvent
{
    BOOL isGoingForward;

    if (![self _isTabChainEvent:anEvent forward:&isGoingForward])
    {
        return NO;
    }

    return [self stepThroughTabChainInWindow:NSApp.keyWindow
                                     forward:isGoingForward];
}

+ (BOOL)stepThroughTabChainInWindow:(NSWindow *)keyWindow
                            forward:(BOOL)isGoingForward
{
    // See if the window delegate has a tab chain.
    NSArray *tabChain = [self modifiedTabChainForWindow:keyWindow];

    if (tabChain == nil)
    {
        return NO;
    }

    // See if the tab chain contains the given view.
    NSInteger currentIndex = [self _indexOfSelectedViewForWindow:keyWindow
                                                      inTabChain:tabChain];
    if (currentIndex == -1)
    {
        return NO;
    }

    // Try to select the next view in the chain in the given direction.
    NSInteger lengthOfChain = tabChain.count;

    for (NSInteger count = 1; count < lengthOfChain; count++)
    {
        NSInteger viewIndex = (isGoingForward
                               ? ((currentIndex + count) % lengthOfChain)
                               : ((currentIndex - count + lengthOfChain) % lengthOfChain));
        NSView *possibleViewToSelect = tabChain[viewIndex];

        if ([self _shouldTryToSelectView:possibleViewToSelect])
        {
            if ([self _tryToSelectView:possibleViewToSelect
                          forKeyWindow:keyWindow
                               forward:isGoingForward])
            {
                return YES;
            }
        }
    }
    
    return NO;
}

+ (NSArray *)unmodifiedTabChainForWindow:(NSWindow *)window
{
    if (![window.delegate respondsToSelector:@selector(tabChainViewsForWindow:)])
    {
        return nil;
    }

    return [(id <AKTabChainWindowDelegate>)window.delegate tabChainViewsForWindow:window];
}

+ (NSArray *)modifiedTabChainForWindow:(NSWindow *)window
{
    NSArray *tabChain = [self unmodifiedTabChainForWindow:window];

    if (tabChain == nil)
    {
        return nil;
    }

    // Add toolbar buttons to the tab chain if Full Keyboard Access is on.
    if (NSApp.fullKeyboardAccessEnabled && window.toolbar.visible)
    {
        NSMutableArray *extendedTabChain = [NSMutableArray arrayWithArray:tabChain];

        [self _addToolbarButtonsInWindow:window toTabChain:extendedTabChain];
        tabChain = extendedTabChain;
    }

    return tabChain;
}

#pragma mark -
#pragma mark Private methods

+ (BOOL)_isTabChainEvent:(NSEvent *)anEvent forward:(BOOL *)forwardFlagPtr
{
    if (anEvent.type != NSKeyDown)
    {
        return NO;
    }

    if (anEvent.characters.length == 0)
    {
        return NO;
    }

    unichar ch = [anEvent.characters characterAtIndex:0];

    if (ch == '\t')
    {
        if (forwardFlagPtr)
        {
            *forwardFlagPtr = YES;
        }

        return YES;
    }

    // I figured out empirically that 25 is the character we get when the user
    // hits Shift-Tab. Note: the test for modifier flags is not perfect; it
    // returns true if other modifier keys are down in *addition* to Shift.
    if ((ch == 25) && (anEvent.modifierFlags & NSShiftKeyMask))
    {
        if (forwardFlagPtr)
        {
            *forwardFlagPtr = NO;
        }

        return YES;
    }
    
    return NO;
}

+ (BOOL)_tryToSelectView:(NSView *)viewToSelect
            forKeyWindow:(NSWindow *)keyWindow
                 forward:(BOOL)isGoingForward
{
    id <AKTabChainWindowDelegate>windowDelegate = (id <AKTabChainWindowDelegate>)keyWindow.delegate;

    // Pre-notify the delegate and see if it approves.
    if ([windowDelegate respondsToSelector:@selector(tabChainWindow:willSelectView:forward:)])
    {
        viewToSelect = [windowDelegate tabChainWindow:keyWindow
                                       willSelectView:viewToSelect
                                              forward:isGoingForward];
    }

    if (viewToSelect == nil)
    {
        return NO;
    }

    // Try to make the change. Note that [viewToSelect window] may not be
    // keyWindow. It could be in a drawer, for example.
    BOOL didSelect = [viewToSelect.window makeFirstResponder:viewToSelect];

    // Post-notify the delegate.
    if ([windowDelegate respondsToSelector:@selector(tabChainWindow:didSelectView:forward:success:)])
    {
        [windowDelegate tabChainWindow:keyWindow
                         didSelectView:viewToSelect
                               forward:isGoingForward
                               success:didSelect];
    }

    // Returning NO means we will keep trying views further down the tab chain.
    return didSelect;
}

+ (BOOL)_shouldTryToSelectView:(NSView *)possibleViewToSelect
{
    // If the view is in a drawer, its window may not be visible. If the view is
    // in a swapped-out tab in a tab view, its window may be nil.
    return (possibleViewToSelect.acceptsFirstResponder
            && possibleViewToSelect.frame.size.width > 0
            && possibleViewToSelect.frame.size.height > 0
            && possibleViewToSelect.window.visible);
}

+ (NSInteger)_indexOfSelectedViewForWindow:(NSWindow *)window inTabChain:(NSArray *)tabChain
{
    NSView *keyView = (NSView *)window.firstResponder;

    if (![keyView isKindOfClass:[NSView class]])
    {
        return -1;
    }

    NSInteger lengthOfChain = tabChain.count;

    for (NSInteger viewIndex = 0; viewIndex < lengthOfChain; viewIndex++)
    {
        if ([keyView isDescendantOf:tabChain[viewIndex]])
        {
            return viewIndex;
        }
    }
    
    return -1;
}

//NSView
//	NSToolbarItemViewer
//	NSControl
//		_NSToolbarItemViewerLabelView
//		NSButton
//			NSToolbarButton
//
//
//BEGIN nextKeyView sequence:
//  <NSToolbarButton: 0xd175990>
//  <NSToolbarItemViewer: 0x3967a90>
//  <_NSToolbarItemViewerLabelView: 0x3967c20>
//  <NSToolbarButton: 0xd1763f0>
//  <NSToolbarItemViewer: 0x39681a0>
//  <_NSToolbarItemViewerLabelView: 0x3968350>
//  <NSToolbarButton: 0x39659d0>
//  <NSToolbarItemViewer: 0x3968770>
//  <_NSToolbarItemViewerLabelView: 0x3968920>
//  <NSToolbarButton: 0x3965e00>
//  <NSToolbarView: 0x236c720>
//  <NSToolbarItemViewer: 0x3966210>
//  <_NSToolbarItemViewerLabelView: 0x3966510>
//  <NSToolbarButton: 0x237d870>
//  <NSToolbarItemViewer: 0x39673e0>
//  <_NSToolbarItemViewerLabelView: 0x39676b0>
//  <NSToolbarButton: 0xd175990>
//END nextKeyView sequence -- sequence contains a loop
//
//
//NSThemeFrame
//	<_NSThemeCloseWidget: 0xd1746c0>,
//	<_NSThemeWidget: 0xd172dc0>,
//	<_NSThemeWidget: 0xd1762a0>,
//
//	contentView <NSView: 0xd1b0d70>,
//
//	(<NSToolbarView: 0x236c720>: AKToolbarID)
//		<_NSToolbarViewClipView: 0x232cab0>
//			<NSToolbarItemViewer: 0x3966210 'AKQuicklistToolID'>,
//				<_NSToolbarItemViewerLabelView: 0x3966510>,
//				<NSToolbarButton: 0x237d870>
//			<NSToolbarItemViewer: 0x39673e0 'AKBrowserToolID'>,
//			<NSToolbarItemViewer: 0x3967a90 'AKBackToolID'>,
//			<NSToolbarItemViewer: 0x39681a0 'AKForwardToolID'>,
//			<NSToolbarItemViewer: 0x3968770 'AKSuperclassToolID'>


+ (void)_addToolbarButtonsInWindow:(NSWindow *)window
                        toTabChain:(NSMutableArray *)tabChain
{
    NSView *themeFrame = window.contentView.superview;
    NSView *toolbarView = [self _subviewsOf:themeFrame
                               withClassName:@"NSToolbarView"].lastObject;
    NSView *toolbarClipView = toolbarView.subviews.lastObject;

    for (NSView *toolbarItemViewer in toolbarClipView.subviews)
    {
        NSButton *toolbarButton = [self _subviewsOf:toolbarItemViewer
                                       withClassName:@"NSToolbarButton"].lastObject;
        if (toolbarButton.enabled)
        {
            [tabChain addObject:toolbarButton];
        }
    }
}

+ (NSArray *)_subviewsOf:(NSView *)view withClassName:(NSString *)viewClassName
{
    NSMutableArray *result = [NSMutableArray array];

    for (NSView *subview in view.subviews)
    {
        if ([subview.className isEqualToString:viewClassName])
        {
            [result addObject:subview];
        }
    }

    return result;
}

@end
