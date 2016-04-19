/*
 * AKMultiRadioView.m
 *
 * Created by Andy Lee on Sun May 22 2005.
 * Copyright (c) 2005 Andy Lee. All rights reserved.
 */

#import "AKMultiRadioView.h"

#import "DIGSLog.h"

@implementation AKMultiRadioView

@synthesize delegate = _delegate;

#pragma mark -
#pragma mark Getters and setters

- (NSInteger)selectedTag
{
    for (NSMatrix *submatrix in [self _submatrixes])
    {
        if ([submatrix selectedTag] != -1)
        {
            return [submatrix selectedTag];
        }
    }
    
    return -1;
}

- (BOOL)selectCellWithTag:(NSInteger)tag
{
    BOOL didSelect = NO;

    for (NSMatrix *submatrix in [self _submatrixes])
    {
        if (didSelect)
        {
            [submatrix deselectAllCells];
        }
        else
        {
            didSelect = [submatrix selectCellWithTag:tag];

            if (!didSelect)
            {
                [submatrix deselectAllCells];
            }
        }
    }

    return didSelect;
}

#pragma mark -
#pragma mark Action methods

- (IBAction)doRadioAction:(id)sender
{
    for (NSMatrix *submatrix in [self _submatrixes])
    {
        if (submatrix != sender)
        {
            [submatrix deselectAllCells];
        }
    }

    [_delegate multiRadioViewDidMakeSelection:self];
}

#pragma mark -
#pragma mark Private methods

- (NSArray *)_submatrixes
{
    NSMutableArray *submatrixes = [NSMutableArray array];

    for (NSView *subview in self.subviews)
    {
        if ([subview isKindOfClass:[NSMatrix class]]
            && (((NSMatrix *)subview).mode == NSRadioModeMatrix)
            && ((NSMatrix *)subview).allowsEmptySelection
            && (((NSMatrix *)subview).target == self)
            && (((NSMatrix *)subview).action == @selector(doRadioAction:)))
        {
            [submatrixes addObject:subview];
        }
    }

    return submatrixes;
}

@end
