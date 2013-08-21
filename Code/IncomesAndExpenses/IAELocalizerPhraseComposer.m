//
//  IAELocalizerPhraseComposer.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 21/08/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAELocalizerPhraseComposer.h"
#import "IAEBook.h"

@implementation IAELocalizerPhraseComposer

#pragma mark - Constants

static NSString * const kLtextNoConcepts = @"LTEXT_PHRASE_NOCONCEPTS";
static NSString * const kLtextOneConcept = @"LTEXT_PHRASE_ONECONCEPT";
static NSString * const kLtextTwoOrMoreConcepts = @"LTEXT_PHRASE_TWOORMORECONCEPTS";

#pragma mark - Phrases

+ (NSString *)stringPhraseNumberOfConceptsOfCategory:(IAECategory *)category
{
    NSString *phrase = nil;
    NSUInteger numberOfConcepts = [[IAEBook sharedBook] findAllConceptsWithCategory:category].count;
    if (numberOfConcepts == 0) {
        phrase = NSLocalizedString(kLtextNoConcepts, @"");
    } else if (numberOfConcepts == 1) {
        phrase = NSLocalizedString(kLtextOneConcept, @"");
    } else {
        phrase = [NSString stringWithFormat:NSLocalizedString(kLtextTwoOrMoreConcepts, @""), numberOfConcepts];
    }
    
    return phrase;
}

@end
