//
//  IAEHelpPageView.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 16/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEHelpPageView.h"

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
    NSDictionary *attributesForStrings = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:32],
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
        
        label.attributedText = [[NSAttributedString alloc] initWithString:[texts objectAtIndex:textIndex]
                                                               attributes:attributesForStrings];
        
        label.numberOfLines = 0;
        [self addSubview:label];
    }
}

@end
