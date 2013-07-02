//
//  IAEYearsConfigViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 21/12/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEYearsConfigViewController.h"
#import "IAEYearConfigCardViewController.h"
#import "IAENewYearDatePickerViewController.h"
#import "IAEBook.h"
#import "IAEYear.h"
#import "IAEPopoverBackgroundCustom.h"

@interface IAEYearsConfigViewController ()

@property (nonatomic, strong) NSMutableArray *yearsCardControllers;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *leftScrollIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *rightScrollIndicator;
@property (nonatomic, strong) UIPopoverController *popover;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *reportButton;
@property (weak, nonatomic) IBOutlet IAEYear *initialYear;
@property (weak, nonatomic) IBOutlet UILabel *emptyLabelAdvice;
@end

@implementation IAEYearsConfigViewController

@synthesize yearsCardControllers = yearsCardControllers_;
@synthesize scrollView = scrollView_;
@synthesize leftScrollIndicator = leftScrollIndicator_;
@synthesize rightScrollIndicator = rightScrollIndicator_;
@synthesize popover = popover_;
@synthesize addButton = addButton_;
@synthesize initialYear = initialYear_;
@synthesize emptyLabelAdvice = emptyLabelAdvice_;
@synthesize deleteButton = deleteButton_;
@synthesize reportButton = reportButton_;

- (id)initWithActualYear:(IAEYear *)year
{
    self = [super initWithNibName:nil bundle:[NSBundle mainBundle]];
    {
        initialYear_ = year;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newYearCreatedNotification:) name:@"NewYearCreated" object:nil];
        [self createYearCards];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"Cerrar") style:UIBarButtonItemStyleBordered target:self action:@selector(closeButtonPressed:)];
    self.navigationItem.title = NSLocalizedString(@"Years", @"Titulo de años");
    

    // TODO: Ir al año actualmente seleccionado
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSArray *years = [IAEBook sharedBook].years;
        
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * years.count, self.scrollView.bounds.size.height);

    [self addYearsCardsInScrollViewFrom:0 Distance:years.count];

    IAEYearConfigCardViewController *configCardSelected = [self findYearConfigViewCardForYear:self.initialYear];
    
    [self.scrollView scrollRectToVisible:configCardSelected.view.frame animated:NO];
    
    [self updateControllsBasedInYears];
}

- (NSUInteger)findActualYearCardIndex
{
    NSUInteger cardWith = self.yearsCardControllers.count == 0 ? 0 : self.scrollView.contentSize.width / self.yearsCardControllers.count;
    
    NSUInteger actualYearCardIndex = floor(self.scrollView.contentOffset.x < 0.0 ? 0.0 : self.scrollView.contentOffset.x / cardWith);
            
    return actualYearCardIndex;
}

- (void)updateControllsBasedInYears
{
    NSArray *years = [IAEBook sharedBook].years;
    
    BOOL noYears = years.count == 0;
    
    //NSUInteger actualYearCardIndex = [self findActualYearCardIndex];
    
    [UIView animateWithDuration:0.35 animations:^{
        CGFloat leftIndicatorAlphaValue = years.count == 1 ? 0.0 : 1.0;//actualYearCardIndex == 0 ? 0.0 : 1.0;
        CGFloat rightIndicatorAlphaValue = years.count == 1 ? 0.0 : 1.0;//actualYearCardIndex == years.count - 1 ? 0.0 : 1.0;
        
        if (leftIndicatorAlphaValue != self.leftScrollIndicator.alpha)
            self.leftScrollIndicator.alpha = leftIndicatorAlphaValue;
        
        if (rightIndicatorAlphaValue != self.rightScrollIndicator.alpha)
            self.rightScrollIndicator.alpha = rightIndicatorAlphaValue;
    }];
    
    self.emptyLabelAdvice.hidden = !noYears;
    self.deleteButton.hidden = self.reportButton.hidden = noYears;
}

- (IAEYearConfigCardViewController *)findYearConfigViewCardForYear:(IAEYear *)year
{
    IAEYearConfigCardViewController *retConfigCardYear;
    
    for (IAEYearConfigCardViewController *configCardYearIt in self.yearsCardControllers)
    {
        if (configCardYearIt.year == year)
        {
            retConfigCardYear = configCardYearIt;
            
            break;
        }
    }
    
    return retConfigCardYear;
}

- (IAEYearConfigCardViewController *)createYearCardControllerForYear:(IAEYear *)year
{
    IAEYearConfigCardViewController *yearCard;
    if (year == self.initialYear) {
        yearCard = [[IAEYearConfigCardViewController alloc] initWithActualYearCard:year];
    } else {
        yearCard = [[IAEYearConfigCardViewController alloc] initWithYear:year];
    }
    return yearCard;
}

- (void)createYearCards
{
    NSArray *years = [[IAEBook sharedBook].years sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"yearDate" ascending:NO], nil]];
    
    self.yearsCardControllers = [NSMutableArray arrayWithCapacity:years.count];
    
    for (IAEYear *year in years) {
        IAEYearConfigCardViewController *yearCard = [self createYearCardControllerForYear:year];
        [self.yearsCardControllers addObject:yearCard];
    }
}

- (void)addYearsCardsInScrollViewFrom:(NSUInteger)yearIndex Distance:(NSUInteger)distance
{
    CGRect frame = self.scrollView.frame;
 
    frame.origin.x = frame.size.width * yearIndex;
    frame.origin.y = 0;
    
    for (NSUInteger indexIt = yearIndex; indexIt < yearIndex + distance; ++indexIt)
    {
        IAEYearConfigCardViewController *yearCard = [self.yearsCardControllers objectAtIndex:indexIt];
        
        yearCard.view.frame = frame;
        
        if (yearCard.view.superview != self.scrollView)
            [self.scrollView addSubview:yearCard.view];
    
        [yearCard.goToYearButton addTarget:self action:@selector(goButtonPressed:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        
        frame.origin.x += frame.size.width;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IAEYearConfigCardViewController *)findActualYearController
{
    NSUInteger widthOfViewCard = self.scrollView.bounds.size.width;
    CGPoint currentOffset = self.scrollView.contentOffset;
    
    NSUInteger indexOfViewCard = currentOffset.x / widthOfViewCard;
    
    IAEYearConfigCardViewController *retConfigCard = [self.yearsCardControllers objectAtIndex:indexOfViewCard];
    
    return retConfigCard;
}

- (void)removeYearFromYearCard:(IAEYearConfigCardViewController *)yearCard
{
    NSUInteger yearDateToRemove = yearCard.goToYearButton.tag;
    
    [[IAEBook sharedBook] deleteYear:[NSNumber numberWithUnsignedInteger:yearDateToRemove]];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)removeYearFromActualYearCard
{
    IAEYearConfigCardViewController *configCard = [self findActualYearController];
    
    [self removeYearFromYearCard:configCard];
}

#pragma mark - Control Notification

- (IBAction)removeButtonPressed:(id)sender
{
    // Si el año tiene mas de un concepto alertview para confirmar la accion
    
    IAEYearConfigCardViewController *yearCardToRemove = [self findActualYearController];
    
    NSNumber *yearDate = [NSNumber numberWithUnsignedInteger:yearCardToRemove.goToYearButton.tag];
    
    IAEYear* year = [[IAEBook sharedBook] existYearDate:yearDate];
    
    if ([year findAllConcepts].count > 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Confirm action", @"Titulo alert view para borrar un año")
                                                            message:NSLocalizedString(@"This year have one o more items.\n If you remove it all items year will be removed forever.\n Do you want to proceed?", @"Descripcion asociada a borrar un año")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"No", @"Opcion de no")
                                                  otherButtonTitles:NSLocalizedString(@"Yes", @"Opcion de si"), nil];
        
        alertView.delegate = self;
        
        [alertView show];
    }
    else
        [self removeYearFromYearCard:yearCardToRemove];
}

- (IBAction)newYearButtonPressed:(id)sender
{
    IAENewYearDatePickerViewController *newYearPicker = [[IAENewYearDatePickerViewController alloc] init];
    newYearPicker.delegate = self;
    
    self.popover = [[UIPopoverController alloc] initWithContentViewController:newYearPicker];
    self.popover.delegate = self;
    self.popover.popoverBackgroundViewClass = [IAEPopoverBackgroundCustom class];
    [self.popover setPopoverContentSize:newYearPicker.view.bounds.size animated:NO];
    [self.popover presentPopoverFromRect:self.addButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}


- (void)dismissAndGoToYear:(NSUInteger)yearDate
{
    [[IAEBook sharedBook] loadYear:yearDate];

    [self.delegate newActualYearSelected:[[IAEBook sharedBook].years objectAtIndex:0]];
    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - NavigationItem Events

- (void)closeButtonPressed:(id)sender
{
    [[IAEBook sharedBook] loadYear:self.initialYear.yearDate];
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setLeftScrollIndicator:nil];
    [self setRightScrollIndicator:nil];
    [self setAddButton:nil];
    [self setEmptyLabelAdvice:nil];
    [self setDeleteButton:nil];
    [self setReportButton:nil];
    [super viewDidUnload];
}

#pragma mark - DatePickerDelegate

- (void)newYearDatePickerSelectionCancelled
{
    [self.popover dismissPopoverAnimated:YES];
    self.popover = nil;
}

- (void)newYearDatePickerSelectionDoneWithYear:(NSUInteger)year
{
    [[IAEBook sharedBook] createYear:[NSNumber numberWithUnsignedInteger:year]];
    
    [self.popover dismissPopoverAnimated:YES];
    self.popover = nil;
}

#pragma mark - YearConfigCardEvents

- (void)goButtonPressed:(UIButton *)sender
{
    NSUInteger yearDate = sender.tag;
        
    [self dismissAndGoToYear:yearDate];
}

#pragma mark - NotificationCenter

- (void)newYearCreatedNotification:(NSNotification *)notification
{
    // Nota: Se puede llegar a crear un año sin estar visible este view
    if (!self.view.hidden)
    {
        [self dismissModalViewControllerAnimated:YES];

        //NSDictionary *userInfo = [notification userInfo];
    
        //NSNumber *yearDate = [userInfo objectForKey:@"YearDate"];
    
        //[self dismissAndGoToYear:yearDate.unsignedIntValue];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateControllsBasedInYears];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    // Se confirma el borrado
    if (buttonIndex == 1)
        [self removeYearFromActualYearCard];
}

#pragma mark - UIPopoverdelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if (popoverController == self.popover) {
        self.popover = nil;
    }
}

@end
