//
//  IAEMonthDelegate.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 25/10/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAEMonth;
@class IAEConcept;
@class IAECategory;

@protocol IAEMonthDelegate <NSObject>

@optional
- (void)month:(IAEMonth *)month didUpdateConcept:(IAEConcept *)concept;

- (void)month:(IAEMonth *)month didAddNewConcept:(IAEConcept *)concept;

- (void)month:(IAEMonth *)month willRemoveConcept:(IAEConcept *)concept;
- (void)month:(IAEMonth *)month willRemoveConceptAtIndex:(NSUInteger)index;
- (void)month:(IAEMonth *)month willRemoveConceptAtIndex:(NSUInteger)index ofCategory:(IAECategory *)category;

- (void)conceptRemovedFromMonth:(IAEMonth *)month;

@end
