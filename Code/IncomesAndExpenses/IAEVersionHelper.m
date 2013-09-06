//
//  IAEVersionHelper.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 18/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEVersionHelper.h"

@implementation IAEVersionHelper

static NSString * const kLTextLanguage = @"LTEXT_LANGUAGE";
static NSString * const kESLanguageValue = @"es";
static NSString * const kENLanguageValue = @"en";

+ (BOOL)isSpanishLanguageVersion
{
    NSComparisonResult compareResult = [NSLocalizedString(kLTextLanguage, @"") compare:kESLanguageValue];
    const BOOL is = compareResult == NSOrderedSame;
    
    return is;
}

+ (BOOL)isEnglishLanguageVersion
{
    NSComparisonResult compareResult = [NSLocalizedString(kLTextLanguage, @"") compare:kENLanguageValue];
    const BOOL is = compareResult == NSOrderedSame;
    
    return is;
}

@end
