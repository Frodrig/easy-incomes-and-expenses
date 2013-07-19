//
//  IAEVersionHelper.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 18/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEVersionHelper.h"

@implementation IAEVersionHelper

static NSString * const ltextLanguage = @"LTEXT_LANGUAGE";
static NSString * const esLanguageValue = @"es";
static NSString * const enLanguageValue = @"en";

+ (BOOL)isSpanishVersion
{
    // ToDo: ¡Esto no se puede mirar por el idioma!
    NSComparisonResult compareResult = [NSLocalizedString(ltextLanguage, @"") compare:esLanguageValue];
    return compareResult == NSOrderedSame;
}

+ (BOOL)isEnglishVersion
{
    // ToDo: ¡Esto no se puede mirar por el idioma!
    NSComparisonResult compareResult = [NSLocalizedString(ltextLanguage, @"") compare:enLanguageValue];
    return compareResult == NSOrderedSame;
}

@end
