//
//  IAEConceptsViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 04/12/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEConceptsViewController.h"
#import "IAEBook.h"
#import "IAEYear.h"
#import "IAECategory.h"
#import "IAEConcept.h"
#import "IAEMonth.h"
#import "IAEViewCategoryTypeIndicator.h"
#import "IAECurrencyManager.h"
#import "IAEAmountStepperViewController.h"
#import "IAEAnimationManager.h"
#import "IAECategoryStore.h"
#import "IAEConstants.h"
#import "IAEViewUtils.h"
#import "IAEPopoverBackgroundCustom.h"
#import <QuartzCore/QuartzCore.h>

static const NSUInteger LTEXT_SCROLLVIEW_CELLSECTION0_CONCEPTSTABLE = 1;
static const NSUInteger LTEXT_SCROLLVIEW_CELLSECTION1_CONCEPTSTABLE = 100;
static const NSUInteger LTEXT_YEARLABEL_CELLSECTION0_CONCEPTSTABLE = 2;
static const NSUInteger LTEXT_YEARLABELAMOUNT_CELLSECTION0_CONCEPTSTABLE = 3;
static const NSUInteger LTEXT_MONTHLABEL_MONTHBALANCECARD = 10;
static const NSUInteger LTEXT_BALANCELABEL_MONTHBALANCECARD = 20;
static const NSUInteger LTEXT_PAGECONTROL_MONTHBALANCECARD = 300;
static const NSUInteger LTEXT_AMOUNTCATEGORYTAGLABEL_EXTENDEDCONCEPTTABLEVIEW = 500;
static const NSUInteger LTEXT_AMOUNTCATEGORYTYPELABEL_EXTENDEDCONCEPTTABLEVIEW = 510;
static const NSUInteger LTEXT_AMOUNTLABEL_EXTENDEDCONCEPTTABLEVIEW = 520;
static const NSUInteger LTEXT_COUNTLABEL_EXTENDEDCONCEPTTABLEVIEW = 530;
static const NSUInteger LTEXT_VIEWCATEGORYINDICATOR_EXTENDEDCONCEPTTABLEVIEW = 550;
static const NSUInteger LTEXT_LABEL_FOOTERCELLSECTION1_CONCEPTSTABLE = 600;
static const NSUInteger LTEXT_PAGECONTROL_FOOTERCELLSECTION1_CONCEPTSTABLE = 610;
static const NSUInteger LTEXT_COACHARROW_WITHOUTCONCEPTSCELL_CONCEPTSTABLE = 666;
static const NSUInteger LTEXT_CATEGORYTAGLABEL_COMPACTCOMPACTTABLEVEW = 700;
static const NSUInteger LTEXT_AMOUNTLABEL_COMPACTCOMPACTTABLEVEW = 710;
static const NSUInteger LTEXT_PERCENTAGELABEL_COMPACTCOMPACTTABLEVEW = 720;
static const NSUInteger LTEXT_NODATALABEL_COMPACTCOMPACTTABLEVEW = 730;
static const NSUInteger LTEXT_FOOTERTOTALAMOUNT_COMPACTTABLEVIEW = 800;
static const NSUInteger LTEXT_HEADERCATEGORYINDICATOR_COMPACTTABLEVIEW = 900;
static const NSUInteger LTEXT_HEADERCATEGORYLABEL_COMPACTTABLEVIEW = 910;

@interface IAEConceptsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *conceptsTableView;
@property (strong, nonatomic) UITableView *extendedConceptsTableView;
@property (strong, nonatomic) UITableView *compactConceptsTableView;
@property (strong, nonatomic) UITableViewController *changeCategoryTableViewController;
@property (strong, nonatomic) UIPopoverController *changeCategoryPopover;
@property (strong, nonatomic) UIPopoverController *changeAmountPopover;
@property (nonatomic, strong) UIView *headerSection0;
@property (nonatomic, strong) UIView *headerSection1;
@property (nonatomic, strong) UIView *footerSection1;
@property (nonatomic, strong) UIView *footerSection0;
@property (nonatomic, strong) UIView *incomeFooterSectionsForCompactTableView;
@property (nonatomic, strong) UIView *expenseFooterSectionsForCompactTableView;
@property (nonatomic, strong) UIView *incomeHeaderSectionForCompactTableView;
@property (nonatomic, strong) UIView *expenseHeaderSectionForCompactTableView;
@property (nonatomic, strong) NSArray *monthBalanceCards;
@property (nonatomic, strong) NSDecimalNumber *monthBalanceBeforeEditMode;
@property (nonatomic, strong) NSDecimalNumber *yearBalanceBeforeEditMode;
@property (nonatomic) BOOL isEditModeOn;
@property (nonatomic) BOOL yearAndGlobalBalanceAnimated;
@property (nonatomic) BOOL actualMonthWithoutConcepts;
@property (nonatomic, weak) IAEMonth *monthBeforeScrollingInMonthCards;
@property (nonatomic, strong) NSNumber *actualCalculatedIndexMonth;
@property (nonatomic) BOOL pendingSaveByAddingConcepts;
@property (nonatomic) BOOL goToActualMonthAtStarting;
@property (nonatomic) NSUInteger actualMonthIndex;
@end

@implementation IAEConceptsViewController

@synthesize conceptsTableView = conceptsTableView_;
@synthesize extendedConceptsTableView = extendedConceptsTableView_;
@synthesize compactConceptsTableView = compactConceptsTableView_;
@synthesize changeCategoryTableViewController = changeCategoryTableView_;
@synthesize changeCategoryPopover = changeCategoryPopover_;
@synthesize changeAmountPopover = changeAmountPopover_;
@synthesize headerSection0 = headerSection0_;
@synthesize headerSection1 = headerSection1_;
@synthesize footerSection1 = footerSection1_;
@synthesize footerSection0 = footerSection0_;
@synthesize incomeFooterSectionsForCompactTableView = incomeFooterSectionsForCompactTableView_;
@synthesize expenseFooterSectionsForCompactTableView = expenseFooterSectionsForCompactTableView_;
@synthesize incomeHeaderSectionForCompactTableView = incomeHeaderSectionForCompactTableView_;
@synthesize expenseHeaderSectionForCompactTableView = expenseHeaderSectionForCompactTableView_;
@synthesize monthBalanceCards = monthBalanceCards_;
@synthesize selectedYear = selectedYear_;
@synthesize isEditModeOn = isEditModeOn_;
@synthesize yearAndGlobalBalanceAnimated = yearAndGlobalBalanceAnimated_;
@synthesize monthBalanceBeforeEditMode = monthBalanceBeforeEditMode_;
@synthesize yearBalanceBeforeEditMode = yearBalanceBeforeEditMode_;
@synthesize actualMonthWithoutConcepts = actualMonthWithoutConcepts_;
@synthesize monthBeforeScrollingInMonthCards = monthBeforeScrollingInMonthCards_;
@synthesize pendingSaveByAddingConcepts = pendingSaveByAddingConcepts_;
@synthesize goToActualMonthAtStarting = goToActualMonthAtStarting_;
@synthesize actualMonthIndex = actualMonthIndex_;

#pragma mark - Properties

- (UIView *)headerSection0
{
    if (nil == headerSection0_)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HeaderSection0ConceptsTableView" owner:self options:nil];
        headerSection0_ = [nib objectAtIndex:0];
    }
    
    return headerSection0_;
}

- (UIView *)headerSection1
{
    if (nil == headerSection1_)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HeaderSection1ConceptsTableView" owner:self options:nil];
        headerSection1_ = [nib objectAtIndex:0];
    }
    
    return headerSection1_;
}

- (UIView *)footerSection1
{
    if (nil == footerSection1_)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FooterSection1ConceptsTableView" owner:self options:nil];
        footerSection1_ = [nib objectAtIndex:0];
    }
    
    return footerSection1_;
}

- (UIView *)footerSection0
{
    if (nil == footerSection0_)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FooterSection0ConceptsTableView" owner:self options:nil];
        footerSection0_ = [nib objectAtIndex:0];
    }
    
    return footerSection0_;
}

- (UIView *)incomeFooterSectionsForCompactTableView
{
    if (nil == incomeFooterSectionsForCompactTableView_)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FooterCompactMode" owner:self options:nil];
        incomeFooterSectionsForCompactTableView_ = [nib objectAtIndex:0];
    }
    
    return incomeFooterSectionsForCompactTableView_;
}

- (UIView *)expenseFooterSectionsForCompactTableView
{
    if (nil == expenseFooterSectionsForCompactTableView_)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FooterCompactMode" owner:self options:nil];
        expenseFooterSectionsForCompactTableView_ = [nib objectAtIndex:0];
    }
    
    return expenseFooterSectionsForCompactTableView_;
}

- (UIView *)incomeHeaderSectionForCompactTableView
{
    if (nil == incomeHeaderSectionForCompactTableView_)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HeaderCompactMode" owner:self options:nil];
        
        incomeHeaderSectionForCompactTableView_ = [nib objectAtIndex:0];
        
        UILabel *descriptionCategoryLabel = (UILabel *)[incomeHeaderSectionForCompactTableView_ viewWithTag:LTEXT_HEADERCATEGORYLABEL_COMPACTTABLEVIEW];
        IAEViewCategoryTypeIndicator *categoryIndicator = (IAEViewCategoryTypeIndicator *)[incomeHeaderSectionForCompactTableView_ viewWithTag:LTEXT_HEADERCATEGORYINDICATOR_COMPACTTABLEVIEW];
        
        descriptionCategoryLabel.text = @"Incomes";
        categoryIndicator.category = IncomeCategory;
        
        [IAEViewUtils addRoundedCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft withRadius:10.0 toView:categoryIndicator];
    }
    
    return incomeHeaderSectionForCompactTableView_;
}

- (UIView *)expenseHeaderSectionForCompactTableView
{
    if (nil == expenseHeaderSectionForCompactTableView_)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HeaderCompactMode" owner:self options:nil];
        expenseHeaderSectionForCompactTableView_ = [nib objectAtIndex:0];
        
        UILabel *descriptionCategoryLabel = (UILabel *)[expenseHeaderSectionForCompactTableView_ viewWithTag:LTEXT_HEADERCATEGORYLABEL_COMPACTTABLEVIEW];
        
        IAEViewCategoryTypeIndicator *categoryIndicator = (IAEViewCategoryTypeIndicator *)[expenseHeaderSectionForCompactTableView_ viewWithTag:LTEXT_HEADERCATEGORYINDICATOR_COMPACTTABLEVIEW];
        
        descriptionCategoryLabel.text = NSLocalizedString(@"Expenses", @"Titulo asociado a gastos");
        categoryIndicator.category = ExpenseCategory;
        
        [IAEViewUtils addRoundedCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft withRadius:10.0 toView:categoryIndicator];
    }
    
    return expenseHeaderSectionForCompactTableView_;
}

#pragma mark - Methods

- (id)initStartingInMonthIndex:(NSInteger)monthIndex
{
    NSAssert(monthIndex > -1 && monthIndex < 12, @"Intervalo para el indice del mes incorrecto");
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.actualMonthIndex = monthIndex;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        if ([IAEBook sharedBook].years.count > 0) {
            selectedYear_ = [[IAEBook sharedBook].years objectAtIndex:0];
        }
        /*
        self.monthBalanceCards = [NSArray arrayWithObjects:
                                  [[UIViewController alloc] initWithNibName:@"MonthBalanceCardConceptsTableView" bundle:nil], // Enero
                                  [[UIViewController alloc] initWithNibName:@"MonthBalanceCardConceptsTableView" bundle:nil], // Febrero
                                  [[UIViewController alloc] initWithNibName:@"MonthBalanceCardConceptsTableView" bundle:nil], // Marzo
                                  [[UIViewController alloc] initWithNibName:@"MonthBalanceCardConceptsTableView" bundle:nil], // Abril
                                  [[UIViewController alloc] initWithNibName:@"MonthBalanceCardConceptsTableView" bundle:nil], // Mayo
                                  [[UIViewController alloc] initWithNibName:@"MonthBalanceCardConceptsTableView" bundle:nil], // Junio
                                  [[UIViewController alloc] initWithNibName:@"MonthBalanceCardConceptsTableView" bundle:nil], // Julio
                                  [[UIViewController alloc] initWithNibName:@"MonthBalanceCardConceptsTableView" bundle:nil], // Agosto
                                  [[UIViewController alloc] initWithNibName:@"MonthBalanceCardConceptsTableView" bundle:nil], // Septiembre
                                  [[UIViewController alloc] initWithNibName:@"MonthBalanceCardConceptsTableView" bundle:nil], // Octubre
                                  [[UIViewController alloc] initWithNibName:@"MonthBalanceCardConceptsTableView" bundle:nil], // Noviembre
                                  [[UIViewController alloc] initWithNibName:@"MonthBalanceCardConceptsTableView" bundle:nil], // Diciembre
                                  nil];
        */
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newConceptAddedNotification:) name:@"NewConceptAdded" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(conceptRemovedNotification:) name:@"ConceptRemoved" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(categoryCreatedNotification:) name:@"CategoryCreated" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(categoryRemoveNotification:) name:@"CategoryRemoved" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(categoryRenamedNotification:) name:@"CategoryRenamed" object:nil];
        
        NSDate *today = [NSDate date];        
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *monthComponents = [gregorian components:NSMonthCalendarUnit fromDate:today];
        self.actualMonthIndex = [monthComponents month] - 1;
        self.goToActualMonthAtStarting = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    
    // Registro de celdas
    [self.conceptsTableView registerNib:[UINib nibWithNibName:@"Section0ConceptsTableViewCell" bundle:nil] forCellReuseIdentifier:@"Section0Cell"];
    [self.conceptsTableView registerNib:[UINib nibWithNibName:@"Section1ConceptsTableViewCell" bundle:nil] forCellReuseIdentifier:@"Section1Cell"];
    [self.conceptsTableView registerNib:[UINib nibWithNibName:@"Section1WithoutContentConceptsTableViewCell" bundle:nil] forCellReuseIdentifier:@"Section1WithoutConceptsCell"];
    
    self.conceptsTableView.backgroundColor = [UIColor blackColor];
    self.conceptsTableView.backgroundView = nil;
    
    [self reloadYearAndGlobalBalanceInfoAnimated:NO];
    [self updateFooterContentOfConceptsTable];
    [self updateConceptsTableViewHeaderVisibilityWithAnimation:NO];
    
    self.conceptsTableView.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Este metodo se llama cuando el view controller se ha añadido a una jerarquia de views. En este punto todo esta cargado.
    // Aprovechamos para solucionar el problema con las dimensiones del UIScrollView de la celda de meses ya que durante el proceso
    // de creacion la anchura aun no se ha seteado y por lo tanto no podemos calcular correctamente cuanto tiene que medir el ancho
    // del content view del scroll view. En este punto si podemos hacerlo y tomaremos simplemente la anchura del propio scrollview.
    UIScrollView *scrollViewMonths = (UIScrollView *)[self.conceptsTableView viewWithTag:LTEXT_SCROLLVIEW_CELLSECTION0_CONCEPTSTABLE];
    
    CGSize scrollViewContentSize = scrollViewMonths.contentSize;
    scrollViewContentSize.width = scrollViewMonths.bounds.size.width * 12;
    scrollViewMonths.contentSize = scrollViewContentSize;
        
    // Nos ocurre lo mismo con el ScrollView de la celda 1 y sus TableViews
    // En particular hay problemas con el tamaño de los frames en compactConceptsTableView
    UIScrollView *scrollViewConcepts  = (UIScrollView *)[self.conceptsTableView viewWithTag:LTEXT_SCROLLVIEW_CELLSECTION1_CONCEPTSTABLE];
    
    scrollViewContentSize = scrollViewConcepts.contentSize;
    scrollViewContentSize.width = scrollViewConcepts.bounds.size.width * 2;
    scrollViewConcepts.contentSize = scrollViewContentSize;
    
    self.compactConceptsTableView.frame = CGRectMake(scrollViewConcepts.bounds.size.width, 0.0, scrollViewConcepts.bounds.size.width, scrollViewConcepts.bounds.size.height);
    
    if (self.goToActualMonthAtStarting) {
        CGRect monthRectToScroll = CGRectMake(scrollViewMonths.bounds.size.width * self.actualMonthIndex, 0.0, scrollViewMonths.bounds.size.width, scrollViewMonths.bounds.size.height);
        [scrollViewMonths scrollRectToVisible:monthRectToScroll animated:NO];
        IAEMonth *actualMonth = [self actualSelectedMonth];
        self.footerSection1.alpha = actualMonth.concepts.count == 0 ? 0.0 : 1.0;
        self.goToActualMonthAtStarting = NO;
    }
    
    [self configureTableViewBasedInActualMonthConceptsWithInput:NO];

    self.conceptsTableView.hidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)findActualMonthIndex
{
    if (nil == self.actualCalculatedIndexMonth) {
        UIScrollView *actualMonthScrollView = (UIScrollView *)[self.conceptsTableView viewWithTag:LTEXT_SCROLLVIEW_CELLSECTION0_CONCEPTSTABLE];
    
        self.actualCalculatedIndexMonth = [NSNumber numberWithUnsignedInteger:actualMonthScrollView.contentOffset.x / (actualMonthScrollView.contentSize.width / 12)];
    }

    return self.actualCalculatedIndexMonth.unsignedIntegerValue;
}

- (IAEMonth *)findActualMonth
{
    IAEMonth *actualMonth = [self.selectedYear.ordererMonths objectAtIndex:self.goToActualMonthAtStarting ? self.actualMonthIndex : [self findActualMonthIndex]];
        
    return actualMonth;
}

- (void)updateMonthBalanceCardInfo
{
    NSUInteger actualMonthIndex = [self findActualMonthIndex];
    UIViewController *monthCardViewController = (UIViewController *)[self.monthBalanceCards objectAtIndex:actualMonthIndex];
    
    IAEMonth *actualMonth = [self findActualMonth];
    
    [self configureMonthBalanceCard:monthCardViewController withMonth:actualMonth andAnimation:YES];
}

- (void)showExtendedConceptTableView
{
    UIPageControl *pageControll = (UIPageControl *)[self.footerSection1 viewWithTag:LTEXT_PAGECONTROL_FOOTERCELLSECTION1_CONCEPTSTABLE];
    if (pageControll.currentPage == 1)
    {
        UIScrollView *scrollView = (UIScrollView *)[self.conceptsTableView viewWithTag:LTEXT_SCROLLVIEW_CELLSECTION1_CONCEPTSTABLE];
        
        [scrollView scrollRectToVisible:CGRectMake(0.0, 0.0, scrollView.bounds.size.width, scrollView.bounds.size.height) animated:[self actualSelectedMonth].concepts.count > 0 ? YES : NO];
        [self.extendedConceptsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        UILabel *footerLabel = (UILabel *)[self.conceptsTableView viewWithTag:LTEXT_LABEL_FOOTERCELLSECTION1_CONCEPTSTABLE];
        
        footerLabel.text = NSLocalizedString(@"Extended", @"Titulo seccion extendida de la tabla de conceptos");
        
        pageControll.currentPage = 0;
    }
}

- (void)reloadYearAndGlobalBalanceInfoAnimated:(BOOL)animated
{
    UILabel *yearLabel = (UILabel *)[self.headerSection0 viewWithTag:LTEXT_YEARLABEL_CELLSECTION0_CONCEPTSTABLE];
    UILabel *amountLabel = (UILabel *)[self.headerSection0 viewWithTag:LTEXT_YEARLABELAMOUNT_CELLSECTION0_CONCEPTSTABLE];
    
    IAEMonth *actualMonth = [self findActualMonth];
    
    NSDecimalNumber *actualYearBalance = actualMonth.year.balance;
    
    if (animated) {
        [[IAEAnimationManager sharedManager] animateLabelCounterWithLabel:amountLabel
                                                                fromValue:self.yearBalanceBeforeEditMode
                                                                  toValue:actualYearBalance
                                                             withDuration:0.6];
    } else {
        NSString *localizedFormat = NSLocalizedString(@"Year %d, balance:", @"String con formato para describir año y balance en el que estamos");
        yearLabel.text = [NSString stringWithFormat:localizedFormat, [actualMonth.year yearDate]];
        amountLabel.text = [[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:actualYearBalance];
    }
    
    self.yearBalanceBeforeEditMode = actualYearBalance;

    [self setLabelColor:amountLabel basedInValue:actualYearBalance];
}

- (void)goToMonthIndex:(NSInteger)monthIndex
{
    if (monthIndex > -1 && monthIndex < 12 && ![self isEditModeActive]) {
        
    }
}

- (void)goToActualMonth
{
    self.actualCalculatedIndexMonth = nil;
    
    UIScrollView *scrollView = (UIScrollView *)[self.conceptsTableView viewWithTag:LTEXT_SCROLLVIEW_CELLSECTION0_CONCEPTSTABLE];
    CGRect monthRectToScroll = CGRectMake(scrollView.bounds.size.width * self.actualMonthIndex, 0.0, scrollView.bounds.size.width, scrollView.bounds.size.height);
    
    [scrollView scrollRectToVisible:monthRectToScroll animated:NO];
    
    // Al darse una orden explicita de scroll, se llama solo a scrollDidScroll pero no a scrollDidEndDecelerating por lo que forzamos la llamada
    //[self scrollViewDidEndDecelerating:scrollView];
    
    
    //IAEMonth *actualMonth = [self findActualMonth];
    //self.footerSection1.alpha = actualMonth.concepts.count == 0 ? 0.0 : 1.0;
}

- (void)setLabelColor:(UILabel *)label basedInValue:(NSDecimalNumber *)value
{
    NSComparisonResult balanceValueType = [value compare:[NSDecimalNumber zero]];

    if (balanceValueType == NSOrderedSame) {
        label.textColor = [IAEConstants zeroValueColor];
    } else if (balanceValueType == NSOrderedAscending) {
        label.textColor = [IAEConstants expenseValueColor];
    } else if (balanceValueType == NSOrderedDescending) {
        label.textColor = [IAEConstants incomeValueColor];
    }
}

- (void)updateConceptsTableViewHeaderVisibilityWithAnimation:(BOOL)animation
{
    IAEMonth *actualMonth = [self actualSelectedMonth];
    BOOL mustBeVisible = actualMonth.concepts.count > 0;
    BOOL headerHidden = self.headerSection1.hidden;
    if (headerHidden == mustBeVisible) {
        if (animation) {
            [[IAEAnimationManager sharedManager] FadeToShow:mustBeVisible View:self.headerSection1];
        } else {
            self.headerSection1.hidden = !mustBeVisible;
        }
    }
}

- (void)executePendingsSavesByAddingConcepts
{
    if (self.pendingSaveByAddingConcepts) {
        [[IAEBook sharedBook] saveAll];
        self.pendingSaveByAddingConcepts = NO;
    }
}

- (BOOL)isEditModeActive
{
    return [self isEditModeOn];
}

- (IAEYear *)actualDateStateYear
{
    return self.selectedYear;
}

- (IAEMonth *)actualDateStateMonth
{
    return [self findActualMonth];
}

#pragma mark UIScrollView Delegate

- (void)configureTableViewBasedInActualMonthConceptsWithInput:(BOOL)input
{
    // Actualizaciones pesadas basadas en el scroll
    // Actualizamos el page controller del footer
    // Si no hay conceptos:
    // - Ocultamos footer de celda de conceptos.
    // - Impedimos scroll en el UIScrollView de la celda
    // - Impedimos scroll en las tableviews que aloja el scrollview de la celda (el anterior)
    // - Impedimos seleccion de celdas
    // - No mostramos separador
    // Si hay conceptos:
    // - Justo lo contrario a lo anterior
    // Damos orden de recarga de informacion
    IAEMonth *actualMonth = [self findActualMonth];
    
    //UIPageControl *pageControl = (UIPageControl *)[self.footerSection0 viewWithTag:LTEXT_PAGECONTROL_MONTHBALANCECARD];
    //pageControl.currentPage = actualMonth.month - 1;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.footerSection1.alpha = input ? 0.0 : actualMonth.concepts.count == 0 ? 0.0 : 1.0;
    }];
    
    //self.footerSection1.hidden = input ? YES : actualMonth.concepts.count == 0 ? YES : NO;
    
    UIScrollView *scrollViewConceptsCell = (UIScrollView *)[self.conceptsTableView viewWithTag:LTEXT_SCROLLVIEW_CELLSECTION1_CONCEPTSTABLE];
    scrollViewConceptsCell.scrollEnabled = input ? NO : actualMonth.concepts.count == 0 ? NO : YES;
    
    self.extendedConceptsTableView.scrollEnabled = actualMonth.concepts.count == 0 ? NO : YES; //scrollViewConceptsCell.scrollEnabled;
    self.compactConceptsTableView.scrollEnabled = actualMonth.concepts.count == 0 ? NO : YES; //scrollViewConceptsCell.scrollEnabled;
    
    self.extendedConceptsTableView.allowsSelection = actualMonth.concepts.count > 0 ? YES : NO;//!self.footerSection1.hidden;
    self.compactConceptsTableView.allowsSelection = actualMonth.concepts.count > 0 ? YES : NO;//!self.footerSection1.hidden;
    
    self.extendedConceptsTableView.separatorStyle = self.footerSection1.hidden ? UITableViewCellEditingStyleNone : UITableViewCellSeparatorStyleSingleLine;
    self.compactConceptsTableView.separatorStyle = self.footerSection1.hidden ? UITableViewCellEditingStyleNone : UITableViewCellSeparatorStyleSingleLine;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == [self.conceptsTableView viewWithTag:LTEXT_SCROLLVIEW_CELLSECTION0_CONCEPTSTABLE]) {
        self.monthBeforeScrollingInMonthCards = [self actualSelectedMonth];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Actualizaciones ligeras y contínuas basadas en el scroll
    if (scrollView == [self.conceptsTableView viewWithTag:LTEXT_SCROLLVIEW_CELLSECTION0_CONCEPTSTABLE]) {
        // Añadimos +0.5 porque al hacer scroll hacia la izquierda el currentOffset da una posicion mas a la izquierda antes de volverse a corregir por si solo
        NSUInteger pageControlIndex = floor(scrollView.contentOffset.x / scrollView.bounds.size.width + 0.5);
        
        UIPageControl *pageControl = (UIPageControl *)[self.footerSection0 viewWithTag:LTEXT_PAGECONTROL_MONTHBALANCECARD];
        pageControl.currentPage = pageControlIndex;
        
        self.actualCalculatedIndexMonth = nil;
    }
}

- (void)updateFooterContentOfConceptsTable
{
    UIScrollView *conceptsScrollView = (UIScrollView *) [self.conceptsTableView viewWithTag:LTEXT_SCROLLVIEW_CELLSECTION1_CONCEPTSTABLE];
    UIPageControl *pageControll = (UIPageControl *)[self.footerSection1 viewWithTag:LTEXT_PAGECONTROL_FOOTERCELLSECTION1_CONCEPTSTABLE];
    UILabel *modeLabel = (UILabel *)[self.footerSection1 viewWithTag:LTEXT_LABEL_FOOTERCELLSECTION1_CONCEPTSTABLE];
    
    CGPoint actualOffset = conceptsScrollView.contentOffset;
    if (actualOffset.x == CGPointZero.x) {
        modeLabel.text = NSLocalizedString(@"Extended", @"Titulo footer tabla de conceptos para modo extendido");
        pageControll.currentPage = 0;
    } else {
        modeLabel.text = NSLocalizedString(@"Compact", @"Titulo footer tabla de conceptos para modo compacto");
        pageControll.currentPage = 1;
    }    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // Actualizaciones pesadas basadas en el fin del scroll
    if (scrollView == [self.conceptsTableView viewWithTag:LTEXT_SCROLLVIEW_CELLSECTION0_CONCEPTSTABLE]) {
        self.actualCalculatedIndexMonth = nil;
        IAEMonth *actualMonth = [self findActualMonth];
        if (self.monthBeforeScrollingInMonthCards != actualMonth) {
            self.monthBalanceBeforeEditMode = [[actualMonth balance] copy];
            [self configureTableViewBasedInActualMonthConceptsWithInput:NO];
            [self.extendedConceptsTableView reloadData];
            [self.compactConceptsTableView reloadData];
            self.extendedConceptsTableView.contentOffset = CGPointZero;
            self.compactConceptsTableView.contentOffset = CGPointZero;
            [self updateConceptsTableViewHeaderVisibilityWithAnimation:YES];
        }
    } else if (scrollView == [self.conceptsTableView viewWithTag:LTEXT_SCROLLVIEW_CELLSECTION1_CONCEPTSTABLE]) {
        [self updateFooterContentOfConceptsTable];
    }
}

#pragma mark TableView Delegate

- (BOOL)isCellOfIndexPath:(NSIndexPath *)indexPath visibleInTableView:(UITableView *)tableView
{
    CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
    cellRect = [tableView convertRect:cellRect toView:tableView.superview];
    BOOL completelyVisible = CGRectContainsRect(tableView.frame, cellRect);
    
    return completelyVisible;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Sera condicion necesaria, pero no suficiente, que estemos en modo edicion
    
    IAEMonth *actualMonth = [self findActualMonth];
    
    if (tableView == self.extendedConceptsTableView && actualMonth.concepts.count > 0/* && self.isEditModeOn*/) {
        // En caso de que la celda no sea completamente visible hacemos scroll para que lo sea
        if ([self isCellOfIndexPath:indexPath visibleInTableView:tableView]) {
            UIMenuController *menu = [UIMenuController sharedMenuController];
            if (menu.menuItems != nil && menu.menuVisible) {
                [menu setMenuVisible:NO animated:YES];
            } else {
                [self.view becomeFirstResponder];
                
               // if (nil == menu.menuItems) {
                    UIMenuItem *deleteMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete", @"Opcion menu de interaccion concepto para borrar") action:@selector(deleteConceptMenuSelected:)];
                    UIMenuItem *changeCategoryItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Change Category", @"Opcion menu de interaccion concepto para cambiar categoria") action:@selector(changeCategoryMenuSelected:)];
                    UIMenuItem *changeAmountItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Adjust Amount", @"Opcion menu de interaccion concepto para ajustar cantidad") action:@selector(changeAmountMenuSelected:)];
                    menu.menuItems = [NSArray arrayWithObjects:changeCategoryItem, changeAmountItem, deleteMenuItem, nil];
                //}
                
                CGRect rect = [tableView rectForRowAtIndexPath:indexPath];
                rect.origin.y += rect.size.height / 1.5;
                [menu setTargetRect:rect inView:tableView];
                [menu setMenuVisible:YES animated:YES];
            }
        } else {
            [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
    } else if (tableView == self.changeCategoryTableViewController.tableView) {
        if ([[self indexPathOfCategoryInChangeCategoryTableViewForSelectedConcept] compare:indexPath] != NSOrderedSame) {
            NSIndexPath *conceptToChangeCategoryIndexPath = [self.extendedConceptsTableView indexPathForSelectedRow];
            UITableViewCell *changeCategoryCellSelected = [self.changeCategoryTableViewController.tableView cellForRowAtIndexPath:indexPath];
            
            IAECategory *newCategory = [[IAECategoryStore sharedCategoryStore] findCategoryByTag:changeCategoryCellSelected.textLabel.text];
            IAEConcept *conceptToChange = [[[self actualSelectedMonth] allConceptsSortedByDate] objectAtIndex:conceptToChangeCategoryIndexPath.row];
            conceptToChange.category = newCategory;
            [[IAEBook sharedBook] saveAll];

            UITableViewCell *conceptToChangeCategory = [self.extendedConceptsTableView cellForRowAtIndexPath:conceptToChangeCategoryIndexPath];
            [[IAEAnimationManager sharedManager] destroyViewGosthEffect:conceptToChangeCategory withDuration:0.6 andDisplacement:conceptToChangeCategory.bounds.size.height];
            [[IAEAnimationManager sharedManager] destroyViewGosthEffect:conceptToChangeCategory withDuration:0.6 andDisplacement:conceptToChangeCategory.bounds.size.height * -1];
            [self.extendedConceptsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:conceptToChangeCategoryIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.compactConceptsTableView reloadData];
            [self updateMonthBalanceCardInfo];
            [self reloadYearAndGlobalBalanceInfoAnimated:YES];
        
            [self.changeCategoryPopover dismissPopoverAnimated:YES];
            
            self.changeCategoryTableViewController = nil;
            self.changeCategoryPopover =  nil;
        }
    }
}

- (void)configureMonthBalanceCard:(UIViewController *)viewController withMonth:(IAEMonth *)month andAnimation:(BOOL)animation
{
    NSDecimalNumber *monthBalance = [month balance];
    UILabel *monthLabel = (UILabel *)[viewController.view viewWithTag:LTEXT_MONTHLABEL_MONTHBALANCECARD];
    monthLabel.text = [month description];
        
    UILabel *balanceLabel = (UILabel *)[viewController.view viewWithTag:LTEXT_BALANCELABEL_MONTHBALANCECARD];
        
    if (month.concepts.count == 0) {
        balanceLabel.text = NSLocalizedString(@"No items", @"Para indicar que no hay conceptos vinculados");
    } else {
        BOOL isTheActualSelectedMonth = month == [self actualSelectedMonth];
        
        if (animation) {
            if (isTheActualSelectedMonth && [self.monthBalanceBeforeEditMode compare:monthBalance] != NSOrderedSame)  {
                [[IAEAnimationManager sharedManager] animateLabelCounterWithLabel:balanceLabel fromValue:self.monthBalanceBeforeEditMode toValue:monthBalance withDuration:0.6];
            }
        } else {
            balanceLabel.text = [[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:monthBalance];
        }
        
        if (isTheActualSelectedMonth) {
            self.monthBalanceBeforeEditMode = [monthBalance copy];
        }
    }
    [self setLabelColor:balanceLabel basedInValue:monthBalance];
}

- (void)configureMonthsBalanceCards
{
    NSArray *monthsOfSelectedYear = self.selectedYear.ordererMonths;
    
    for (NSUInteger idx = 0; idx < monthsOfSelectedYear.count; ++idx) {
        UIViewController *monthBalanceCard = (UIViewController *)[self.monthBalanceCards objectAtIndex:idx];
        IAEMonth *moth = (IAEMonth *)[monthsOfSelectedYear objectAtIndex:idx];
        
        [self configureMonthBalanceCard:monthBalanceCard withMonth:moth andAnimation:NO];
    }
}

- (void)createAndPrepareMonthBalanceCardsIn:(UIScrollView *)scrollView
{
    // 12 ViewControllers. Uno por mes.
    
    self.monthBalanceCards = [NSArray arrayWithObjects:
                              [[UIViewController alloc] initWithNibName:@"MonthBalanceCardConceptsTableView" bundle:nil], // Enero
                              [[UIViewController alloc] initWithNibName:@"MonthBalanceCardConceptsTableView" bundle:nil], // Febrero
                              [[UIViewController alloc] initWithNibName:@"MonthBalanceCardConceptsTableView" bundle:nil], // Marzo
                              [[UIViewController alloc] initWithNibName:@"MonthBalanceCardConceptsTableView" bundle:nil], // Abril
                              [[UIViewController alloc] initWithNibName:@"MonthBalanceCardConceptsTableView" bundle:nil], // Mayo
                              [[UIViewController alloc] initWithNibName:@"MonthBalanceCardConceptsTableView" bundle:nil], // Junio
                              [[UIViewController alloc] initWithNibName:@"MonthBalanceCardConceptsTableView" bundle:nil], // Julio
                              [[UIViewController alloc] initWithNibName:@"MonthBalanceCardConceptsTableView" bundle:nil], // Agosto
                              [[UIViewController alloc] initWithNibName:@"MonthBalanceCardConceptsTableView" bundle:nil], // Septiembre
                              [[UIViewController alloc] initWithNibName:@"MonthBalanceCardConceptsTableView" bundle:nil], // Octubre
                              [[UIViewController alloc] initWithNibName:@"MonthBalanceCardConceptsTableView" bundle:nil], // Noviembre
                              [[UIViewController alloc] initWithNibName:@"MonthBalanceCardConceptsTableView" bundle:nil], // Diciembre
                              nil];
    
    UIViewController *referenceController = [self.monthBalanceCards objectAtIndex:0];
    
    // ScrollView Content Size
    CGSize scrollViewSize = scrollView.bounds.size;
    
    scrollViewSize.width *= 12;
    scrollView.contentSize = scrollViewSize;
    
    // Insercion en ScrollView
    CGRect frame = CGRectMake(0.0, 0.0, scrollView.bounds.size.width, scrollView.bounds.size.height);
    referenceController.view.frame = frame;
    
    [scrollView addSubview:referenceController.view];
    
    NSUInteger idx = 1;
    do {
        UIViewController *idxController = [self.monthBalanceCards objectAtIndex:idx];
        
        frame.origin.x += frame.size.width;
        
        idxController.view.frame = frame;
        
        [scrollView addSubview:idxController.view];
        
    } while (++idx < self.monthBalanceCards.count);
    
    scrollView.scrollEnabled = YES;
    scrollView.pagingEnabled = YES;
    scrollView.bounces = YES;
    scrollView.alwaysBounceVertical = NO;
    scrollView.alwaysBounceHorizontal = YES;
    scrollView.delegate = self;
    
    // Configuracion de las cards con el año actual
    [self configureMonthsBalanceCards];
}

- (void)createAndPrepareConceptsTableViewsIn:(UIScrollView *)scrollView
{
    CGRect tableViewsFrame = CGRectMake(0.0, 0.0, scrollView.bounds.size.width, scrollView.bounds.size.height);
    
    self.extendedConceptsTableView = [[UITableView alloc] initWithFrame:tableViewsFrame style:UITableViewStylePlain];
    self.extendedConceptsTableView.delegate = self;
    self.extendedConceptsTableView.dataSource = self;
    self.extendedConceptsTableView.showsHorizontalScrollIndicator = NO;
    self.extendedConceptsTableView.showsVerticalScrollIndicator = NO;
    self.extendedConceptsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.extendedConceptsTableView.separatorColor = [UIColor clearColor];
    self.extendedConceptsTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.extendedConceptsTableView.backgroundColor = [IAEConstants sectionsTablesBackgroundColor];
    [self.extendedConceptsTableView registerNib:[UINib nibWithNibName:@"ExtendedConceptsTableViewCell" bundle:nil] forCellReuseIdentifier:@"ExtendedConceptsCell"];

    
    tableViewsFrame.origin.x += tableViewsFrame.size.width;
    self.compactConceptsTableView = [[UITableView alloc] initWithFrame:tableViewsFrame style:UITableViewStylePlain];
    self.compactConceptsTableView.delegate = self;
    self.compactConceptsTableView.dataSource = self;
    self.compactConceptsTableView.showsHorizontalScrollIndicator = NO;
    self.compactConceptsTableView.showsVerticalScrollIndicator = NO;
    self.compactConceptsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.compactConceptsTableView.separatorColor = [UIColor clearColor];
    self.compactConceptsTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.compactConceptsTableView.backgroundColor = [IAEConstants sectionsTablesBackgroundColor];
    [self.compactConceptsTableView registerNib:[UINib nibWithNibName:@"CompactConceptsTableViewCell" bundle:nil] forCellReuseIdentifier:@"CompactConceptsCell"];
    
    scrollView.contentSize = CGSizeMake(scrollView.bounds.size.width * 2, scrollView.bounds.size.height);
    [scrollView addSubview:self.extendedConceptsTableView];
    [scrollView addSubview:self.compactConceptsTableView];
    
    scrollView.delegate = self;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat retValue = 44;

 //   NSString *nibName;

    if (tableView == self.conceptsTableView)
    {
        if (indexPath.section == 0) {
            //nibName = @"Section0ConceptsTableViewCell";
            retValue = 88;
        } else if (indexPath.section == 1) {
            retValue = 356;
            //nibName = @"Section1ConceptsTableViewCell";
        }
    }
    else if (tableView == self.extendedConceptsTableView) {
        IAEMonth *actualMonth = [self findActualMonth];
        retValue = actualMonth.concepts.count == 0 ? 325 : 101;
        //nibName = actualMonth.concepts.count == 0 ? @"Section1WithoutContentConceptsTableViewCell" : @"ExtendedConceptsTableViewCell";
    }
    else if (tableView == self.compactConceptsTableView) {
        IAEMonth *actualMonth = [self findActualMonth];
        retValue = actualMonth.concepts.count == 0 ? 325 : 66;
        //nibName = actualMonth.concepts.count == 0 ? @"Section1WithoutContentConceptsTableViewCell" : @"CompactConceptsTableViewCell";
    }
    
    /*
    if (nibName) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
        UIView *referenceView = [nib objectAtIndex:0];
        
        retValue = referenceView.bounds.size.height;
    }
    else
        retValue = 44;
    */
    return retValue;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // 0 -> Year, month, balance section
    // 1 -> Concepts section
    UIView *retView;
    if (tableView == self.conceptsTableView) {
        retView = 0 == section ? self.headerSection0 : self.headerSection1;
    }
    else if (tableView == self.compactConceptsTableView) {
        // Solo si hay conceptos
        if ([self findActualMonth].concepts.count > 0)
            retView = IncomeCategory == section ? self.incomeHeaderSectionForCompactTableView : self.expenseHeaderSectionForCompactTableView;
    } else if (tableView == self.changeCategoryTableViewController.tableView) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 185.0, 32.0)];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.contentMode = UIViewContentModeTop;
        label.text = section == 0 ? NSLocalizedString(@"Income Categories", @"Titulo seccion categorias de ingresos") : NSLocalizedString(@"Expense Categories", @"Titulo seccion categoria de gastos");
        
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.bounds.size.width, 32.0)];
        containerView.contentMode = UIViewContentModeTop;
        [IAEViewUtils addRoundedCorners:UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight withRadius:4.0 toView:containerView];
        containerView.backgroundColor = section == 0 ? [IAEConstants incomeValueColor] : [IAEConstants expenseValueColor];
        [containerView addSubview:label];
        
        retView = containerView;
    }
    
    return retView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *retView;
    
    if (tableView == self.conceptsTableView)
    {
        // 0 -> MonthSection
        // 1 -> Concepts section
        if (0 == section)
            retView = self.footerSection0;
        else if (1 == section)
            retView = self.footerSection1;
    }
    else if (tableView == self.compactConceptsTableView)
    {
        // Solo si hay conceptos
        IAEMonth *actualMonth = [self findActualMonth];
        
        if (actualMonth.concepts.count > 0)
        {
            UIView *footerView = section == IncomeCategory ? self.incomeFooterSectionsForCompactTableView : self.expenseFooterSectionsForCompactTableView;
            
            UILabel *amountLabelFooter = (UILabel *)[footerView viewWithTag:LTEXT_FOOTERTOTALAMOUNT_COMPACTTABLEVIEW];
            
            NSDecimalNumber *amount = section == IncomeCategory ? [actualMonth incomes] : [actualMonth expenses];
            if (section == ExpenseCategory)
                amount = [amount decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"-1"]];
            
            amountLabelFooter.text = [NSString stringWithFormat:@"%@",[[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:amount]];
            
            [self setLabelColor:amountLabelFooter basedInValue:amount];

            retView = footerView;
        }
    }
    
    return retView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat retHeight = 0;
    if (tableView == self.conceptsTableView) {
        retHeight = IncomeCategory == section ? self.headerSection0.bounds.size.height : self.headerSection1.bounds.size.height;
    }
    else if (tableView == self.compactConceptsTableView) {
        // Solo si hay conceptos
        if ([self findActualMonth].concepts.count > 0)
            retHeight = self.incomeHeaderSectionForCompactTableView.bounds.size.height;
    } else if (tableView == self.changeCategoryTableViewController.tableView) {
        retHeight = 32.0;
    }
    
    return retHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat retHeight = 0;
    
    if (self.conceptsTableView == tableView)
    {
        if (IncomeCategory == section)
            retHeight = self.footerSection0.bounds.size.height;
        else
            retHeight = self.footerSection1.bounds.size.height;
    }
    else if (self.compactConceptsTableView == tableView)
    {
        // Solo si hay conceptos
        if ([self findActualMonth].concepts.count > 0)
        {
            UIView *footerView = IncomeCategory == section ? self.incomeFooterSectionsForCompactTableView : self.expenseFooterSectionsForCompactTableView;
            retHeight = footerView.bounds.size.height;
        }
    }
    return retHeight;
}

#pragma mark TableView DataSource

- (UITableViewCell *)conceptsTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == 0)
    {
        static NSString *cellIdentifier = @"Section0Cell";
        
        cell = [self.conceptsTableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        [self createAndPrepareMonthBalanceCardsIn:(UIScrollView *)[cell viewWithTag:LTEXT_SCROLLVIEW_CELLSECTION0_CONCEPTSTABLE]];
    }
    else
    {
        static NSString *cellIdentifier = @"Section1Cell";
            
        cell = [self.conceptsTableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
        [self createAndPrepareConceptsTableViewsIn:(UIScrollView *)[cell viewWithTag:LTEXT_SCROLLVIEW_CELLSECTION1_CONCEPTSTABLE]];
    }
    
    return cell;
}

- (UITableViewCell *)extendedConceptsTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ExtendedConceptsCell";
    
    UITableViewCell *cell = [self.extendedConceptsTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    UILabel *categoryLabel = (UILabel *)[cell viewWithTag:LTEXT_AMOUNTCATEGORYTAGLABEL_EXTENDEDCONCEPTTABLEVIEW];
    UILabel *categoryTypeLabel = (UILabel *)[cell viewWithTag:LTEXT_AMOUNTCATEGORYTYPELABEL_EXTENDEDCONCEPTTABLEVIEW];
    UILabel *amountLabel = (UILabel *)[cell viewWithTag:LTEXT_AMOUNTLABEL_EXTENDEDCONCEPTTABLEVIEW];
    UILabel *counterLabel = (UILabel *)[cell viewWithTag:LTEXT_COUNTLABEL_EXTENDEDCONCEPTTABLEVIEW];
    
    IAEViewCategoryTypeIndicator *categoryIndicatorView = (IAEViewCategoryTypeIndicator *)[cell viewWithTag:LTEXT_VIEWCATEGORYINDICATOR_EXTENDEDCONCEPTTABLEVIEW];

    [categoryIndicatorView applyRoundedCorners];
    
    IAEMonth *actualMonth = [self findActualMonth];
    
    NSArray *concepts = [actualMonth allConceptsSortedByDate];
    
    IAEConcept *concept = [concepts objectAtIndex:indexPath.row];
    
    categoryLabel.text = [concept.category localizedTag];
    categoryTypeLabel.text = concept.category.categoryType == IncomeCategory ? NSLocalizedString(@"Income", @"Ingreso") : NSLocalizedString(@"Expense", @"Gasto");
    
    amountLabel.text = [[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:concept.category.categoryType == ExpenseCategory ? [concept.amount decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"-1"]] : concept.amount];
    
    categoryIndicatorView.category = concept.category.categoryType;
    
    counterLabel.text = [NSString stringWithFormat:@"%d", actualMonth.concepts.count - indexPath.row];
    
    return cell;
}

- (UITableViewCell *)compactConceptsTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CompactConceptsCell";
    
    UITableViewCell *cell = [self.compactConceptsTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    UILabel *categoryLabel = (UILabel *)[cell viewWithTag:LTEXT_CATEGORYTAGLABEL_COMPACTCOMPACTTABLEVEW];
    UILabel *amountLabel = (UILabel *)[cell viewWithTag:LTEXT_AMOUNTLABEL_COMPACTCOMPACTTABLEVEW];
    UILabel *percentageLabel = (UILabel *)[cell viewWithTag:LTEXT_PERCENTAGELABEL_COMPACTCOMPACTTABLEVEW];
    UILabel *noDataLabel = (UILabel *)[cell viewWithTag:LTEXT_NODATALABEL_COMPACTCOMPACTTABLEVEW];

    // 0 -> incomes section
    // 1 -> expense section
    IAEMonth *actualMonth = [self findActualMonth];
    
    BOOL categorySectionWithData = indexPath.section == 0 ? [actualMonth incomes].floatValue > 0.0 : [actualMonth expenses].floatValue > 0.0;
    
    if (categorySectionWithData)
    {
        //NSArray *categoriesOfConcepts = [actualMonth findAllCategoriesInConceptsOfType:indexPath.section == 0 ? IncomeCategory : ExpenseCategory];
     
        NSArray *categoriesOfConcepts = [actualMonth findAllCategoriesSortedByAbsoluteValueOfAmountsInConceptsOfType:indexPath.section == 0 ? IncomeCategory : ExpenseCategory];

        IAECategory* categoryOfCell = [categoriesOfConcepts objectAtIndex:indexPath.row];
        categoryLabel.text = [categoryOfCell localizedTag];
    
        NSDecimalNumber *categoryAmount = [actualMonth balanceOfAllConceptsOfCategory:categoryOfCell];
                
        amountLabel.text = indexPath.section == 0 ? [[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:categoryAmount] : [[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:[categoryAmount decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"-1"]]]
;
    
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterPercentStyle;
        formatter.locale = [NSLocale currentLocale];
        formatter.maximumFractionDigits = 2;
        formatter.minimumFractionDigits = 2;
        
        NSDecimalNumber *totalAmount = indexPath.section == 0 ? [actualMonth incomes] : [actualMonth expenses];
        NSDecimalNumber *percentageAmount = [categoryAmount decimalNumberByDividingBy:totalAmount];
        
        percentageLabel.text = [formatter stringFromNumber:percentageAmount];

        noDataLabel.hidden = YES;
    }
    else
    {
        categoryLabel.text = @"";
        amountLabel.text = @"";
        percentageLabel.text = @"";
        
        noDataLabel.hidden = NO;
    }
    
    return cell;
}

- (NSIndexPath *)indexPathOfCategoryInChangeCategoryTableViewForSelectedConcept
{
    NSIndexPath *selectedCellIndex = [self.extendedConceptsTableView indexPathForSelectedRow];
    IAEMonth *actualMonth = [self actualSelectedMonth];
    NSArray *concepts = [actualMonth allConceptsSortedByDate];
    IAEConcept *selectedConcept = [concepts objectAtIndex:selectedCellIndex.row];
    
    NSArray *categories = [NSArray arrayWithObject:selectedConcept.category.categoryType == IncomeCategory ? [[IAECategoryStore sharedCategoryStore] generalIncomeCategory] : [[IAECategoryStore sharedCategoryStore] generalExpenseCategory]];
    categories = [categories arrayByAddingObjectsFromArray:[[IAECategoryStore sharedCategoryStore] allUserCategoriesOfType:selectedConcept.category.categoryType]];
    
    NSUInteger indexOfCategoryInCategoriesType = [categories indexOfObject:selectedConcept.category];
    
    NSIndexPath *retIndexPath = [NSIndexPath indexPathForRow:indexOfCategoryInCategoriesType inSection:selectedConcept.category.categoryType];
    return retIndexPath;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (tableView == self.conceptsTableView)
        cell = [self conceptsTableViewCellForRowAtIndexPath:indexPath];
    else if (tableView == self.changeCategoryTableViewController.tableView) {
        static NSString *cellIdentifier = @"ChangeCategoryCellIdentifier";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:22.0]];
            cell.backgroundColor = [UIColor blackColor];
         }
        
        NSArray *categories = [NSArray arrayWithObject:indexPath.section == 0 ? [[IAECategoryStore sharedCategoryStore] generalIncomeCategory] : [[IAECategoryStore sharedCategoryStore] generalExpenseCategory]];
        categories = [categories arrayByAddingObjectsFromArray:[[IAECategoryStore sharedCategoryStore] allUserCategoriesOfType:indexPath.section == 0 ? IncomeCategory : ExpenseCategory]];
        IAECategory *category = [categories objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [category localizedTag];
        NSIndexPath *selectedCellIndex = [self.extendedConceptsTableView indexPathForSelectedRow];
        IAEMonth *actualMonth = [self actualSelectedMonth];
        NSArray *concepts = [actualMonth allConceptsSortedByDate];
        IAEConcept *selectedConcept = [concepts objectAtIndex:selectedCellIndex.row];
        if (selectedConcept.category == category) {
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"17-check.png"]];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else {
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.accessoryView = nil;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
    }
    else
    {
        IAEMonth *actualMonth = [self findActualMonth];
        self.actualMonthWithoutConcepts = actualMonth.concepts.count == 0;
        if (self.actualMonthWithoutConcepts) {
            static NSString *cellIdentifier = @"Section1WithoutConceptsCell";
            cell = [self.conceptsTableView dequeueReusableCellWithIdentifier:cellIdentifier];
            self.actualMonthWithoutConcepts = YES;
        }
        else {
            if (tableView == self.compactConceptsTableView)
                cell = [self compactConceptsTableViewCellForRowAtIndexPath:indexPath];
            else if (tableView == self.extendedConceptsTableView)
                cell = [self extendedConceptsTableViewCellForRowAtIndexPath:indexPath];
        }
    }

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger retValue = 0;
    
    if (tableView == self.conceptsTableView)
    {
        // Tanto en seccion 0 como en seccion 1 hay solo una (super)celda.
        retValue = 1;
    }
    else if (tableView == self.extendedConceptsTableView)
    {
        // En caso de no haber conceptos se creara una celda especial
        IAEMonth *actualMonth = [self findActualMonth];
        
        retValue = MAX(actualMonth.concepts.count, 1);
    }
    else if (tableView == self.compactConceptsTableView)
    {
        // 0 -> Income Section
        // 1 -> Expense Section
        // Si para una de las secciones no hay contenido usaremos una celda vacía
        IAEMonth *actualMonth = [self findActualMonth];
        
        NSArray *categoriesOfConcepts = [actualMonth findAllCategoriesInConceptsOfType:section == 0 ? IncomeCategory : ExpenseCategory];
        
        retValue = MAX(categoriesOfConcepts.count, 1);
    }
    else if (tableView == self.changeCategoryTableViewController.tableView) {
        // +1 es la categoria general
        NSArray *categories = [[IAECategoryStore sharedCategoryStore] allUserCategoriesOfType:section == 0 ? IncomeCategory : ExpenseCategory];
        retValue = categories.count + 1;
    }
    
    return retValue;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger retValue = 0;
    
    if (tableView == self.conceptsTableView) {
        // 1 -> Year, Month, Balance
        // 2 -> Concepts
        retValue = 2;
    } else if (tableView == self.extendedConceptsTableView) {
        // 1 -> Todos los conceptos
        retValue = 1;
    }
    else if (tableView == self.compactConceptsTableView) {
        // 1 -> Conceptos de tipo income agrupados
        // 2 -> Conceptos de tipo expense agrupados
        retValue = 2;
    } else if (tableView == self.changeCategoryTableViewController.tableView) {
        retValue = 2;
    }
    
    return retValue;
}

- (void)viewDidUnload {
    [self setConceptsTableView:nil];
    [super viewDidUnload];
}

- (void)dealloc
{    
    [self.view removeFromSuperview];
    
    self.extendedConceptsTableView = nil;
    self.compactConceptsTableView = nil;
    self.changeCategoryTableViewController = nil;
    self.changeCategoryPopover = nil;
    self.changeAmountPopover = nil;
    self.headerSection0 = nil;
    self.headerSection1 = nil;
    self.footerSection1 = nil;
    self.footerSection0 = nil;
    self.incomeFooterSectionsForCompactTableView = nil;
    self.expenseFooterSectionsForCompactTableView = nil;
    self.incomeHeaderSectionForCompactTableView = nil;
    self.expenseHeaderSectionForCompactTableView = nil;
    self.monthBalanceCards = nil;
    self.monthBalanceBeforeEditMode = nil;
    self.yearBalanceBeforeEditMode = nil;
    self.actualCalculatedIndexMonth = nil;
}

#pragma mark - IAEInputConceptsDelegate

- (void)inputChangePosition:(CGFloat)offsetY
{
    self.view.center = CGPointMake(self.view.center.x, self.view.center.y + offsetY);
}

- (void)inputShowed
{
    // En el caso de ser mostrado el input tenemos que estar en modo extendido con los conceptos
    [self showExtendedConceptTableView];
    
    [self configureTableViewBasedInActualMonthConceptsWithInput:YES];
    
    IAEMonth *actualMonth = [self findActualMonth];
    
    self.monthBalanceBeforeEditMode = [[actualMonth balance] copy];
    self.yearBalanceBeforeEditMode = [[self.selectedYear balance] copy];
    
    self.isEditModeOn = YES;
}

- (void)inputHidden
{
    [self executePendingsSavesByAddingConcepts];
    
    [self configureTableViewBasedInActualMonthConceptsWithInput:NO];
    
    [self updateMonthBalanceCardInfo];
    [self reloadYearAndGlobalBalanceInfoAnimated:YES];
    [self.compactConceptsTableView reloadData];

    self.isEditModeOn = NO;
}

- (void)inputChangeCategoryModeToIncome
{
    [self executePendingsSavesByAddingConcepts];
}

- (void)inputChangeCategoryModeToExpense
{
    [self executePendingsSavesByAddingConcepts];
}

- (void)applyAnimationToHideAndShowWithOffset:(CGFloat)offsetY andDuration:(CGFloat)duration andSpeed:(CGFloat)speed
{
    CABasicAnimation *mov = [CABasicAnimation animationWithKeyPath:@"position"];
    
    mov.duration = duration;
    mov.fromValue = [NSValue valueWithCGPoint:self.view.layer.position];
    
    CGPoint endPoint = CGPointMake(self.view.layer.position.x, self.view.layer.position.y + offsetY);
    mov.toValue = [NSValue valueWithCGPoint:endPoint];
    mov.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    mov.speed = speed;

    [self.view.layer addAnimation:mov forKey:@"position"];
    
    // Nota: Garantiza que al terminar no se retorna a posicion original
    self.view.layer.position = endPoint;
}

- (void)inputAnimationShowedWithOffset:(CGFloat)offsetY andDuration:(CGFloat)duration andSpeed:(CGFloat)speed
{
    [self applyAnimationToHideAndShowWithOffset:-offsetY andDuration:duration andSpeed:speed];
                   
    [self inputShowed];
}

- (void)inputAnimationHiddenWithOffset:(CGFloat)offsetY andDuration:(CGFloat)duration andSpeed:(CGFloat)speed
{
    [self applyAnimationToHideAndShowWithOffset:offsetY andDuration:duration andSpeed:speed];

    [self inputHidden];
}

- (void)inputHiddenWithAnimation:(CABasicAnimation *)animation
{
    [self.view.layer addAnimation:animation forKey:@"position"];
    
    [self inputHidden];
}

#pragma mark - IAEInputConceptsDataSource

- (IAEMonth *)actualSelectedMonth
{
    return [self findActualMonth];
}

#pragma mark - NotificationCenter

- (void)newConceptAddedNotification:(NSNotification *)notification
{
    self.pendingSaveByAddingConcepts = YES;

    NSDictionary *userInfo = [notification userInfo];
    
    IAEMonth *month = [userInfo objectForKey:@"Month"];
    
    if (month == [self actualSelectedMonth])
    {
        //[self updateMonthBalanceCardInfo];
                
        // OJO: Este evento se manda cuando YA HA SIDO CREADO EL CONCEPTO por lo que si count vale 1 singifica que venia de no haber nada y hay que hacer reloadcompleto
        if (month.concepts.count == 1)
        {
            
            [self.extendedConceptsTableView beginUpdates];
            [self.extendedConceptsTableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            [self.extendedConceptsTableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            [self.extendedConceptsTableView endUpdates];
            
            
            self.extendedConceptsTableView.allowsSelection = self.compactConceptsTableView.allowsSelection = YES;
        }
        else
        {
            [self.extendedConceptsTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.extendedConceptsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:UITableViewRowAnimationAutomatic];
            UITableViewCell *cell = [self.extendedConceptsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            [[IAEAnimationManager sharedManager] scaleFrom:CATransform3DMakeScale(0.8, 0.8, 1.0) to:CATransform3DIdentity forAnimation:cell];
        }
    
        [self updateConceptsTableViewHeaderVisibilityWithAnimation:!self.isEditModeOn];
    }
}

- (void)categoryCreatedNotification:(NSNotification *)notification
{
    [[IAEBook sharedBook] saveAll];
}

- (void)categoryRemoveNotification:(NSNotification *)notification
{
    [[IAEBook sharedBook] saveAll];

    [self.extendedConceptsTableView reloadData];
    [self.compactConceptsTableView reloadData];
}

- (void)categoryRenamedNotification:(NSNotification *)notification
{
    [[IAEBook sharedBook] saveAll];
    
    [self.extendedConceptsTableView reloadData];
    [self.compactConceptsTableView reloadData];
}

#pragma mark - IAEAmountStepperViewControllerDelegate

- (void)onMinusButtonPressed:(id)amountStepperViewController withAmount:(NSNumber *)value
{
    [self changeAmountInSelectedConceptRowByValue:[NSDecimalNumber decimalNumberWithString:value.stringValue]];
}

- (void)onPlusButtonPressed:(id)amountStepperViewController withAmount:(NSNumber *)value
{
    [self changeAmountInSelectedConceptRowByValue:[NSDecimalNumber decimalNumberWithString:value.stringValue]];
}

- (void)changeAmountInSelectedConceptRowByValue:(NSDecimalNumber *)value
{
    // TODO: Codigo horror
    // Tip importante: los conceptos guardan su valor en valor absoluto y es el tipo de categoria lo que los cualifica
    NSIndexPath *conceptCellToChangeAmountIndex = [self.extendedConceptsTableView indexPathForSelectedRow];
    UITableViewCell *cellToChangeAmount = [self.extendedConceptsTableView cellForRowAtIndexPath:conceptCellToChangeAmountIndex];
    IAEConcept *concept = [[[self actualSelectedMonth] allConceptsSortedByDate] objectAtIndex:conceptCellToChangeAmountIndex.row];
    NSDecimalNumber *actualValue = [concept amount];
    NSDecimalNumber *stepperValue = concept.category.categoryType == IncomeCategory ? [actualValue decimalNumberByAdding:value] : [actualValue decimalNumberBySubtracting:value];
   
    if ([stepperValue compare:[NSDecimalNumber zero]] != NSOrderedSame) {
        BOOL passCheckLimits = [stepperValue compare:[IAEConstants maxDecimalNumberAllowed]] != NSOrderedDescending;
        if (passCheckLimits) {
            NSComparisonResult compareValues = [actualValue compare:stepperValue];
            UILabel *labelAmount = (UILabel *)[cellToChangeAmount viewWithTag:LTEXT_AMOUNTLABEL_EXTENDEDCONCEPTTABLEVIEW];
            [[IAEAnimationManager sharedManager] destroyViewGosthEffect:labelAmount withDuration:0.5 andDisplacement:compareValues == NSOrderedAscending ? 44.0 : -44.0];
            if (concept.category.categoryType == ExpenseCategory) {
                labelAmount.text = [[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:[stepperValue decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"-1"]]];
            } else {
                labelAmount.text = [[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:stepperValue];
            }
    
            concept.amount = stepperValue;
            [[IAEBook sharedBook] saveAll];
        }
    }
}

#pragma mark - MenuControllerNotification

- (void)changeCategoryMenuSelected:(id)sender
{
    self.changeCategoryTableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.changeCategoryTableViewController.tableView.backgroundColor = [UIColor blackColor];
    self.changeCategoryTableViewController.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.changeCategoryTableViewController.tableView.showsVerticalScrollIndicator = self.changeCategoryTableViewController.tableView.showsHorizontalScrollIndicator = NO;
    self.changeCategoryTableViewController.tableView.delegate = self;
    self.changeCategoryTableViewController.tableView.dataSource = self;
    
    self.changeCategoryPopover = [[UIPopoverController alloc] initWithContentViewController:self.changeCategoryTableViewController];
    self.changeCategoryPopover.popoverBackgroundViewClass = [IAEPopoverBackgroundCustom class];
    self.changeCategoryPopover.popoverContentSize = CGSizeMake(415.0, 250.0);
    self.changeCategoryPopover.delegate = self;
    
    NSIndexPath *cellIndexPath = [self.extendedConceptsTableView indexPathForSelectedRow];
    UITableViewCell *cell = [self.extendedConceptsTableView cellForRowAtIndexPath:cellIndexPath];
    [self.changeCategoryPopover presentPopoverFromRect:CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width / 2.5, cell.frame.size.height)
                                                inView:self.extendedConceptsTableView
                              permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    
    NSIndexPath *categorySelected = [self indexPathOfCategoryInChangeCategoryTableViewForSelectedConcept];
    [self.changeCategoryTableViewController.tableView scrollToRowAtIndexPath:categorySelected atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}

- (void)changeAmountMenuSelected:(id)sender
{
    NSIndexPath *amountConceptLabelIndexPath = [self.extendedConceptsTableView indexPathForSelectedRow];
    UITableViewCell *cell = [self.extendedConceptsTableView cellForRowAtIndexPath:amountConceptLabelIndexPath];
    
    IAEAmountStepperViewController *amountStepperViewController = [[IAEAmountStepperViewController alloc] initWithNibName:@"IAEAmountStepperViewController" bundle:nil];
    amountStepperViewController.delegate = self;
   
    self.changeAmountPopover = [[UIPopoverController alloc] initWithContentViewController:amountStepperViewController];
    self.changeAmountPopover.delegate = self;
    self.changeAmountPopover.popoverBackgroundViewClass = [IAEPopoverBackgroundCustom class];
    self.changeAmountPopover.popoverContentSize = CGSizeMake(amountStepperViewController.view.bounds.size.width, amountStepperViewController.view.bounds.size.height);
    
    UILabel *amountLabel = (UILabel *)[cell viewWithTag:LTEXT_AMOUNTLABEL_EXTENDEDCONCEPTTABLEVIEW];
    CGRect amountLabelRect = [amountLabel convertRect:amountLabel.frame toView:self.extendedConceptsTableView];
    CGSize sizeOfLabel = [amountLabel.text sizeWithFont:amountLabel.font];
    CGRect popoverPosition = CGRectMake(amountLabelRect.origin.x - sizeOfLabel.width - 40.0,
                                        amountLabelRect.origin.y - sizeOfLabel.height / 4, // No se porque no funciona directamente diviendo la altura entre dos
                                        amountLabelRect.size.width,
                                        amountLabelRect.size.height);
    [self.changeAmountPopover presentPopoverFromRect:popoverPosition inView:self.extendedConceptsTableView permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
}

- (void)changeAmountByStepper:(UIStepper *)stepper
{
    NSIndexPath *conceptCellToChangeAmountIndex = [self.extendedConceptsTableView indexPathForSelectedRow];
    UITableViewCell *cellToChangeAmount = [self.extendedConceptsTableView cellForRowAtIndexPath:conceptCellToChangeAmountIndex];
    IAEConcept *concept = [[[self actualSelectedMonth] allConceptsSortedByDate] objectAtIndex:conceptCellToChangeAmountIndex.row];
    NSDecimalNumber *actualValue = [concept amount];
    NSDecimalNumber *stepperValue = [NSDecimalNumber decimalNumberWithString:[NSNumber numberWithDouble:stepper.value].stringValue];
    NSComparisonResult compareValues = [actualValue compare:stepperValue];

    UILabel *labelAmount = (UILabel *)[cellToChangeAmount viewWithTag:LTEXT_AMOUNTLABEL_EXTENDEDCONCEPTTABLEVIEW];
    [[IAEAnimationManager sharedManager] destroyViewGosthEffect:labelAmount withDuration:0.3 andDisplacement:compareValues == NSOrderedAscending ? 44.0 : -44.0];
    labelAmount.text = [[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:stepperValue];
    
    concept.amount = stepperValue;
    [[IAEBook sharedBook] saveAll];    
}

- (void)deleteConceptMenuSelected:(id)sender
{
    NSIndexPath *cellIndexPath = [self.extendedConceptsTableView indexPathForSelectedRow];
    
    IAEMonth *actualMonth = [self findActualMonth];
    
    NSArray *concepts = [actualMonth allConceptsSortedByDate];
    
    IAEConcept *conceptToRemove = [concepts objectAtIndex:cellIndexPath.row];
    
    [actualMonth removeConcept:conceptToRemove];
    
    // Si no estamos en modo edit recargamos. En modo edit recarga auto al pasar a modo no edit
    if (![self isEditModeOn]) {
        [self updateMonthBalanceCardInfo];
        [self reloadYearAndGlobalBalanceInfoAnimated:YES];
        [self configureTableViewBasedInActualMonthConceptsWithInput:YES];
    }
    
    [self updateConceptsTableViewHeaderVisibilityWithAnimation:!self.isEditModeOn];
    
    // OJO: Este evento se llama DESPUES de borrar el concepto por lo que si no hay ningun elemento es que se ha borrado y hay que hacer reload completo
    UITableViewCell *cell = [self.extendedConceptsTableView cellForRowAtIndexPath:cellIndexPath];

    [[IAEAnimationManager sharedManager] destroyViewGosthEffect:cell withDuration:0.3 andDisplacement:44.0];

    if (actualMonth.concepts.count == 0) {
        [self.extendedConceptsTableView reloadData];
        [self.compactConceptsTableView reloadData];
        self.extendedConceptsTableView.allowsSelection = self.compactConceptsTableView.allowsSelection = NO;
    }
    else {
        //[self.extendedConceptsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:cellIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.extendedConceptsTableView reloadData];
        [self.compactConceptsTableView reloadData];
    }
    
    [[IAEBook sharedBook] saveAll];
}

#pragma mark - UIPopoverDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    if (self.changeAmountPopover == popoverController) {
        if (!self.isEditModeOn) {
            [self updateMonthBalanceCardInfo];
            [self reloadYearAndGlobalBalanceInfoAnimated:YES];
            [self.compactConceptsTableView reloadData];
        }
        self.changeAmountPopover = nil;
    } else if (self.changeCategoryPopover == popoverController) {
        self.changeCategoryTableViewController = nil;
        self.changeCategoryPopover =  nil;
    }
}

@end
