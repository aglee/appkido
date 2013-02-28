//
//  AKMultiRadioViewDelegate.h
//  AppKiDo
//
//  Created by Andy Lee on 2/28/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AKMultiRadioView;

@protocol AKMultiRadioViewDelegate <NSObject>

@required

/*!
 * Sent to the delegate when the user makes a selection in one of the
 * AKMultiRadioView's submatrixes.
 */
- (void)multiRadioViewDidMakeSelection:(AKMultiRadioView *)mrv;

@end
