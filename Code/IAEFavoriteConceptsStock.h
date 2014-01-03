//
//  IAEFavoriteConceptsStock.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 03/01/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAEConcept;

@interface IAEFavoriteConceptsStock : NSObject

@property (nonatomic, readonly, strong) NSMutableDictionary *favorites;

+ (IAEFavoriteConceptsStock *)sharedInstance;

- (void)addFavorite:(IAEConcept *)concept;

- (void)removeFavoriteWithCategory:(NSString *)category andValue:(NSString *)value;
- (void)removeFavoriteOfConcept:(IAEConcept *)concept;
- (void)removeAndSaveFavoriteWithCategory:(NSString *)category andValue:(NSString *)value;
- (void)removeAndSaveFavoriteOfConcept:(IAEConcept *)concept;

- (BOOL)isMarkedAsFavorite:(IAEConcept *)concept;

- (void)removeAll;

- (void)save;
- (void)reload;

@end
