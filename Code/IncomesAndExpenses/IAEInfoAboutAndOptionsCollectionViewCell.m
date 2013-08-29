//
//  IAEInfoAboutAndOptionsCollectionViewCell.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 17/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEInfoAboutAndOptionsCollectionViewCell.h"
#import "IAEInfoAboutAndOptionsCollectionViewCellDelegate.h"

@interface IAEInfoAboutAndOptionsCollectionViewCell()

@end

@implementation IAEInfoAboutAndOptionsCollectionViewCell

#pragma mark - Constants

static const NSUInteger kTitleLabelViewTag = 101;
static const NSUInteger kUrlButtonTag = 102;
static const NSUInteger kLiteLabelViewTag = 103;
static const NSUInteger kDesignedAndDevelopedLabelViewTag = 201;
static const NSUInteger kDeveloperNameLabelViewTag = 202;
static const NSUInteger kFeedbackLabelViewTag = 301;
static const NSUInteger kEmailButtonTag = 302;

static NSString * const kLtextTitle = @"LTEXT_SETTINGS_ABOUT_TITLE";
static NSString * const kLtextUrl = @"LTEXT_SETTINGS_ABOUT_URL";
static NSString * const kLtextLiteTitle = @"LTEXT_SETTINGS_ABOUT_LITE";
static NSString * const kLtextDesignedAndDeveloped = @"LTEXT_SETTINGS_ABOUT_DESIGNEDANDDEVELOPED";
static NSString * const kLtextDeveloperName = @"LTEXT_SETTINGS_ABOUT_DEVELOPER";
static NSString * const kLtextFeedback = @"LTEXT_SETTINGS_ABOUT_FEEDBACK";
static NSString * const kLtextEmail = @"LTEXT_SETTINGS_ABOUT_EMAIL";

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [self localizeControls];
}

- (void)localizeControls
{
    [self localizeLabel:(UILabel *)[self viewWithTag:kTitleLabelViewTag] withUnlocalizedText:kLtextTitle];
    [self localizeButton:(UIButton *)[self viewWithTag:kUrlButtonTag] withUnlocalizedText:kLtextUrl];
    [self localizeLabel:(UILabel *)[self viewWithTag:kLiteLabelViewTag] withUnlocalizedText:kLtextLiteTitle];
    [self localizeLabel:(UILabel *)[self viewWithTag:kDesignedAndDevelopedLabelViewTag] withUnlocalizedText:kLtextDesignedAndDeveloped];
    [self localizeLabel:(UILabel *)[self viewWithTag:kDeveloperNameLabelViewTag] withUnlocalizedText:kLtextDeveloperName];
    [self localizeLabel:(UILabel *)[self viewWithTag:kFeedbackLabelViewTag] withUnlocalizedText:kLtextFeedback];
    [self localizeButton:(UIButton *)[self viewWithTag:kEmailButtonTag] withUnlocalizedText:kLtextEmail];

}

- (void)localizeLabel:(UILabel *)label withUnlocalizedText:(NSString *)text
{
    label.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(text, @"")
                                                           attributes:[label.attributedText attributesAtIndex:0 effectiveRange:NULL]];
}

- (void)localizeButton:(UIButton *)button withUnlocalizedText:(NSString *)text
{
    NSDictionary *attributes = [[button attributedTitleForState:UIControlStateNormal] attributesAtIndex:0 effectiveRange:NULL];
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(text, @"")
                                                                          attributes:attributes];
    [button setAttributedTitle:attributedTitle forState:UIControlStateNormal];
}

#pragma mark - Control Events

- (IBAction)feedbackButtonPressed:(id)sender
{
    [self.delegate feedbackEmailButtonWasPressedIninfoAboutOptionsCollectionViewCell:self];
}

- (IBAction)urlButtonPressed:(id)sender
{
}

@end
