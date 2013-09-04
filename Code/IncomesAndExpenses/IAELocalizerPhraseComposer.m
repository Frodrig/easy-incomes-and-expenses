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
static NSString * const kLTextTwoConcepts = @"LTEXT_PHRASE_TWOCONCEPT";
static NSString * const kLTextThreeConcepts = @"LTEXT_PHRASE_THREECONCEPT";
static NSString * const kLTextFourConcepts = @"LTEXT_PHRASE_FOURCONCEPT";
static NSString * const kLTextFiveConcepts = @"LTEXT_PHRASE_FIVECONCEPT";
static NSString * const kLTextSixConcepts = @"LTEXT_PHRASE_SIXCONCEPT";
static NSString * const kLTextSevenConcepts = @"LTEXT_PHRASE_SEVENCONCEPT";
static NSString * const kLTextEightConcepts = @"LTEXT_PHRASE_EIGHTCONCEPT";
static NSString * const kLTextNineConcepts = @"LTEXT_PHRASE_NINECONCEPT";
static NSString * const kLTextMoreThanTenConcepts = @"LTEXT_PHRASE_MORETHANTENCONCEPTS";

#pragma mark - Phrases

+ (NSString *)stringPhraseWithNumberOfConcepts:(NSUInteger)numberOfConcepts;
{
    static NSArray *ltextForConceptsLessThanTen = nil;
    if (!ltextForConceptsLessThanTen) {
        ltextForConceptsLessThanTen = @[NSLocalizedString(kLTextNoConcepts, @""),
                                        NSLocalizedString(kLTextOneConcept, @""),
                                        NSLocalizedString(kLTextTwoConcepts, @""),
                                        NSLocalizedString(kLTextThreeConcepts, @""),
                                        NSLocalizedString(kLTextFourConcepts, @""),
                                        NSLocalizedString(kLTextFiveConcepts, @""),
                                        NSLocalizedString(kLTextSixConcepts, @""),
                                        NSLocalizedString(kLTextSevenConcepts, @""),
                                        NSLocalizedString(kLTextEightConcepts, @""),
                                        NSLocalizedString(kLTextNineConcepts, @"")];
    }
    
    NSString *phrase = nil;
    if (numberOfConcepts < ltextForConceptsLessThanTen.count) {
        phrase = ltextForConceptsLessThanTen[numberOfConcepts];
    } else {
        phrase = [NSString stringWithFormat:NSLocalizedString(kLTextMoreThanTenConcepts, @""), numberOfConcepts];
    }
    
    return phrase;
}

@end
