//
//  IAEHelpAboutCollectionViewCell
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 17/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEHelpAboutCollectionViewCell.h"
#import "IAEHelpAboutCollectionViewCellDelegate.h"
#import "IAENibUtils.h"
#import "NSUserDefaults+EasyIncAndExp.h"

@interface IAEHelpAboutCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIButton *emailButton;

@end

@implementation IAEHelpAboutCollectionViewCell

#pragma mark - Constants

static const NSUInteger kTitleLabelViewTag = 101;
static const NSUInteger kUrlButtonTag = 102;
static const NSUInteger kVersionLabelViewTag = 103;
static const NSUInteger kDesignedAndDevelopedLabelViewTag = 201;
static const NSUInteger kDeveloperNameLabelViewTag = 202;
static const NSUInteger kFeedbackLabelViewTag = 301;
static const NSUInteger kEmailButtonTag = 302;

static NSString * const kLTextTitle = @"LTEXT_SETTINGS_ABOUT_TITLE";
static NSString * const kLTextUrl = @"LTEXT_SETTINGS_ABOUT_URL";
static NSString * const kLTextLiteTitle = @"LTEXT_SETTINGS_ABOUT_LITE";
static NSString * const kLTextDesignedAndDeveloped = @"LTEXT_SETTINGS_ABOUT_DESIGNEDANDDEVELOPED";
static NSString * const kLTextDeveloperName = @"LTEXT_SETTINGS_ABOUT_DEVELOPER";
static NSString * const kLTextFeedback = @"LTEXT_SETTINGS_ABOUT_FEEDBACK";
static NSString * const kLTextEmail = @"LTEXT_SETTINGS_ABOUT_EMAIL";

static NSString * const kNibName = @"IAEHelpAboutCollectionViewCell";

#pragma mark - Class

+ (CGSize)sizeOfItem
{
    static CGSize size;
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        size = [IAENibUtils findSizeOfTheBaseViewOfNibNamed:kNibName];
    }
    
    return size;
}

#pragma mark - Properties

- (void)setCanSendMail:(BOOL)canSendMail
{
    self.emailButton.enabled = canSendMail;
    _canSendMail = canSendMail;
}

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
    [super awakeFromNib];

    [self localizeControls];
}

- (void)localizeControls
{
    [self localizeLabel:(UILabel *)[self viewWithTag:kTitleLabelViewTag] withUnlocalizedText:kLTextTitle];
    [self localizeButton:(UIButton *)[self viewWithTag:kUrlButtonTag] withUnlocalizedText:kLTextUrl];
    [self localizedVersionLabel:(UILabel *)[self viewWithTag:kVersionLabelViewTag]];
    [self localizeLabel:(UILabel *)[self viewWithTag:kDesignedAndDevelopedLabelViewTag] withUnlocalizedText:kLTextDesignedAndDeveloped];
    [self localizeLabel:(UILabel *)[self viewWithTag:kDeveloperNameLabelViewTag] withUnlocalizedText:kLTextDeveloperName];
    [self localizeLabel:(UILabel *)[self viewWithTag:kFeedbackLabelViewTag] withUnlocalizedText:kLTextFeedback];
    [self localizeButton:(UIButton *)[self viewWithTag:kEmailButtonTag] withUnlocalizedText:kLTextEmail];

}

- (void)localizeLabel:(UILabel *)label withUnlocalizedText:(NSString *)text
{
    label.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(text, @"")
                                                           attributes:[label.attributedText attributesAtIndex:0 effectiveRange:NULL]];
}

- (void)localizedVersionLabel:(UILabel *)label
{
    NSString *versionText = [[NSUserDefaults standardUserDefaults] isProVersionEnabled] ? NSLocalizedString(@"LTEXT_SETTINGS_ABOUT_PRO", @"") : NSLocalizedString(@"LTEXT_SETTINGS_ABOUT_LITE", @"");
    versionText = [versionText stringByAppendingString:@" "];
    versionText = [versionText stringByAppendingString:NSLocalizedString(@"LTEXT_VERSION", @"")];
    label.text = versionText;
}

- (void)localizeButton:(UIButton *)button withUnlocalizedText:(NSString *)text
{
    [button setTitle:NSLocalizedString(text, @"") forState:UIControlStateNormal];
}

#pragma mark - Control Events

- (IBAction)feedbackButtonPressed:(id)sender
{
    [self.delegate feedbackEmailButtonWasPressedInHelpAboutCollectionViewCell:self];
}

- (IBAction)urlButtonPressed:(id)sender
{
    [self.delegate urlButtonWasPressedInHelpAboutCollectionViewCell:self];
}

@end
