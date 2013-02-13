//
//  IAECategoriesConfigAddViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 04/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAECategoriesConfigAddViewController.h"
#import "IAEViewUtils.h"
#import "IAEConcept.h"
#import "IAEConstants.h"
#import "IAECategoryStore.h"
#import "IAECategory.h"

@interface IAECategoriesConfigAddViewController ()
@property (weak, nonatomic) IBOutlet UIView *backgroundEditingView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *detailedFooterTextLabel;
@property (nonatomic) CategoryType categoryType;
@property (weak, nonatomic) IAECategory *category;
@property (weak, nonatomic) IBOutlet UIView *accesoryCategoryTypeView;
@property (nonatomic) BOOL exitByCancel;
@property (nonatomic) BOOL validCategoryTag;
@property (weak, nonatomic) IBOutlet UILabel *invalidCategoryTagLabel;
@property (weak, nonatomic) IBOutlet UIView *invalidViewCategoryTagInfo;
@property (nonatomic) BOOL fromInputPanel;
@end

@implementation IAECategoriesConfigAddViewController

@synthesize backgroundEditingView = backgroundEditingView_;
@synthesize textField = textField_;
@synthesize detailedFooterTextLabel = detailedFooterTextLabel_;
@synthesize categoryType = categoryType_;
@synthesize category = category_;
@synthesize accesoryCategoryTypeView = accesoryCategoryTypeView_;
@synthesize exitByCancel = exitByCancel_;
@synthesize invalidCategoryTagLabel = invalidCategoryTagLabel_;
@synthesize invalidViewCategoryTagInfo = invalidViewCategoryTagInfo_;
@synthesize validCategoryTag = validCategoryTag_;
@synthesize fromInputPanel = fromInputPanel_;

- (id)initWithCategoryType:(CategoryType)categoryType andRenamingCategory:(IAECategory *)category fromInputPanel:(BOOL)fromInputPanel
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.category = category;
        self.categoryType = categoryType;
        self.fromInputPanel = fromInputPanel;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [IAEViewUtils addRoundedCorners:UIRectCornerAllCorners withRadius:10.0 toView:self.backgroundEditingView];
    self.navigationItem.title = self.categoryType == IncomeCategory ? NSLocalizedString(@"Income categories", @"Titulo para la categoria de ingresos") : NSLocalizedString(@"Expense categories", @"Titulo para la categoria de ingresos");
    if (self.category) {
        self.textField.text = self.category.tag;
    }
    
    self.textField.placeholder = NSLocalizedString(@"Placeholder Category...", @"Placeholder para añadir categoria");
    self.detailedFooterTextLabel.text = self.category ? NSLocalizedString(@"Rename category", @"Renombrar categoria") : NSLocalizedString(@"Add new category", @"Añadir nueva categoria");
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancelar" style:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    self.invalidCategoryTagLabel.text = NSLocalizedString(@"InvalidCategory", @"");
    
    if (self.fromInputPanel) {
        [self.textField becomeFirstResponder];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Nota:
    // - Poner esto en viewDidLoad hace que no se estire
    [IAEViewUtils addRoundedCorners:UIRectCornerAllCorners withRadius:10.0 toView:self.backgroundEditingView];
    [IAEViewUtils addRoundedCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft withRadius:10.0 toView:self.accesoryCategoryTypeView];
    self.accesoryCategoryTypeView.backgroundColor = self.categoryType == IncomeCategory ? [IAEConstants incomeValueColor] : [IAEConstants expenseValueColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.fromInputPanel) {
        [self.textField becomeFirstResponder];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setBackgroundEditingView:nil];
    [self setTextField:nil];
    [self setDetailedFooterTextLabel:nil];
    [self setAccesoryCategoryTypeView:nil];
    [self setInvalidCategoryTagLabel:nil];
    [self setInvalidViewCategoryTagInfo:nil];
    [super viewDidUnload];
}

#pragma mark - UITextEditDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    static const NSUInteger MAX_LENGHT = 36;
    
    // Se puede si:
    // - No sobrepasamos el limite de caracteres
    // - Estamos borrando
    // - No hemos generado un doble tap en el espacio que produce el valor ". "
    BOOL should = textField.text.length < MAX_LENGHT;
    if (!should) {
        should = range.length > 0 && [string isEqualToString:@""];
    }
    if (should) {
        should = ![string isEqualToString:@". "];
    }
    
    if (should) {
        NSString *categoryTag = [textField.text stringByReplacingCharactersInRange:range withString:string];
        categoryTag = [categoryTag stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        switch ([IAECategory isAValidTag:categoryTag]) {
            case InvalidEmptyTag:
            case InvalidWhiteSpaceOnlyTag: {
                self.validCategoryTag = NO;
            } break;
            case InvalidEqualToAnotherTag: {
                if (self.category != nil) {
                    self.validCategoryTag = [categoryTag caseInsensitiveCompare:self.category.tag] == NSOrderedSame;
                } else {
                    self.validCategoryTag = NO;
                }
            } break;
            case ValidTag: {
                self.validCategoryTag = YES;
            } break;
            default: {
            } break;
        };
        
        [UIView animateWithDuration:0.25 animations:^{
            self.invalidViewCategoryTagInfo.alpha = self.validCategoryTag || categoryTag.length == 0 ? 0.0 : 1.0;
        }];
    }
    
    return should;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.exitByCancel = NO;
    [textField resignFirstResponder];

    return YES;
}

#pragma mark - NavigationBar Events

- (void)cancelButtonPressed:(id)sender
{
    self.exitByCancel = YES;
    [self.textField resignFirstResponder];
}

#pragma mark - NotificationCenter

- (void)keyboardDidHide:(NSNotification *)notification
{
    if (!self.exitByCancel && self.validCategoryTag) {
        NSString *textFieldWithoutSpaces = [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        if (self.category) {
            if ([self.category.tag caseInsensitiveCompare:textFieldWithoutSpaces] != NSOrderedSame) {
                self.category.tag = textFieldWithoutSpaces;
            }
        } else {
            [[IAECategoryStore sharedCategoryStore] createCategoryOfType:self.categoryType andTag:textFieldWithoutSpaces withValidityTagCheck:NO];
        }
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.fromInputPanel) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}


@end
