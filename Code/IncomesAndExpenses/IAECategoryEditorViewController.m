//
//  IAECategoryEditorViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 08/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAECategoryEditorViewController.h"
#import "IAECategoryEditorViewControllerDelegate.h"
#import "IAECategoryEditorDefs.h"
#import "IAECategory.h"
#import "IAEColorHelper.h"
#import "IAEEconomicValueTypeHelper.h"
#import "UIView+RoundedCorners.h"

@interface IAECategoryEditorViewController ()

@property (nonatomic) EdityModeCategoryType editModeContext;
@property (nonatomic) CategoryType categoryTypeContext;
@property (nonatomic, weak) IAECategory *categoryToRename;
@property (weak, nonatomic) IBOutlet UILabel *informationLabel;
@property (weak, nonatomic) IBOutlet UITextField *categoryInputTextField;
@property (weak, nonatomic) IBOutlet UIView *categoryTypeDecoratorView;
@property (weak, nonatomic) IBOutlet UIView *categoryDecoratorAndInputContainerView;
@property (weak, nonatomic) IBOutlet UILabel *problemWarningLabel;
@property (nonatomic) BOOL cancelButtonWasPressed;
@end

@implementation IAECategoryEditorViewController

static const NSUInteger kSizeInformationLabel = 32;
static const NSUInteger kSizeInputTextField = 68;
static const NSUInteger kSizeRoundedRectCorners = 10;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSAssert(@"No deberiamos de inicializar desde este punto", @"");
    self = nil;
    return self;
}

- (id)initToAddCategoryOfType:(CategoryType)categoryType
{
    self = [self initForEditMode:EDITMODE_CATEGORY_ADD ofCategoryType:categoryType andCategory:nil];
    return self;
}

- (id)initToRenameCategory:(IAECategory *)category
{
    self = [self initForEditMode:EDITMODE_CATEGORY_RENAME ofCategoryType:category.categoryType andCategory:category];
    return self;
}

- (id)initForEditMode:(EdityModeCategoryType)editMode ofCategoryType:(CategoryType)categoryType andCategory:(IAECategory *)category
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _editModeContext = editMode;
        _categoryTypeContext = categoryType;
        _categoryToRename = category;
        
        [self initModalTransitionAndPresentationStyles];
    }
    
    return self;
}

- (void)initModalTransitionAndPresentationStyles
{
    [self setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self setModalPresentationStyle:UIModalPresentationFormSheet];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)disablesAutomaticKeyboardDismissal
{
    // IMPORTANTE: Por algun motivo para que el teclado desaparezca tras return, hay que sobrecargar esta funcion
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureInformationLabel];
    [self configureCategoryDecoratorAndInputContainerView];
    [self configureCategoryTypeDecoratorView];
    [self configureInputTextFieldDefaultText];
    [self configureProblemWarningLabel];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self launchKeyboard];
}

#pragma mark - Configuration & Launch

- (void)configureInformationLabel
{
    self.informationLabel.attributedText = [[NSAttributedString alloc] initWithString:[self stringTagBasedOnEditModeForInformationLabel]
                                                                           attributes:[self createAttributeForLabelWithSize:kSizeInformationLabel]];
}

- (void)configureCategoryDecoratorAndInputContainerView
{
    [self.categoryDecoratorAndInputContainerView addRoundedCorners:UIRectCornerAllCorners withRadius:kSizeRoundedRectCorners];
}

- (void)configureInputTextFieldDefaultText
{
    self.categoryInputTextField.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:kSizeInputTextField];
    
    NSDictionary *attributesForCategoryInputText = [self createAttributeForLabelWithSize:kSizeInputTextField];
    self.categoryInputTextField.attributedText = [[NSAttributedString alloc] initWithString:@""
                                                                                 attributes:attributesForCategoryInputText];
    
    NSDictionary *attributesForCategoryPlaceholderText = [self createAttributeForLabelWithSize:kSizeInputTextField andColor:[UIColor lightGrayColor]];
    self.categoryInputTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[self stringTagBasedOnEditModeForInputTextField]
                                                                                        attributes:attributesForCategoryPlaceholderText];
    self.categoryInputTextField.textAlignment = NSTextAlignmentLeft;
    self.categoryInputTextField.delegate = self;
}

- (void)configureCategoryTypeDecoratorView
{
    [self.categoryTypeDecoratorView addRoundedCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft withRadius:kSizeRoundedRectCorners];
    
    EconomicValueType economicValueType = [IAEEconomicValueTypeHelper economicValueTypeFromCategoryType:self.categoryTypeContext];
    self.categoryTypeDecoratorView.backgroundColor = [IAEColorHelper colorForEconomicValueType:economicValueType];
}

- (void)configureProblemWarningLabel
{
    self.problemWarningLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"LTEXT_INVALIDCATEGORY", "")
                                                                              attributes:[self createAttributeForLabelWithSize:21]];
    self.problemWarningLabel.numberOfLines = 2;
    self.problemWarningLabel.alpha = 0;
}

- (NSString *)stringTagBasedOnEditModeForInformationLabel
{
    NSString *stringTag = nil;
    if ([self isEditModeCategoryInAddMode]) {
        stringTag = NSLocalizedString(@"LTEXT_ADD_NEW_CATEGORY", @"");
    } else if ([self isEditModeCategoryInRenameMode]) {
        stringTag = NSLocalizedString(@"LTEXT_RENAME_CATEGORY", @"");
    }
    
    return stringTag;
}

- (NSString *)stringTagBasedOnEditModeForInputTextField
{
    NSString *stringTag = nil;
    if ([self isEditModeCategoryInAddMode]) {
        stringTag = NSLocalizedString(@"LTEXT_PLACEHOLDER_CATEGORY", "");
    } else if ([self isEditModeCategoryInRenameMode]) {
        stringTag = self.categoryToRename.tag;
    }
    
    return stringTag;
}

- (BOOL)isEditModeCategoryInAddMode
{
    return self.editModeContext == EDITMODE_CATEGORY_ADD;
}

- (BOOL)isEditModeCategoryInRenameMode
{
    return self.editModeContext == EDITMODE_CATEGORY_RENAME;
}

- (NSDictionary *)createAttributeForLabelWithSize:(CGFloat)size
{
    return [self createAttributeForLabelWithSize:size andColor:[UIColor blackColor]];
}

- (NSDictionary *)createAttributeForLabelWithSize:(CGFloat)size andColor:(UIColor *)color
{
    NSAssert(color, @"");
    NSDictionary *attributes =  @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:size],
                                  NSForegroundColorAttributeName: color,
                                  NSKernAttributeName: [NSNumber numberWithInteger:0.0]};
    
    return attributes;
}

- (void)launchKeyboard
{
    [self.categoryInputTextField becomeFirstResponder];
}

#pragma mark - UIControl Events

- (IBAction)cancelButtonPressed:(id)sender
{
    [self setCancelActionAndNotifyToDelegate];
}

- (void)setCancelActionAndNotifyToDelegate
{
    self.cancelButtonWasPressed = YES;
    [self.delegate cancelButtonWasPressedInCategoryEditorViewController:self];
}

#pragma mark - UITextEditDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSAssert(textField == self.categoryInputTextField, @"No puede venir un textfield diferente");
    BOOL shouldChangeCharacters = [self categoryInputShouldChangeCharactersInRange:range replacementString:string];
    if (shouldChangeCharacters) {
        NSString *categoryTag = [self createCategoryTagByReplaceCategoryInputInRange:range withString:string];
        [self updateVisibilityWithAnimationOfProblemWarningLabelBasedInCategorTag:categoryTag];
    }
    
    return shouldChangeCharacters;
}

- (BOOL)categoryInputShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    static const NSUInteger MAX_LENGHT = 56;
    
    BOOL should = self.categoryInputTextField.text.length < MAX_LENGHT;
    if (!should) {
        should = range.length > 0 && [string isEqualToString:@""];
    }
    
    if (should) {
        should = ![string isEqualToString:@". "];
    }

    return should;
}

- (BOOL)isValidCategoryTag:(NSString *)categoryTag
{
    BOOL isValid = NO;
    
    ValidTagCheckResult validTagCheckResult = [IAECategory isAValidTag:categoryTag];
    if (validTagCheckResult == ValidTag) {
        isValid = YES;
    } else if (validTagCheckResult == InvalidEqualToAnotherTag && self.categoryToRename) {
        isValid = [categoryTag caseInsensitiveCompare:self.categoryToRename.tag] == NSOrderedSame;
    }
    
    return isValid;
}

- (NSString *)createCategoryTagByReplaceCategoryInputInRange:(NSRange)range withString:(NSString *)string
{
    NSString *categoryTag = [self.categoryInputTextField.text stringByReplacingCharactersInRange:range withString:string];
    categoryTag = [categoryTag stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    return categoryTag;
}

- (void)updateVisibilityWithAnimationOfProblemWarningLabelBasedInCategorTag:(NSString *)categoryTag
{
    BOOL isValidCategoryTag = [self isValidCategoryTag:categoryTag];
    BOOL hideWarningLabel = isValidCategoryTag || categoryTag.length == 0;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.problemWarningLabel.alpha = hideWarningLabel ? 0.0 : 1.0;
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSAssert(textField == self.categoryInputTextField, @"");
    
    if (![self notifyToDelegateForNewOrRenamedCategoryIfProceed]) {
        [self setCancelActionAndNotifyToDelegate];
    }

//    [self.categoryInputTextField resignFirstResponder];
    
    return YES;
}

#pragma mark - NotificationCenter

- (BOOL)isClosingWithAValidTagCategory
{
    return self.cancelButtonWasPressed == NO && [self isValidCategoryTag:self.categoryInputTextField.text];
}

- (BOOL)notifyToDelegateForNewOrRenamedCategoryIfProceed
{
    BOOL notify = [self isClosingWithAValidTagCategory];
    if (notify) {
        [self notifyToDelegateForActionCompleted];
    }
    
    return notify;
}

- (void)notifyToDelegateForActionCompleted
{
    NSString *normalizedCategoryTag = [self.categoryInputTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (self.editModeContext == EDITMODE_CATEGORY_ADD) {
        [self.delegate categoryEditorViewController:self DidValidateNewCategoryTag:normalizedCategoryTag ofCategoryType:self.categoryTypeContext];
    } else if (self.editModeContext == EDITMODE_CATEGORY_RENAME && [self categoryTagToRenameDifferentOfCategoryTag:normalizedCategoryTag]) {
        [self.delegate categoryEditorViewController:self DidValidateRenameCategory:self.categoryToRename withTag:normalizedCategoryTag];
    }
}

- (BOOL)categoryTagToRenameDifferentOfCategoryTag:(NSString *)categoryTag
{
    return [self.categoryToRename.tag caseInsensitiveCompare:categoryTag] != NSOrderedSame;
}

@end

