//
//  IAEIncomeExpenseControllerViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 04/12/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEIncomeExpenseControllerViewController.h"
#import "IAEConceptsViewController.h"
#import "IAEInputConceptsViewController.h"
#import "IAEConfigViewController.h"
#import "IAEConfigNavigationControllerViewController.h"
#import "IAEYearsConfigViewController.h"
#import "IAECategoriesConfigViewControllerv2.h"
#import "IAENewYearDatePickerViewController.h"
#import "IAEBook.h"
#import "IAESettingsViewController.h"
#import "IAEPopoverBackgroundCustom.h"
#import "IAEAnimationManager.h"
#import "IAEYear.h"

@interface IAEIncomeExpenseControllerViewController ()
@property(nonatomic, strong) IAEConceptsViewController *conceptsViewController;
@property(nonatomic, strong) IAEInputConceptsViewController *inputConceptsViewController;
@property (weak, nonatomic) IBOutlet UILabel *noYearsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *noYearCoachArrow;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *yearBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *categoriesBarButton;
@property (nonatomic, strong) UIPopoverController *yearPickerPopover;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) UIPopoverController *settingsPopover;
@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UIButton *settingsBarButton;
@property (strong, nonatomic) UIImageView *splashScreen;
@end

@implementation IAEIncomeExpenseControllerViewController

@synthesize conceptsViewController = conceptsViewController_;
@synthesize inputConceptsViewController = inputConceptsViewController_;
@synthesize noYearsLabel = noYearsLabel_;
@synthesize noYearCoachArrow = noYearCoachArrow_;
@synthesize yearBarButton = yeareBarButton_;
@synthesize categoriesBarButton = categoriesBarButton_;
@synthesize yearPickerPopover = yearPickerPopover_;
@synthesize navigationBar = navigationBar_;
@synthesize settingsPopover = settingsPopover_;
@synthesize baseView = baseView_;
@synthesize settingsBarButton = settingsBarButton_;
@synthesize splashScreen = splashScreen_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        self.conceptsViewController = [[IAEConceptsViewController alloc] init];
        self.inputConceptsViewController = [[IAEInputConceptsViewController alloc] init];
        
        self.splashScreen = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default-Landscape~ipad"]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(yearAddedNotification:) name:@"NewYearCreated" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(yearRemovedNotification:) name:@"YearRemoved" object:nil];
    }
    
    return self;
}

- (void)calculeFramePositionForInputController
{
    // Ajuste input para animacion
    CGRect baseViewFrame = self.baseView.frame;
    CGRect InputFrame = self.conceptsViewController.view.frame;
    CGRect InputSize = self.inputConceptsViewController.view.bounds;
    InputFrame.origin.x = (InputFrame.size.width - InputSize.size.width) / 2;
    InputFrame.origin.y = baseViewFrame.size.height /*- [self.inputConceptsViewController sizeOfDragToolbarView] Para ocultar de cara a la animacion*/;
    InputFrame.size = InputSize.size;
    
    self.inputConceptsViewController.view.frame = InputFrame;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    
    // Añade controllers
    // Concepts
    //[self.scrollViewControllersContainer addSubview:self.conceptsViewController.view];
    [self.baseView addSubview:self.conceptsViewController.view];
    
    // Ajuste navigation para animacion
    CGRect navigationBarFrame = self.navigationBar.frame;
    self.navigationBar.frame = CGRectMake(navigationBarFrame.origin.x, navigationBarFrame.origin.y - navigationBarFrame.size.height, navigationBarFrame.size.width, navigationBarFrame.size.height);
    
    // Ajuste input para animacion
    // Vincula delegado & data source de InputConcepts a Concepts
    [self calculeFramePositionForInputController];
    [self.baseView addSubview:self.inputConceptsViewController.view];
    self.inputConceptsViewController.delegate = self;
    self.inputConceptsViewController.dataSource = self.conceptsViewController;
    
    // Por ahora desactivamos el segmentedcontrol
    self.navigationItem.title = NSLocalizedString(@"Easy Incomes and Expenses", @"Titulo aplicacion");
    self.navigationItem.titleView = nil;
    
    self.yearBarButton.enabled = NO;
    self.categoriesBarButton.enabled = NO;
    self.settingsBarButton.enabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIDeviceOrientationIsLandscape(toInterfaceOrientation);
}

- (void)updateContentDataBasedInYearBookExistence
{
    BOOL noYears = [IAEBook sharedBook].years.count == 0;
    self.noYearsLabel.hidden = !noYears;
    self.noYearCoachArrow.hidden = !noYears;
    self.baseView.hidden = noYears;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //  splashScreen.transform = CGAffineTransformMakeRotation();
    [self.view addSubview:self.splashScreen];
    [self.view bringSubviewToFront:self.splashScreen];
    
    [self updateContentDataBasedInYearBookExistence];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    [UIView animateWithDuration:2.0 animations:^{self.splashScreen.alpha = 0.0;}
                     completion:(void (^)(BOOL)) ^{
                         [self.splashScreen removeFromSuperview];
                         self.splashScreen = nil;
                     }];
    
    [UIView animateWithDuration:1.0 animations:^{
        self.navigationBar.frame = CGRectMake(0.0, 0.0, self.navigationBar.bounds.size.width, self.navigationBar.bounds.size.height);
        self.inputConceptsViewController.view.frame = CGRectMake(self.inputConceptsViewController.view.frame.origin.x, self.inputConceptsViewController.view.frame.origin.y - [self.inputConceptsViewController sizeOfDragToolbarView].height + 1, self.inputConceptsViewController.view.frame.size.width, self.inputConceptsViewController.view.frame.size.height);
    } completion:^(BOOL finished) {
        [self.inputConceptsViewController updateStarAndEndFrame];
        
        self.yearBarButton.enabled = YES;
        self.categoriesBarButton.enabled = YES;
        self.settingsBarButton.enabled = YES;
    }];
}

- (void)viewDidUnload {
    [self setNoYearsLabel:nil];
    [self setYearBarButton:nil];
    [self setCategoriesBarButton:nil];
    [self setNavigationBar:nil];
    [self setNoYearCoachArrow:nil];
    [self setBaseView:nil];
    [self setSettingsBarButton:nil];
    [super viewDidUnload];
}

- (BOOL)inputModeActive
{
    return [self.conceptsViewController isEditModeActive];
}

- (IAEYear *)actualDateStateYear
{
    return [self.conceptsViewController selectedYear];
}

- (IAEMonth *)actualDateStateMonth
{
    return [self.conceptsViewController actualSelectedMonth];
}

- (void)changeToYear:(NSNumber *)toYear executingBlock:(void (^)(void))block
{
    CGRect conceptsControllerFrame = self.conceptsViewController.view.frame;
    
    IAEConceptsViewController *conceptsController = [[IAEConceptsViewController alloc] init];
    [self.baseView insertSubview:conceptsController.view belowSubview:self.inputConceptsViewController.view];
    
    if (self.conceptsViewController) {
       NSNumber *actualYear = [NSNumber numberWithInteger:self.conceptsViewController.selectedYear.yearDate];
        
        NSComparisonResult yearCompare = [actualYear compare:toYear];
        if (yearCompare == NSOrderedAscending) {
            conceptsControllerFrame.origin.x -= conceptsControllerFrame.size.width;
        } else if (yearCompare == NSOrderedDescending) {
            conceptsControllerFrame.origin.x += conceptsControllerFrame.size.width;
        } else {
            NSAssert(NO, @"Este caso nunca deberia de suceder");
        }
        
        conceptsController.view.frame = conceptsControllerFrame;
        
        self.baseView.userInteractionEnabled = NO;
        self.yearBarButton.enabled = NO;
        self.categoriesBarButton.enabled = NO;
        self.settingsBarButton.enabled = NO;
        
        [UIView animateWithDuration:1.75 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction animations:^{
            conceptsController.view.center = self.conceptsViewController.view.center;
            self.conceptsViewController.view.center = conceptsControllerFrame.origin.x > self.conceptsViewController.view.frame.origin.x ? CGPointMake(self.conceptsViewController.view.center.x - self.conceptsViewController.view.bounds.size.width, self.conceptsViewController.view.center.y) : CGPointMake(self.conceptsViewController.view.center.x + self.conceptsViewController.view.bounds.size.width, self.conceptsViewController.view.center.y-1);
        } completion:^(BOOL finished) {
            [self.conceptsViewController.view removeFromSuperview];
            self.conceptsViewController = conceptsController;
            self.inputConceptsViewController.dataSource = self.conceptsViewController;
            if (block != nil) {
                block();
            }
            self.baseView.userInteractionEnabled = YES;
            self.yearBarButton.enabled = YES;
            self.categoriesBarButton.enabled = YES;
            self.settingsBarButton.enabled = YES;
        }];
    } else {
        self.conceptsViewController = conceptsController;
        [self.baseView addSubview:conceptsController.view];
        self.inputConceptsViewController.dataSource = self.conceptsViewController;
        if (block != nil) {
            block();
        }
    }
}

- (void)unloadConceptControllersGoingToBackground
{
    [self dismissModalViewControllerAnimated:NO];
    [self.inputConceptsViewController dismissModalViewControllerAnimated:NO];
    
    NSAssert(self.baseView != nil, @"no nil la baseview");
    [self.inputConceptsViewController.view removeFromSuperview];
    [self.conceptsViewController.view removeFromSuperview];
    
    self.inputConceptsViewController = nil;
    self.conceptsViewController = nil;
    
}

// Este metodo se llama solo si habia algun año que restaurar y en este caso el año ya estara cargado
- (void)loadConceptControllersToRestoreFromBackgroundWithActualLoadedYearAndMonth:(NSInteger)monthIndex
{
    self.conceptsViewController = [[IAEConceptsViewController alloc] initStartingInMonthIndex:monthIndex];
    [self.baseView addSubview:self.conceptsViewController.view];
    
    self.inputConceptsViewController = [[IAEInputConceptsViewController alloc] init];
    [self calculeFramePositionForInputController];
    self.inputConceptsViewController.view.frame = CGRectMake(self.inputConceptsViewController.view.frame.origin.x,
                                                             self.inputConceptsViewController.view.frame.origin.y - [self.inputConceptsViewController sizeOfDragToolbarView].height,
                                                             self.inputConceptsViewController.view.frame.size.width,
                                                             self.inputConceptsViewController.view.frame.size.height);
    [self.baseView addSubview:self.inputConceptsViewController.view];
    self.inputConceptsViewController.delegate = self;
    self.inputConceptsViewController.dataSource = self.conceptsViewController;
    
    [self updateContentDataBasedInYearBookExistence];
    
    self.yearBarButton.enabled = YES;
}

#pragma mark - ToolBar Events

- (IBAction)settingsButtonPressed:(UIButton *)sender {
    IAESettingsViewController *settingsCntrl = [[IAESettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:settingsCntrl];

    self.settingsPopover = [[UIPopoverController alloc] initWithContentViewController:navController];
    self.settingsPopover.popoverBackgroundViewClass = [IAEPopoverBackgroundCustom class];
    self.settingsPopover.popoverContentSize = CGSizeMake(300.0, 192.0);
    self.settingsPopover.delegate = self;
    [self.settingsPopover presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
    settingsCntrl.popoverFatherController = self.settingsPopover;
}

- (IBAction)yearsButtonPressed:(id)sender
{
    // En caso de que no exista ningun año creado directamente mostraremos popover.
    // Si existe algun año creado lanzamos el controller "oficial" para la gestion de años
    if ([IAEBook sharedBook].years.count > 0)
    {
        [[IAEBook sharedBook] loadAll];
        
        IAEYearsConfigViewController *yearsViewController = [[IAEYearsConfigViewController alloc] initWithActualYear:self.conceptsViewController.selectedYear];
        yearsViewController.delegate = self;
    
        IAEConfigNavigationControllerViewController *navController = [[IAEConfigNavigationControllerViewController alloc] initWithRootViewController:yearsViewController];
    
        navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
    
        [self presentViewController:navController animated:YES completion:nil];
    }
    else
    {
        if (nil == self.yearPickerPopover)
        {
            IAENewYearDatePickerViewController *newYearPicker = [[IAENewYearDatePickerViewController alloc] init];
            newYearPicker.delegate = self;
        
            self.yearPickerPopover = [[UIPopoverController alloc] initWithContentViewController:newYearPicker];
            self.yearPickerPopover.delegate = self;
            self.yearPickerPopover.popoverBackgroundViewClass = [IAEPopoverBackgroundCustom class];
            [self.yearPickerPopover setPopoverContentSize:newYearPicker.view.bounds.size animated:NO];
            [self.yearPickerPopover presentPopoverFromBarButtonItem:self.yearBarButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else
        {
            [self.yearPickerPopover dismissPopoverAnimated:YES];
            self.yearPickerPopover = nil;
        }
    }
}

- (IBAction)categoriesButtonPressed:(id)sender
{
    IAECategoriesConfigViewControllerv2 *categoriesViewController = [[IAECategoriesConfigViewControllerv2 alloc] initWithNibName:@"IAECategoriesConfigViewControllerv2" bundle:nil];
    
    IAEConfigNavigationControllerViewController *navController = [[IAEConfigNavigationControllerViewController alloc] initWithRootViewController:categoriesViewController];
    
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:navController animated:YES completion:nil];

}

#pragma mark - IAEYearsConfigViewController

- (void)newYearDatePickerSelectionCancelled
{
    [self.yearPickerPopover dismissPopoverAnimated:YES];
    self.yearPickerPopover = nil;
}

#pragma mark - IAENewYearDatePickerViewControllerDelegate

- (void)newYearDatePickerSelectionDoneWithYear:(NSUInteger)year
{
    [self.yearPickerPopover dismissPopoverAnimated:YES];
    self.yearPickerPopover = nil;
    
    [[IAEBook sharedBook] createYear:[NSNumber numberWithUnsignedInteger:year]];
    [[IAEBook sharedBook] loadYear:year];
}

#pragma mark - Notification center

- (void)yearRemovedNotification:(NSNotification *)notification
{
    if (self.conceptsViewController.selectedYear.isDeleted) {
        NSMutableArray *years = [IAEBook sharedBook].years;
        IAEYear *newYear = years.count > 0 ? [years objectAtIndex:0] : nil;
        if (newYear) {
            [[IAEBook sharedBook] loadYear:newYear.yearDate];
            [self changeToYear:[NSNumber numberWithUnsignedInteger:newYear.yearDate] executingBlock:nil];
        } else {
            [self.conceptsViewController.view removeFromSuperview];
            self.conceptsViewController = nil;
        }
        [[IAEBook sharedBook] saveAll];

    } else {
        [[IAEBook sharedBook] saveAll];
    }

    [self updateContentDataBasedInYearBookExistence];
}

- (void)yearAddedNotification:(NSNotification *)notification
{
    [[IAEBook sharedBook] saveAll];

    NSNumber *yearDate = [[notification userInfo] objectForKey:@"YearDate"];
    [[IAEBook sharedBook] loadYear:yearDate.unsignedIntegerValue];

    void (^logicCode)(void) = ^void(void) {
        [self updateContentDataBasedInYearBookExistence];
    };
 
    [self changeToYear:yearDate executingBlock:logicCode];
}

#pragma mark - IAEYearConfigViewDelegate

- (void)newActualYearSelected:(IAEYear *)year
{
    [self changeToYear:[NSNumber numberWithUnsignedInt:year.yearDate] executingBlock:nil];
}

#pragma mark - IAEInputConceptsDelegate

// IMPORTANTE: Por el momento pasamos la patata a IAEConceptsViewController pero lo normal es que hicieramos
// que las notificaciones del Input fueran en una notificacion.

- (void)inputChangePosition:(CGFloat) offsetY
{
    [self.conceptsViewController inputChangePosition:offsetY];
}

- (void)inputShowed;
{
    self.yearBarButton.enabled = NO;
    self.categoriesBarButton.enabled = YES;
    
    [self.conceptsViewController inputShowed];
}
- (void)inputHidden
{
    self.yearBarButton.enabled = YES;
    //self.categoriesBarButton.enabled = NO;
    self.categoriesBarButton.enabled = YES;
    
    [self.conceptsViewController inputHidden];
}

- (void)inputAnimationShowedWithOffset:(CGFloat)offsetY andDuration:(CGFloat)duration andSpeed:(CGFloat)speed
{
    self.yearBarButton.enabled = NO;
    self.categoriesBarButton.enabled = YES;
    
    [self.conceptsViewController inputAnimationShowedWithOffset:offsetY andDuration:duration andSpeed:speed];
}

- (void)inputAnimationHiddenWithOffset:(CGFloat)offsetY andDuration:(CGFloat)duration andSpeed:(CGFloat)speed
{
    self.yearBarButton.enabled = YES;
    //self.categoriesBarButton.enabled = NO;
    self.categoriesBarButton.enabled = YES;
    
    [self.conceptsViewController inputAnimationHiddenWithOffset:offsetY andDuration:duration andSpeed:speed];
}

- (void)inputChangeCategoryModeToIncome
{
    [self.conceptsViewController inputChangeCategoryModeToIncome];
}

- (void)inputChangeCategoryModeToExpense
{
    [self.conceptsViewController inputChangeCategoryModeToExpense];
}

#pragma mark - UIPopoverdelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if (popoverController == self.settingsPopover) {
        self.settingsPopover = nil;
    } else if (popoverController == self.yearPickerPopover) {
        self.yearPickerPopover = nil;
    }
}

@end
