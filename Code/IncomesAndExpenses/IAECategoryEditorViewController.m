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

@interface IAECategoryEditorViewController ()
@property (nonatomic) EdityModeCategoryType editModeContext;
@property (nonatomic) CategoryType categoryTypeContext;
@property (nonatomic, weak) IAECategory *categoryToRename;
@property (weak, nonatomic) IBOutlet UILabel *informationLabel;
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property (weak, nonatomic) IBOutlet UIView *categoryTypeDecoratorView;
@property (weak, nonatomic) IBOutlet UILabel *problemWarningLabel;
@end

@implementation IAECategoryEditorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initModalTransitionAndPresentationStyles];
    }
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureTextLabels];
}

- (void)configureTextLabels
{
    [self configureTitleBarLabel];
    [self configureInputTextFieldDefaultText];
}

- (void)configureTitleBarLabel
{
    self.informationLabel.attributedText = [[NSAttributedString alloc] initWithString:[self stringTagBasedOnEditModeForInformationLabel]
                                                                           attributes:[self createAttributeForLabelWithSize:32]];
}

- (void)configureInputTextFieldDefaultText
{
    self.inputTextField.placeholder = [self stringTagBasedOnEditModeForInputTextField];
}

- (NSString *)stringTagBasedOnEditModeForInformationLabel
{
    NSString *stringTag = nil;
    if ([self isEditModeCategoryInAddMode]) {
        stringTag = NSLocalizedString(@"TAG_ADD_NEW_CATEGORY", @"");
    } else if ([self isEditModeCategoryInRenameMode]) {
        stringTag = NSLocalizedString(@"TAG_RENAME_CATEGORY", @"");
    }
    
    return stringTag;
}

- (NSString *)stringTagBasedOnEditModeForInputTextField
{
    NSString *stringTag = nil;
    if ([self isEditModeCategoryInAddMode]) {
        stringTag = NSLocalizedString(@"TAG_PLACEHOLDER_CATEGORY", "");
    } else if ([self isEditModeCategoryInRenameMode]) {
        stringTag = self.categoryToRename.tag;
    }
    
    return stringTag;
}

- (BOOL)isEditModeCategoryInAddMode
{
    return self.categoryTypeContext == EDITMODE_CATEGORY_ADD;
}

- (BOOL)isEditModeCategoryInRenameMode
{
    return self.categoryTypeContext == EDITMODE_CATEGORY_RENAME;
}

- (NSDictionary *)createAttributeForLabelWithSize:(CGFloat)size
{
    NSDictionary *attributes =  @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:size],
                                  NSForegroundColorAttributeName: [UIColor blackColor],
                                  NSKernAttributeName: [NSNumber numberWithInteger:0.0]};
    
    return attributes;
}

#pragma mark - UIControl Events

- (IBAction)cancelButtonPressed:(id)sender
{
    [self.delegate cancelButtonWasPressedInCategoryEditorViewController:self];
}


@end
