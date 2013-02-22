/*
 * AKMultiRadioView.m
 *
 * Created by Andy Lee on Sun May 22 2005.
 * Copyright (c) 2005 Andy Lee. All rights reserved.
 */

#import "AKMultiRadioView.h"

#import "DIGSLog.h"

@implementation AKMultiRadioView


#pragma mark -
#pragma mark Init/awake/dealloc

// Note: we never retain _selectedRadioMatrix, so there's no need to
// release it in -dealloc.
- (id)initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        _selectedRadioMatrix = nil;
        _radioAction = (SEL)NULL;
    }

    return self;
}

- (void)awakeFromNib
{
    // Make sure at most one co-matrix has a non-empty selection,
    // and remember which co-matrix it is.
    _selectedRadioMatrix = nil;
    for (id subview in [self subviews])
    {
        if ([subview isKindOfClass:[NSMatrix class]]
            && ([(NSMatrix *)subview mode] == NSRadioModeMatrix))
        {
            if (_radioAction && ([subview action] != _radioAction))
            {
                DIGSLogWarning(@"co-matrixes have different actions");
            }

            if (_radioTarget && ([subview target] != _radioTarget))
            {
                DIGSLogWarning(@"co-matrixes have different targets");
            }

            _radioAction = [subview action];
            _radioTarget = [subview target];
            [subview setTarget:self];
            [subview setAction:@selector(doRadioAction:)];

            if (_selectedRadioMatrix == nil)
            {
                // We've come across the first comatrix with a selected
                // cell; make ithe selected matrix.
                if ([subview selectedCell])
                {
                    _selectedRadioMatrix = subview;
                }
            }
            else
            {
                // We already chose our selected matrix, so deselect
                // all the cells in this one.
                [subview deselectAllCells];
            }
        }
    }
}


#pragma mark -
#pragma mark Getters and setters

- (NSInteger)selectedTag
{
    if (_selectedRadioMatrix == nil)
    {
        return -1;
    }
    else
    {
        return [_selectedRadioMatrix selectedTag];
    }
}

- (BOOL)selectCellWithTag:(NSInteger)tag
{
    BOOL didSelect = NO;

    _selectedRadioMatrix = nil;
    for (id subview in [self subviews])
    {
        if ([subview isKindOfClass:[NSMatrix class]]
            && ([(NSMatrix *)subview mode] == NSRadioModeMatrix))
        {
            if (didSelect)
            {
                [subview deselectAllCells];
            }
            else
            {
                didSelect = [subview selectCellWithTag:tag];

                if (didSelect)
                {
                    _selectedRadioMatrix = subview;
                }
                else
                {
                    [subview deselectAllCells];
                }
            }
        }
    }

    return didSelect;
}


#pragma mark -
#pragma mark Action methods

// manage singleness of selection, then forward action to real target
- (IBAction)doRadioAction:(id)sender
{
    if ([sender superview] != self)
    {
        DIGSLogWarning(@"AKMultiRadioView [%@] doesn't have [%@] as a subview",
                       self, sender);
        return;
    }

    if (sender != _selectedRadioMatrix)
    {
        [_selectedRadioMatrix deselectAllCells];
        _selectedRadioMatrix = sender;
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [_radioTarget performSelector:_radioAction withObject:sender];
#pragma clang diagnostic pop
}


@end
