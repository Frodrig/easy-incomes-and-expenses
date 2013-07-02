//
//  IAEYearConfigCardViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 21/12/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEYearConfigCardViewController.h"
#import "IAECurrencyManager.h"
#import "IAEYear.h"
#import "IAEViewCategoryTypeIndicator.h"
#import "IAEViewUtils.h"
#import "IAEConstants.h"
#import <QuartzCore/QuartzCore.h>

@interface IAEYearConfigCardViewController ()

@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalIncomesLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalExpensesLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalBalanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearSubtleLabel;
@property (weak, nonatomic) IBOutlet IAEViewCategoryTypeIndicator *balanceCategoryIndicator;
@property (weak, nonatomic) IBOutlet UIView *openButtonPannel;
@property (weak, nonatomic) IBOutlet UIView *rightPartViewOfYearLabel;
@property (weak, nonatomic) IBOutlet UIButton *openYearButton;
@property (nonatomic) BOOL isActualYearCard;

@end

@implementation IAEYearConfigCardViewController

@synthesize year = year_;
@synthesize yearLabel = yearLabel_;
@synthesize totalIncomesLabel = totalIncomesLabel_;
@synthesize totalExpensesLabel = totalExpensesLabel_;
@synthesize totalBalanceLabel = totalBalanceLabel_;
@synthesize goToYearButton = goToYearButton_;
@synthesize yearSubtleLabel = yearSubtleLabel_;
@synthesize balanceCategoryIndicator = balanceCategoryIndicator_;
@synthesize openButtonPannel = openButtonPannel_;
@synthesize rightPartViewOfYearLabel = rightPartViewOfYearLabel_;
@synthesize openYearButton = openYearButton_;
@synthesize isActualYearCard = isActualYearCard_;

- (id)initWithYear:(IAEYear *)year
{
    self = [super initWithNibName:@"IAEYearConfigCardViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        year_ = year;        
    }
    
    return self;
}

- (id)initWithActualYearCard:(IAEYear *)year
{
    self = [self initWithYear:year];
    if (self) {
        self.isActualYearCard = YES;
    }
    
    return self;
}

- (id)init
{
    return nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return nil;
}

- (void)colorizeLabel:(UILabel *)label basedInValue:(NSDecimalNumber *)value
{
    NSComparisonResult compareResult = [value compare:[NSDecimalNumber zero]];
    label.textColor = compareResult == NSOrderedAscending ? [IAEConstants expenseValueColor] : compareResult == NSOrderedDescending ? [IAEConstants incomeValueColor] : [IAEConstants zeroValueColor];
}

- (void)setYearInfo
{
    self.yearLabel.text = [NSString stringWithFormat:@"%d", self.year.yearDate];
    
    NSUInteger conceptsOfYear = [self.year findAllConcepts].count;
    
    switch (conceptsOfYear) {
        case 0:
            self.yearSubtleLabel.text = NSLocalizedString(@"No items", @"Año sin conceptos");
            break;
        case 1:
            self.yearSubtleLabel.text = NSLocalizedString(@"With 1 item", @"Año con un concepto");
            break;
        default:
            self.yearSubtleLabel.text = [NSString stringWithFormat: NSLocalizedString(@"With %d items", @"Año con mas de un concepto"), conceptsOfYear];
            break;
    }

    self.totalIncomesLabel.text = [[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:self.year.incomes];
    [self colorizeLabel:self.totalIncomesLabel basedInValue:self.year.incomes];

    NSDecimalNumber *negativeExpenseAmount = [self.year.expenses decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"-1"]];
    self.totalExpensesLabel.text = [[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:negativeExpenseAmount];
    [self colorizeLabel:self.totalExpensesLabel basedInValue:negativeExpenseAmount];
    
    NSDecimalNumber *totalBalance = self.year.balance;
    self.totalBalanceLabel.text = [[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:totalBalance];
    [self colorizeLabel:self.totalBalanceLabel basedInValue:totalBalance];
    
    self.balanceCategoryIndicator.category = [totalBalance compare:[NSDecimalNumber zero]] == NSOrderedAscending ? ExpenseCategory : IncomeCategory;
    
    self.goToYearButton.tag = self.year.yearDate;
    
    if (self.isActualYearCard) {
        self.openYearButton.enabled = NO;
        [self.openYearButton setTitle:NSLocalizedString(@"The actual year", @"Indica que estamos sobre el año actual") forState:UIControlStateDisabled];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [IAEViewUtils addRoundedCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft withRadius:10.0 toView:self.balanceCategoryIndicator];
    [IAEViewUtils addRoundedCorners:UIRectCornerTopRight | UIRectCornerBottomRight withRadius:10.0 toView:self.rightPartViewOfYearLabel];
    
    self.openButtonPannel.layer.cornerRadius = 10;
    self.openButtonPannel.layer.masksToBounds = YES;
  
    self.view.layer.cornerRadius = 10;
    self.view.layer.masksToBounds = YES;
    
    [self setYearInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setYearLabel:nil];
    [self setTotalIncomesLabel:nil];
    [self setTotalExpensesLabel:nil];
    [self setTotalBalanceLabel:nil];
    [self setGoToYearButton:nil];
    [self setGoToYearButton:nil];
    [self setYearSubtleLabel:nil];
    [self setBalanceCategoryIndicator:nil];
    [self setOpenButtonPannel:nil];
    [self setRightPartViewOfYearLabel:nil];
    [self setOpenYearButton:nil];
    [super viewDidUnload];
}

@end
