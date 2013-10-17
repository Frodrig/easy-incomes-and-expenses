//
//  IAEHelpPageView.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 16/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEHelpPageView.h"
#import "IAEColorHelper.h"

@implementation IAEHelpPageView

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
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentJustified;
    paragraphStyle.lineHeightMultiple = 1.1;
    NSDictionary *attributesForStrings = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:34],
                                           NSForegroundColorAttributeName: [UIColor darkTextColor],
                                           NSKernAttributeName: @1.0,
                                           NSParagraphStyleAttributeName : paragraphStyle};
    
    const CGFloat widthOfLabels = self.bounds.size.width * 0.8;
    const CGFloat heightOfLabels = (self.bounds.size.height / (CGFloat)texts.count) * 1;
    const CGFloat xPosition = (self.bounds.size.width - widthOfLabels) / 2.0;
    for (NSUInteger textIndex = 0; textIndex < texts.count; ++textIndex) {
        const CGFloat yPosition = heightOfLabels * textIndex;
        CGRect labelFrame = CGRectMake(xPosition, yPosition, widthOfLabels, heightOfLabels);
        UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
        label.numberOfLines = 0;
        label.minimumScaleFactor = 0.5;
        label.adjustsFontSizeToFitWidth = YES;

        NSString *originalText = [texts objectAtIndex:textIndex];
        NSArray *rangesWithOpenCloseBrakets = [self rangesWithOpenCharacter:@"<" andCloseCharacter:@">" inTextString:originalText];
        NSArray *rangesWithOpenCloseKeys = [self rangesWithOpenCharacter:@"{" andCloseCharacter:@"}" inTextString:originalText];
        NSArray *rangesWithOpenCloseIncomes = [self rangesWithOpenCharacter:@"+[" andCloseCharacter:@"]+" inTextString:originalText];
        NSArray *rangesWithOpenCloseExpenses = [self rangesWithOpenCharacter:@"-[" andCloseCharacter:@"]-" inTextString:originalText];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:originalText
                                                                                             attributes:attributesForStrings];
        [attributedString beginEditing];
        
        for (NSValue *range in rangesWithOpenCloseBrakets) {
            [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue" size:34] range:range.rangeValue];
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:0.6 alpha:1.0] range:range.rangeValue];
            [attributedString addAttribute:NSKernAttributeName value:@0 range:range.rangeValue];
        }

        for (NSValue *range in rangesWithOpenCloseKeys) {
            [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Italic" size:34] range:range.rangeValue];
            [attributedString addAttribute:NSKernAttributeName value:@0 range:range.rangeValue];
        }
        
        for (NSValue *range in rangesWithOpenCloseIncomes) {
            [attributedString addAttribute:NSForegroundColorAttributeName value:[IAEColorHelper colorForEconomicIncomeValue] range:range.rangeValue];
            [attributedString addAttribute:NSKernAttributeName value:@0 range:range.rangeValue];
        }

        
        for (NSValue *range in rangesWithOpenCloseExpenses) {
            [attributedString addAttribute:NSForegroundColorAttributeName value:[IAEColorHelper colorForEconomicExpenseValue] range:range.rangeValue];
            [attributedString addAttribute:NSKernAttributeName value:@0 range:range.rangeValue];
        }

        [attributedString.mutableString replaceOccurrencesOfString:@"<" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, attributedString.string.length)];
        [attributedString.mutableString replaceOccurrencesOfString:@">" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, attributedString.string.length)];
        [attributedString.mutableString replaceOccurrencesOfString:@"{" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, attributedString.string.length)];
        [attributedString.mutableString replaceOccurrencesOfString:@"}" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, attributedString.string.length)];
        [attributedString.mutableString replaceOccurrencesOfString:@"+[" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, attributedString.string.length)];
        [attributedString.mutableString replaceOccurrencesOfString:@"]+" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, attributedString.string.length)];
        [attributedString.mutableString replaceOccurrencesOfString:@"-[" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, attributedString.string.length)];
        [attributedString.mutableString replaceOccurrencesOfString:@"]-" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, attributedString.string.length)];


        [attributedString endEditing];
        
        label.attributedText = attributedString;
        //[label sizeToFit];

        [self addSubview:label];
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

- (NSString *)removeQuotesFromString:(NSString *)text
{
    NSString *newText = [text stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    return newText;
}

@end
