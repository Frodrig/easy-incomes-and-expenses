//
//  IAELocalizerPhraseComposer.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 21/08/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAECategory;

@interface IAELocalizerPhraseComposer : NSObject

+ (NSString *)stringPhraseNumberOfConceptsOfCategory:(IAECategory *)category;

@end
