//
//  IAELocalizerPhraseComposer.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 21/08/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAELocalizerPhraseComposer.h"

@implementation IAELocalizerPhraseComposer

#pragma mark - Constants

static NSString * const kLTextNoConcepts = @"LTEXT_PHRASE_NOCONCEPTS";
static NSString * const kLTextOneConcept = @"LTEXT_PHRASE_ONECONCEPT";
static NSString * const kLTextTwoOrMoreConcepts = @"LTEXT_PHRASE_TWOORMORECONCEPTS";

#pragma mark - Phrases

+ (NSString *)stringPhraseWithNumberOfConcepts:(NSUInteger)numberOfConcepts;
{
    NSString *phrase = nil;
    if (numberOfConcepts == 0) {
        phrase = NSLocalizedString(kLTextNoConcepts, @"");
    } else if (numberOfConcepts == 1) {
        phrase = NSLocalizedString(kLTextOneConcept, @"");
    } else {
        phrase = [NSString stringWithFormat:NSLocalizedString(kLTextTwoOrMoreConcepts, @""), numberOfConcepts];
    }
    
    return phrase;
}

@end
