//
//  IAEHelpPageView.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 16/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEHelpPageView.h"
#import "IAEColorHelper.h"

@interface IAEHelpPageView()

@end

@implementation IAEHelpPageView

#pragma mark - Constants

static NSString * const kBaseFontFamilyName = @"HelveticaNeue-Light";
static const NSUInteger kBaseFontSize = 34;
static const NSUInteger kBaseFontKern = 1.0;

static NSString * const kFontOpenCloseBraketsFamilyName = @"HelveticaNeue";
static NSString * const kFontOpenCloseKeysFamilyName = @"HelveticaNeue-Italic";

static const CGFloat kPercentageWidthOfText = 0.8;

#pragma mark - Properties

#pragma mark - Clase

+ (NSDictionary *)baseAttributesForText
{
    static NSDictionary *baseAttributes = nil;
    if (!baseAttributes) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentJustified;
        paragraphStyle.lineHeightMultiple = 1.1;
        
        baseAttributes = @{NSFontAttributeName: [UIFont fontWithName:kBaseFontFamilyName size:kBaseFontSize],
                           NSForegroundColorAttributeName: [UIColor darkTextColor],
                           NSKernAttributeName: @(kBaseFontKern),
                           NSParagraphStyleAttributeName : paragraphStyle};

    }
    
    return baseAttributes;
}

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame andTexts:nil];
}

- (instancetype)initWithFrame:(CGRect)frame andTexts:(NSArray *)text
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createTexts:text];
    }
    
    return self;
}

- (void)createTexts:(NSArray *)texts
{
    const CGFloat widthOfLabels = self.bounds.size.width * kPercentageWidthOfText;
    const CGFloat heightOfLabels = (self.bounds.size.height / (CGFloat)texts.count) * 1;
    const CGFloat xPosition = (self.bounds.size.width - widthOfLabels) / 2.0;
    for (NSUInteger textIndex = 0; textIndex < texts.count; ++textIndex) {
        const CGFloat yPosition = heightOfLabels * textIndex;
        CGRect labelFrame = CGRectMake(xPosition, yPosition, widthOfLabels, heightOfLabels);
        UILabel *label = [self createLabelWithFrame:labelFrame];
        NSString *originalText = [texts objectAtIndex:textIndex];
        [self applyAttributedStringInLabel:label withOriginalText:originalText];
        [self addSubview:label];
    }
}

- (UILabel *)createLabelWithFrame:(CGRect)frame
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.numberOfLines = 0;
    label.minimumScaleFactor = 0.5;
    label.adjustsFontSizeToFitWidth = YES;
    
    return label;
}

- (void)applyAttributedStringInLabel:(UILabel *)label withOriginalText:(NSString *)text
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:[self.class baseAttributesForText]];

    [attributedString beginEditing];
    [self applyOpenCloseBraketsInAttributedString:attributedString withOriginalText:text];
    [self applyOpenCloseKeysInAttributedString:attributedString withOriginalText:text];
    [self applyOpenCloseIncomesInAttributedString:attributedString withOriginalText:text];
    [self applyOpenCloseExpensesInAttributedString:attributedString withOriginalText:text];
    [attributedString endEditing];

    [self removeAllSpecialCharactersinAttributedString:attributedString];
    
    label.attributedText = attributedString;
}

- (void)applyOpenCloseBraketsInAttributedString:(NSMutableAttributedString *)attributedString withOriginalText:(NSString *)text
{
    NSArray *rangesWithOpenCloseBrakets = [self rangesWithOpenCharacter:@"<" andCloseCharacter:@">" inTextString:text];
    for (NSValue *range in rangesWithOpenCloseBrakets) {
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:kFontOpenCloseBraketsFamilyName size:kBaseFontSize] range:range.rangeValue];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:0.6 alpha:1.0] range:range.rangeValue];
        [attributedString addAttribute:NSKernAttributeName value:@0 range:range.rangeValue];
    }
}

- (void)applyOpenCloseKeysInAttributedString:(NSMutableAttributedString *)attributedString withOriginalText:(NSString *)text
{
    NSArray *rangesWithOpenCloseKeys = [self rangesWithOpenCharacter:@"{" andCloseCharacter:@"}" inTextString:text];
    for (NSValue *range in rangesWithOpenCloseKeys) {
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:kFontOpenCloseKeysFamilyName size:34] range:range.rangeValue];
        [attributedString addAttribute:NSKernAttributeName value:@0 range:range.rangeValue];
    }
}

- (void)applyOpenCloseIncomesInAttributedString:(NSMutableAttributedString *)attributedString withOriginalText:(NSString *)text
{
    NSArray *rangesWithOpenCloseIncomes = [self rangesWithOpenCharacter:@"+[" andCloseCharacter:@"]+" inTextString:text];
    for (NSValue *range in rangesWithOpenCloseIncomes) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:[IAEColorHelper colorForEconomicIncomeValue] range:range.rangeValue];
        [attributedString addAttribute:NSKernAttributeName value:@0 range:range.rangeValue];
    }
}

- (void)applyOpenCloseExpensesInAttributedString:(NSMutableAttributedString *)attributedString withOriginalText:(NSString *)text
{
    NSArray *rangesWithOpenCloseExpenses = [self rangesWithOpenCharacter:@"-[" andCloseCharacter:@"]-" inTextString:text];
    for (NSValue *range in rangesWithOpenCloseExpenses) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:[IAEColorHelper colorForEconomicExpenseValue] range:range.rangeValue];
        [attributedString addAttribute:NSKernAttributeName value:@0 range:range.rangeValue];
    }
}

- (void)removeAllSpecialCharactersinAttributedString:(NSMutableAttributedString *)attributedString
{
    NSSet *specialCharacters = [[NSSet alloc] initWithArray:@[@"<", @">", @"{", @"}", @"+[", @"]+", @"-[", @"]-"]];
    for (NSString *specialCharacter in specialCharacters) {
        [attributedString.mutableString replaceOccurrencesOfString:specialCharacter
                                                        withString:@""
                                                           options:NSCaseInsensitiveSearch
                                                             range:NSMakeRange(0, attributedString.string.length)];

    }
}

- (NSArray *)rangesWithOpenCharacter:(NSString *)openCharacter andCloseCharacter:(NSString *)closeCharacter inTextString:(NSString *)text
{
    NSMutableArray *rangesFound = [[NSMutableArray alloc] init];
    
    NSString *setOfOpenCloseCharacters = [NSString stringWithFormat:@"%@%@", openCharacter, closeCharacter];
    NSArray *substringsSeparated = [text componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:setOfOpenCloseCharacters]];
    for (NSString *substring in substringsSeparated) {
        NSString *substringOpenCloseCharacters = [NSString stringWithFormat:@"%@%@%@", openCharacter, substring, closeCharacter];
        NSRange range = [text rangeOfString:substringOpenCloseCharacters options:NSLiteralSearch];
        if (range.location != NSNotFound) {
            [rangesFound addObject:[NSValue valueWithRange:range]];
        }
    }
    
    return [NSArray arrayWithArray:rangesFound];
}

@end
