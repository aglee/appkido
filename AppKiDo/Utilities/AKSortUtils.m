//
//  AKSortUtils.m
//  AppKiDo
//
//  Created by Andy Lee on 6/19/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKSortUtils.h"

NSSortDescriptor *AKFinderLikeSort(NSString *keyPath)
{
	return [NSSortDescriptor sortDescriptorWithKey:keyPath
										 ascending:YES
										  selector:@selector(localizedStandardCompare:)];
}

