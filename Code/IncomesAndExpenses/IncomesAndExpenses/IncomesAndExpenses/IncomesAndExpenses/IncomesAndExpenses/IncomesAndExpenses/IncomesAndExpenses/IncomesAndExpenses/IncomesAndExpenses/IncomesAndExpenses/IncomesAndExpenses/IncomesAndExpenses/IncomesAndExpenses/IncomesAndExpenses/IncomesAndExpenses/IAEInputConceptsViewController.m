//
//  IAEInputConceptsViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 06/12/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEInputConceptsViewController.h"
#import "IAECategory.h"
#import "IAEMonth.h"
#import "IAECategoryStore.h"
#import "IAEBook.h"
#import "IAEConcept.h"
#import "IAECurrencyManager.h"
#import "IAEConfigNavigationControllerViewController.h"
#import "IAEAnimationManager.h"
#import "IAEConstants.h"
#import "IAEViewUtils.h"
#import "IAECategoriesConfigAddViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface IAEInputConceptsViewController ()
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapDragGestureRecognizer;
@property (nonatomic) CGRect initialFrame;
@property (nonatomic, strong) NSMutableString *actualAmount;
@property (weak, nonatomic) IBOutlet UIView *dragToolbarView;
@property (weak, nonatomic) IBOutlet UIView *amountPannelView;
@property (weak, nonatomic) IBOutlet UIView *calculatorButtonPannelView;
@property (weak, nonatomic) IBOutlet UIView *categoryButtonPannelView;
@property (weak, nonatomic) IBOutlet UILabel *numericPannel;
@property (weak, nonatomic) IBOutlet UIScrollView *categoryLabelsScrollView;
@property (nonatomic, strong) NSMutableArray *incomeCategoryLabels;
@property (nonatomic, strong) NSMutableArray *expenseCategoryLabels;
@property (nonatomic, strong) UIAlertView *categoryAlertViewNameInput;
@property (weak, nonatomic) IBOutlet UIButton *decimalButton;
@property (weak, nonatomic) IBOutlet UIButton *clearAmountButton;
@property (nonatomic) CGRect startFrame;
@property (nonatomic) CGRect endFrame;
@property (nonatomic, weak) UILabel *actualIncomeCategory;
@property (nonatomic, weak) UILabel *actualExpenseCategory;
@property (weak, nonatomic) IBOutlet UIImageView *leftNavigationIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *rightNavigationIndicator;
@property (weak, nonatomic) IBOutlet UILabel *titleLableDragPanel;
@property (strong, nonatomic) UILabel *numericPanelToBeDestroyed;
@property (nonatomic) CategoryType editModeCategory;
@property (weak, nonatomic) IBOutlet UIButton *addConceptCheckButton;
@property (nonatomic) BOOL addNewCategoryFromInputController;
@end

@implementation IAEInputConceptsViewController

@synthesize panGestureRecognizer = panGestureRecognizer_;
@synthesize tapDragGestureRecognizer = tapDragGestureRecognizer_;
@synthesize initialFrame = initialFrame_;
@synthesize dragToolbarView = dragToolbarView_;
@synthesize amountPannelView = amountPannelView_;
@synthesize calculatorButtonPannelView = calculatorButtonPannelView_;
@synthesize delegate = delegate_;
@synthesize numericPannel = numericPannel_;
@synthesize categoryLabelsScrollView = categoryButtonScrollView_;
@synthesize categoryButtonPannelView = categoryButtonPannelView_;
@synthesize actualAmount = actualAmount_;
@synthesize incomeCategoryLabels = incomeCategoryLabels_;
@synthesize expenseCategoryLabels = expenseCategoryLabels_;
@synthesize categoryAlertViewNameInput = newCategoryAlertView_;
@synthesize decimalButton = decimalButton_;
@synthesize clearAmountButton = clearAmountButton_;
@synthesize startFrame = startFrame_;
@synthesize endFrame = endFrame_;
@synthesize actualIncomeCategory = actualIncomeCategory_;
@synthesize actualExpenseCategory = actualExpenseCategory_;
@synthesize leftNavigationIndicator = leftNavigationIndicator_;
@synthesize rightNavigationIndicator = rightNavigationIndicator_;
@synthesize titleLableDragPanel = titleLableDragPanel_;
@synthesize numericPanelToBeDestroyed = numericPanelToBeDestroyed_;
@synthesize editModeCategory = editModeCategory_;
@synthesize addConceptCheckButton = addConceptCheckButton_;
@synthesize addNewCategoryFromInputController = addNewCategoryFromInputController_;

const NSUInteger LABEL_MARGIN = 2.0;

#pragma mark - Getter and Setters

- (NSMutableString *)actualAmount
{
    if (actualAmount_ == nil)
        actualAmount_ = [[NSMutableString alloc] init];
    return actualAmount_;
}

- (NSMutableArray *)incomeCategoryLabels
{
    if (nil == incomeCategoryLabels_)
        incomeCategoryLabels_ = [NSMutableArray arrayWithCapacity:[IAECategoryStore sharedCategoryStore].userDefinedCategories.count];
    return incomeCategoryLabels_;
}


- (NSMutableArray *)expenseCategoryLabels
{
    if (nil == expenseCategoryLabels_)
        expenseCategoryLabels_ = [NSMutableArray arrayWithCapacity:[IAECategoryStore sharedCategoryStore].userDefinedCategories.count];
    return expenseCategoryLabels_;
}

#pragma mark - General Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(categoryCreatedNotification:) name:@"CategoryCreated" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(categoryRemoveNotification:) name:@"CategoryRemoved" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(categoryRenamedNotification:) name:@"CategoryRenamed" object:nil];
        
        self.editModeCategory = IncomeCategory;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    initialFrame_ = self.view.frame;
    
    self.amountPannelView.layer.cornerRadius = 10;
    self.calculatorButtonPannelView.layer.cornerRadius = 10;
    self.categoryButtonPannelView.layer.cornerRadius = 10;

    self.amountPannelView.layer.masksToBounds = self.calculatorButtonPannelView.layer.masksToBounds = self.categoryButtonPannelView.layer.masksToBounds = YES;

    [IAEViewUtils addRoundedCorners:UIRectCornerTopLeft | UIRectCornerTopRight withRadius:10.0 toView:self.dragToolbarView];
    [IAEViewUtils addRoundedCorners:UIRectCornerTopLeft | UIRectCornerTopRight withRadius:16.0 toView:self.view];
    
    CGFloat selfViewRedColor;
    CGFloat selfViewGreenColor;
    CGFloat selfViewBlueColor;
    CGFloat selfViewAlphaColor;
    
    [self.view.backgroundColor getRed:&selfViewRedColor green:&selfViewGreenColor blue:&selfViewBlueColor alpha:&selfViewAlphaColor];
    
    self.categoryButtonPannelView.backgroundColor = [UIColor colorWithRed:selfViewRedColor green:selfViewGreenColor blue:selfViewBlueColor alpha:0.2];
    self.calculatorButtonPannelView.backgroundColor = [UIColor colorWithRed:selfViewRedColor green:selfViewGreenColor blue:selfViewBlueColor alpha:0.2];
    self.amountPannelView.backgroundColor = [UIColor colorWithRed:selfViewRedColor green:selfViewGreenColor blue:selfViewBlueColor alpha:0.2];
    
    //self.dragToolbarView.layer.cornerRadius = 10;
    //self.view.layer.cornerRadius = 10;
        
    [self initPanGestureRecognizer];
    [self initTapDragGestureRecognizer];
    
    [self createCategoryLabels];
    [self showCategoryLabelsBasedInSegmentedControl];
    
    [self createCategoryAlertViewInput];
    
    [self resetAmountPannel];
    
    [self.decimalButton setTitle:[[IAECurrencyManager sharedManager] decimalSeparator] forState:UIControlStateNormal];
    
    [self tintBackgroundInputBasedInCategorySelectorButton:YES];
}

- (void)updateStarAndEndFrame
{
    self.startFrame = self.view.frame;
    self.endFrame = CGRectMake(self.view.frame.origin.x,
                               self.view.frame.origin.y - (self.view.frame.size.height - self.dragToolbarView.frame.size.height),
                               self.view.frame.size.width,
                               self.view.frame.size.height);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateAddCategoryCheckButtonVisibility];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self updateStarAndEndFrame];
}

- (void)createCategoryAlertViewInput
{
    self.categoryAlertViewNameInput = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Create New Category", @"Titulo alerta al crear nueva categoria")
                                                                 message:@""
                                                                delegate:self
                                                       cancelButtonTitle:NSLocalizedString(@"Cancel", "Opcion cancelar")
                                                       otherButtonTitles:NSLocalizedString(@"OK", @"Opcion aceptar"), nil];
    
    self.categoryAlertViewNameInput.delegate = self;
    self.categoryAlertViewNameInput.alertViewStyle = UIAlertViewStylePlainTextInput;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{    
   // [self.view removeFromSuperview];

    self.panGestureRecognizer = nil;
    self.tapDragGestureRecognizer = nil;
    self.incomeCategoryLabels = nil;
    self.expenseCategoryLabels = nil;
    self.categoryAlertViewNameInput = nil;
    self.numericPanelToBeDestroyed = nil;
    
    self.delegate = nil;
    self.dataSource = nil;
}

- (void)viewDidUnload {
    [self setDragToolbarView:nil];
    [self setNumericPannel:nil];
    [self setCategoryLabelsScrollView:nil];
    [self setDecimalButton:nil];
    [self setClearAmountButton:nil];
    [self setLeftNavigationIndicator:nil];
    [self setRightNavigationIndicator:nil];
    [self setTitleLableDragPanel:nil];
    [self setAmountPannelView:nil];
    [self setCalculatorButtonPannelView:nil];
    [self setCategoryButtonPannelView:nil];
    [self setAddConceptCheckButton:nil];
    [super viewDidUnload];
}

- (void)initTapDragGestureRecognizer
{
    tapDragGestureRecognizer_ = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAutomaticDrag:)];
    tapDragGestureRecognizer_.numberOfTapsRequired = 2;
    
    [self.dragToolbarView addGestureRecognizer:tapDragGestureRecognizer_];
}

- (void)initPanGestureRecognizer
{
    panGestureRecognizer_ = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    panGestureRecognizer_.minimumNumberOfTouches = panGestureRecognizer_.maximumNumberOfTouches = 1;
    
    [self.dragToolbarView addGestureRecognizer:panGestureRecognizer_];
}

- (void)resetAmountPannel
{
    self.numericPannel.text = @"";
    self.actualAmount = nil;
    [self appenValueToPannel:@"0"];
    self.clearAmountButton.enabled = NO;
    self.addConceptCheckButton.enabled = [self isCategoryPannelInAddCategoryLabel];
}

- (CGSize)sizeOfDragToolbarView
{
    return self.dragToolbarView.bounds.size;
}

- (void)deployActualAmountToNumericPanel
{
    if (self.actualAmount.length > 0)
    {
        // Controlamos la cantidad de decimales que aparecen segun se van escribiendo:
        // Si no se ha puesto aun el simbolo o se ha puesto sin ningun decimal no mostramos.
        // Si se ha puesto el simbolo con un decimal mostramos exactamente un decimal.
        // En el resto de los casos mostramos como mucho dos decimales (valor por defecto).
        NSUInteger prevMaxFraction = [IAECurrencyManager sharedManager].currencyFormatter.maximumFractionDigits;
        NSUInteger prevMinFraction = [IAECurrencyManager sharedManager].currencyFormatter.minimumFractionDigits;
        
        NSRange decimalRange = [self.actualAmount rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:[[IAECurrencyManager sharedManager] decimalSeparator]]];
        if (decimalRange.location == NSNotFound || decimalRange.location == self.actualAmount.length - 1)
            [IAECurrencyManager sharedManager].currencyFormatter.maximumFractionDigits = 0;
        else if (decimalRange.location == self.actualAmount.length - 2)
            [IAECurrencyManager sharedManager].currencyFormatter.maximumFractionDigits = 1;
        
        NSMutableString *normalizedStrValue = [NSMutableString stringWithString:self.actualAmount];
        [normalizedStrValue replaceOccurrencesOfString:[[IAECurrencyManager sharedManager] decimalSeparator] withString:@"." options:NSBackwardsSearch range:NSMakeRange(0, normalizedStrValue.length)];
        
        //NSNumber *actualNumberAmount = [NSNumber numberWithDouble:[normalizedStrValue doubleValue]];
        NSDecimalNumber *actualNumberAmount = [NSDecimalNumber decimalNumberWithString:normalizedStrValue];
        self.numericPannel.text = [[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:actualNumberAmount];
            
        // En los casos en los que se haya encontrado la coma y el maximo de decimales sea de 0, el simbolo de separacion se escribe manualmente
        if (decimalRange.location != NSNotFound && [IAECurrencyManager sharedManager].currencyFormatter.maximumFractionDigits == 0)
            self.numericPannel.text = [NSMutableString stringWithString:[self.numericPannel.text stringByAppendingString:[[IAECurrencyManager sharedManager] decimalSeparator]]];
        
        [IAECurrencyManager sharedManager].currencyFormatter.maximumFractionDigits = prevMaxFraction;
        [IAECurrencyManager sharedManager].currencyFormatter.minimumFractionDigits = prevMinFraction;
        
       // [self enableClearAmmountButton:YES];
    }
    else
    {
        self.numericPannel.text = @"";
        
        //[self enableClearAmmountButton:NO];
    }
    
    // Establece el button clear si el valor en el amount NO es cero y no existe el decimal
    [self updateClearButtonVisibility];
    [self updateAddCategoryCheckButtonVisibility];
}

- (void)updateClearButtonVisibility
{
    NSDecimalNumber *actualValue = [NSDecimalNumber decimalNumberWithString:self.actualAmount];
    NSRange decimalRange = [self.actualAmount rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:[[IAECurrencyManager sharedManager] decimalSeparator]]];
    
    BOOL zeroValue = [actualValue isEqualToValue:[NSDecimalNumber zero]];
    BOOL decimalPressent = decimalRange.location == NSNotFound ? NO : YES;
    BOOL enableClearButton = !zeroValue || (zeroValue && decimalPressent);
    
    self.clearAmountButton.enabled = enableClearButton;
}

- (void)updateAddCategoryCheckButtonVisibility
{
    NSDecimalNumber *actualValue = [NSDecimalNumber decimalNumberWithString:self.actualAmount locale:[NSLocale currentLocale]];
    
    BOOL zeroValue = [actualValue isEqualToValue:[NSDecimalNumber zero]];
    BOOL enableAddConceptCheckButton = [self isCategoryPannelInAddCategoryLabel] || !zeroValue;
    
    self.addConceptCheckButton.enabled = enableAddConceptCheckButton;
}

- (void)appenValueToPannel:(NSString *)value
{
    // Hasta un maximo de 16 caracteres y 2 decimales
    BOOL canAppendValue = self.actualAmount.length < 15;
    
    if (canAppendValue)
    {
        NSRange decimalRange = [self.actualAmount rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:[[IAECurrencyManager sharedManager] decimalSeparator]]];
        
        canAppendValue = decimalRange.location == NSNotFound;
        
        if (!canAppendValue)
        {
            canAppendValue = self.actualAmount.length - decimalRange.location < 3;
        }
    }
    
    if (canAppendValue) {
        NSString *tmpValue = [NSMutableString stringWithFormat:@"%@%@", self.actualAmount, value];
        NSDecimalNumber *tmpNumberValue = [NSDecimalNumber decimalNumberWithString:tmpValue];
        canAppendValue = [tmpNumberValue compare:[IAEConstants maxDecimalNumberAllowed]] != NSOrderedDescending;
    }
    
    if (canAppendValue)
    {
        self.actualAmount = [NSMutableString stringWithFormat:@"%@%@", self.actualAmount, value];
        
        [self deployActualAmountToNumericPanel];
    }
}

- (void)recalculeLabelFramesOfType:(CategoryType)type
{
    NSArray *container = type == IncomeCategory ? self.incomeCategoryLabels : self.expenseCategoryLabels;
   
    NSUInteger indexOfObject = 0;
    for (UILabel *label in container) {
        label.frame = CGRectMake(LABEL_MARGIN + indexOfObject++ * (label.bounds.size.width + LABEL_MARGIN * 2), 0.0, label.bounds.size.width, label.bounds.size.height);
    }
}

- (void)updateCategoryScrollViewContentSize
{
    CGSize scrollViewContentSize = CGSizeMake(self.categoryLabelsScrollView.bounds.size.width * (self.editModeCategory == IncomeCategory ? self.incomeCategoryLabels.count : self.expenseCategoryLabels.count), self.categoryLabelsScrollView.bounds.size.height);
    
    self.categoryLabelsScrollView.contentSize = scrollViewContentSize;
}

- (void)createCategoryLabels
{
    [self createCategoryLabelsOfType:IncomeCategory];
    [self createCategoryLabelsOfType:ExpenseCategory];
    
    [self createAddNewCategoryLabelOfType:IncomeCategory];
    [self createAddNewCategoryLabelOfType:ExpenseCategory];
    
    [self sortCategoryLabels:IncomeCategory];
    [self sortCategoryLabels:ExpenseCategory];
    
    [self updateCategoryScrollViewContentSize];
}

- (UILabel *)makeNewUICategoryLabelWithFontName:(NSString *)fontName andSize:(CGFloat)size
{
    //UILabel *label = [[UILabel alloc] initWithFrame:self.categoryLabelsScrollView.bounds];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.categoryLabelsScrollView.bounds.size.width - LABEL_MARGIN * 2, self.categoryLabelsScrollView.bounds.size.height)];
    
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:fontName size:size];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumFontSize = 17.0;
    label.numberOfLines = 3;
    label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    
    return label;
}

- (void)createAddNewCategoryLabelOfType:(CategoryType)type
{
    NSMutableArray *destContainer = type == IncomeCategory ? self.incomeCategoryLabels : self.expenseCategoryLabels;
 
    // Importante: El frame se ajustara correctamente al invocar a sortCategoryButtons
    if (destContainer.count > 0) {
        UILabel *label = [self makeNewUICategoryLabelWithFontName:@"HelveticaNeue-Light" andSize:28.0];
        label.text = NSLocalizedString(@"+ Add new category", @"Opcion añadir categoria");
        label.tag = type;
        [destContainer addObject:label];
        //
        [self.categoryLabelsScrollView addSubview:label];
    }
}

- (void)createCategoryLabelsOfType:(CategoryType)type
{
    IAECategoryStore *categoryStore = [IAECategoryStore sharedCategoryStore];
    
    NSMutableArray *container;
    if (type == IncomeCategory)
        container = [NSMutableArray arrayWithObject:[categoryStore generalIncomeCategory]];
    else
        container = [NSMutableArray arrayWithObject:[categoryStore generalExpenseCategory]];
    
    [container addObjectsFromArray:[categoryStore allUserCategoriesOfType:type]];
   
    for (IAECategory *category in container)
        [self createCategoryLabelOfType:type andTag:[category localizedTag]];
}


- (void)createCategoryLabelOfType:(CategoryType)type andTag:(NSString *)tag
{
    NSMutableArray *destContainer = type == IncomeCategory ? self.incomeCategoryLabels : self.expenseCategoryLabels;
    
    CGRect frame;
    if (destContainer.count == 0) {
        frame = CGRectMake(0.0, 0.0, self.categoryLabelsScrollView.bounds.size.width - LABEL_MARGIN * 2, self.categoryLabelsScrollView.bounds.size.height - 0.0);
    } else {
        UILabel *lastLabel = (UILabel *)[destContainer objectAtIndex:destContainer.count-1];
        frame = lastLabel.frame;
        frame.origin.x += self.categoryLabelsScrollView.bounds.size.width;
    }
    
    UILabel *label = [self makeNewUICategoryLabelWithFontName:@"HelveticaNeue-Light" andSize:28.0];
    
    label.bounds = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
    label.frame = frame;
    label.text = tag;
    
    [destContainer addObject:label];
    //
    [self.categoryLabelsScrollView addSubview:label];
}

- (void)setCategoryLabels:(CategoryType)type active:(BOOL)active
{
    NSMutableArray *container = type == IncomeCategory ? self.incomeCategoryLabels : self.expenseCategoryLabels;
    
    for (UILabel *categoryLabel in container) {
        if (active) {
            categoryLabel.hidden = NO;
            //[self.categoryLabelsScrollView addSubview:categoryLabel];

        } else {
            categoryLabel.hidden = YES;
            //[categoryLabel removeFromSuperview];
        }
    }
}

- (void)sortCategoryLabels:(CategoryType)type
{
    NSMutableArray *container = type == IncomeCategory ? self.incomeCategoryLabels : self.expenseCategoryLabels;
    
    NSUInteger scrollIndex = floor(self.categoryLabelsScrollView.contentOffset.x / self.categoryLabelsScrollView.bounds.size.width);

    UILabel *actualVisibleControlLabel;
    if (type == self.editModeCategory)
        actualVisibleControlLabel = [container objectAtIndex:scrollIndex];
    
    // Para reordenar eliminamos el primer y ultimo elemento.
    // NO he encontrado un metodo para ordenar un array entre dos posiciones
    UILabel *generalCategoryLabel = [container objectAtIndex:0];
    UILabel *addNewCategoryLabel = [container objectAtIndex:container.count - 1];
    
    [container removeLastObject];
    [container removeObjectAtIndex:0];
    
    // Ordenamos
    [container sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        UILabel *categoryLabel1 = obj1;
        UILabel *categoryLabel2 = obj2;
        
        NSComparisonResult cmpResult = [categoryLabel1.text caseInsensitiveCompare:categoryLabel2.text];
        
        return cmpResult;
    }];
    
    // Volvemos a añadir
    [container insertObject:generalCategoryLabel atIndex:0];
    [container addObject:addNewCategoryLabel];
    
    // Ajustamos frame
    for (UILabel *label in container) {
        CGRect frame = CGRectMake([container indexOfObject:label] * (label.bounds.size.width + LABEL_MARGIN * 2) + LABEL_MARGIN, 0.0, label.bounds.size.width, label.bounds.size.height);
        label.frame = frame;
    }
    
    // Ajustamos posible boton que se ha quedado fuera de foco
    if (actualVisibleControlLabel && actualVisibleControlLabel != [container objectAtIndex:scrollIndex])
        [self.categoryLabelsScrollView scrollRectToVisible:actualVisibleControlLabel.frame animated:NO];
}

- (BOOL)isCategoryPannelInAddCategoryLabel
{
    NSUInteger actualIndex = floor(self.categoryLabelsScrollView.contentOffset.x / self.categoryLabelsScrollView.bounds.size.width + 0.5);
    NSArray *container = self.editModeCategory == IncomeCategory ? self.incomeCategoryLabels : self.expenseCategoryLabels;
    return actualIndex == container.count - 1;
}

#pragma mark - Gesture Recognizer

- (void)showAnimated:(CGFloat)velocity
{
    CABasicAnimation *mov =  [CABasicAnimation animationWithKeyPath:@"position"];
    
    mov.duration = 0.25;
    CGPoint endPoint = CGPointMake(self.view.layer.position.x, self.endFrame.origin.y + self.endFrame.size.height / 2);
    
    mov.fromValue = [NSValue valueWithCGPoint:self.view.layer.position];
    mov.toValue = [NSValue valueWithCGPoint:endPoint];
    mov.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    mov.speed = velocity;
    [self.view.layer addAnimation:mov forKey:@"position"];
    
    [self.delegate inputAnimationShowedWithOffset:(self.view.layer.position.y - endPoint.y) andDuration:mov.duration andSpeed:velocity];
    
    // Nota: Garantiza que al terminar la animacion no volvamos a empezar
    self.view.layer.position = endPoint;
    
    [self resetAmountPannel];
}

- (void)hideAnimated:(CGFloat)velocity
{
    CABasicAnimation *mov =  [CABasicAnimation animationWithKeyPath:@"position"];
    
    mov.duration = 0.25;
    CGPoint endPoint = CGPointMake(self.view.layer.position.x, self.startFrame.origin.y + self.startFrame.size.height / 2);
    
    mov.fromValue = [NSValue valueWithCGPoint:self.view.layer.position];
    mov.toValue = [NSValue valueWithCGPoint:endPoint];
    mov.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    mov.speed = velocity;
    [self.view.layer addAnimation:mov forKey:@"position"];
    
    [self.delegate inputAnimationHiddenWithOffset:(endPoint.y - self.view.layer.position.y) andDuration:mov.duration andSpeed:velocity];
    
    // Nota: Garantiza que al terminar la animacion no volvamos a empezar
    self.view.layer.position = endPoint;
}

- (BOOL)isInputVisible
{
    return CGRectEqualToRect(self.view.frame, self.endFrame);
}

- (BOOL)isInputHide
{
    return CGRectEqualToRect(self.view.frame, self.startFrame);
}

- (BOOL)inputDoingVisibleHideAnimation
{
    return ![self isInputVisible] && ![self isInputHide];
}

- (void)automaticDrag
{
    if ([self isInputVisible]) {
        [self hideAnimated:1];
        self.titleLableDragPanel.enabled = NO;
    }
    else if ([self isInputHide]) {
        [self showAnimated:1];
        self.titleLableDragPanel.enabled = YES;
    }
}

- (void)tapAutomaticDrag:(UITapGestureRecognizer *)gesture
{
    //[self automaticDrag];
}

- (void)pan:(UIPanGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [gesture translationInView:self.view.superview];
            CGFloat originalYCenterPosition = self.view.center.y;
            
            self.view.center = CGPointMake(self.view.center.x, self.view.center.y + translation.y);
            if (self.view.frame.origin.y < self.endFrame.origin.y) {
                self.view.frame = self.endFrame;
                self.titleLableDragPanel.enabled = YES;
                [self.delegate inputShowed];
            } else if (self.view.frame.origin.y > self.startFrame.origin.y) {
                self.view.frame = self.startFrame;
                [self resetAmountPannel];
                self.titleLableDragPanel.enabled = NO;
                [self.delegate inputHidden];
            }
            
            [self.delegate inputChangePosition:self.view.center.y - originalYCenterPosition];
            [gesture setTranslation:CGPointZero inView:self.view.superview];
        } break;
        
        case UIGestureRecognizerStateEnded: {
            CGFloat limitToGoToEndFrame = (self.startFrame.origin.y - self.endFrame.origin.y) / 2.75;
            CGFloat actualPositionDistanceToEndFrame = self.view.frame.origin.y - self.endFrame.origin.y;
            CGFloat speed = 1.0;
            CGFloat panVelocity = [gesture velocityInView:self.view.superview].y;
            if (panVelocity > 2000) {
                speed = panVelocity < 3000 ? 1.5 : 2.0;
            }
            
            BOOL inputWillBeVisible = actualPositionDistanceToEndFrame < limitToGoToEndFrame;
            if (inputWillBeVisible) {
                [self showAnimated:speed];
                self.titleLableDragPanel.enabled = YES;
            } else {
                [self hideAnimated:speed];
                self.titleLableDragPanel.enabled = NO;
            }
        } break;
        
        default:
            break;
    }
}

- (void)showCategoryLabelsBasedInSegmentedControl
{    
    UILabel *firstLabel;
    //if (self.categorySegmentedControl.selectedSegmentIndex == 0)
    if (self.editModeCategory == IncomeCategory)
    {
        [self setCategoryLabels:IncomeCategory active:YES];
        [self setCategoryLabels:ExpenseCategory active:NO];
        
        self.actualExpenseCategory = [self.expenseCategoryLabels objectAtIndex:floor(self.categoryLabelsScrollView.contentOffset.x / self.categoryLabelsScrollView.bounds.size.width)];
        
        firstLabel = self.actualIncomeCategory;
    }
    else
    {
        [self setCategoryLabels:IncomeCategory active:NO];
        [self setCategoryLabels:ExpenseCategory active:YES];
        
        self.actualIncomeCategory = [self.incomeCategoryLabels objectAtIndex:floor(self.categoryLabelsScrollView.contentOffset.x / self.categoryLabelsScrollView.bounds.size.width)];
        
        firstLabel = self.actualExpenseCategory;
    }
    
    [self updateCategoryScrollViewContentSize];

    [self.categoryLabelsScrollView scrollRectToVisible:firstLabel.frame animated:NO];
}

#pragma mark - ControlEvents

- (void)setBackgroundColorBasedInEditModeCategory
{
    if (self.editModeCategory == IncomeCategory)
        self.view.backgroundColor = [IAEConstants incomeValueColor];
    else
        self.view.backgroundColor = [IAEConstants expenseValueColor];
}

- (void)tintBackgroundInputBasedInCategorySelectorButton:(BOOL)inmediate
{
    if (inmediate) {
        [self setBackgroundColorBasedInEditModeCategory];
    } else {
        [UIView animateWithDuration:0.15 animations:^{
            [self setBackgroundColorBasedInEditModeCategory];
        }];
    }
}

- (BOOL)showInputIfCategorySelectionButtonPressedWhenHide
{
    BOOL hide = [self isInputHide];
    if (hide) {
        [self automaticDrag];
    }
    return hide;
}
- (IBAction)incomesSelectionCategoryButtonPressed:(UIButton *)button
{
    BOOL hideToVisible = [self isInputHide];
    
    if (hideToVisible) {
        [self automaticDrag];
    }
    
    if (self.editModeCategory != IncomeCategory) {
        self.editModeCategory = IncomeCategory;
        [self tintBackgroundInputBasedInCategorySelectorButton:hideToVisible];
        [self showCategoryLabelsBasedInSegmentedControl];
        if (!hideToVisible) {
            [self.delegate inputChangeCategoryModeToIncome];
        }
    } else if (!hideToVisible) {
        [self automaticDrag];
    }
}

- (IBAction)expenseSelectionCategoryButtonPressed:(UIButton *)button
{
    BOOL hideToVisible = [self isInputHide];
    
    if (hideToVisible) {
        [self automaticDrag];
    }
    
    if (self.editModeCategory != ExpenseCategory) {
        self.editModeCategory = ExpenseCategory;
        [self tintBackgroundInputBasedInCategorySelectorButton:hideToVisible];
        [self showCategoryLabelsBasedInSegmentedControl];
        if (!hideToVisible) {
            [self.delegate inputChangeCategoryModeToExpense];
        }
    } else if (!hideToVisible) {
        [self automaticDrag];
    }
}
- (IBAction)clearButtonPressed:(UIButton *)sender
{
    [[IAEAnimationManager sharedManager] destroyViewGosthEffect:self.numericPannel withDuration:0.6 andDisplacement:44.0];
    [self resetAmountPannel];
}

- (IBAction)numberButtonPressed:(UIButton *)button
{
    [[IAEAnimationManager sharedManager] buttonPressedEffect:button];
    
    [self appenValueToPannel:button.titleLabel.text];
}

- (IBAction)numberButtonReleased:(UIButton *)button
{
    [[IAEAnimationManager sharedManager] buttonReleasedEffect:button];
}
- (IBAction)commaButtonPressed:(UIButton *)button
{
    [[IAEAnimationManager sharedManager] buttonPressedEffect:button];

    // Solo si no se ha puesto la coma antes
    // TODO: Cuidado con la localizacion porque en algunos paises el punto se usa como decimal. En españa es la coma pero
    // el sistema solo reconoce el punto para hacer la conversion.
    NSRange decimalRange = [self.actualAmount rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:[[IAECurrencyManager sharedManager] decimalSeparator]]];
    
    if (decimalRange.location == NSNotFound)
        [self appenValueToPannel:[[IAECurrencyManager sharedManager] decimalSeparator]];
}

- (IBAction)commaButtonReleased:(UIButton *)button
{
    [[IAEAnimationManager sharedManager] buttonReleasedEffect:button];
}

- (IBAction)deleteButtonPressed:(UIButton *)button
{
    [[IAEAnimationManager sharedManager] buttonPressedEffect:button];
    
    // Se puede borrar si:
    // - El valor NO es cero.
    // - El valor ES cero PERO el ultimo caracter es el decimal
    NSDecimalNumber *actualNumberAmount = [NSDecimalNumber decimalNumberWithString:self.actualAmount];
    
    BOOL canUseDeleteButton = ![actualNumberAmount isEqualToValue:[NSDecimalNumber zero]];
    if (!canUseDeleteButton)
        canUseDeleteButton = [self.actualAmount rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:[[IAECurrencyManager sharedManager] decimalSeparator]]].location != NSNotFound;
    
    if (canUseDeleteButton)
    {
        [self.actualAmount deleteCharactersInRange:NSMakeRange(self.actualAmount.length - 1, 1)];
        
        [self deployActualAmountToNumericPanel];
    }
}

- (IBAction)deleteButtonRelease:(UIButton *)button
{
    [[IAEAnimationManager sharedManager] buttonReleasedEffect:button];
}

- (IBAction)addNewConceptButtonPressed:(UIButton *)button
{
    //[[IAEAnimationManager sharedManager] buttonPressedEffect:button];
    
    NSMutableArray *container = self.editModeCategory == IncomeCategory ? self.incomeCategoryLabels : self.expenseCategoryLabels;
    
    NSUInteger scrollIndex = floor(self.categoryLabelsScrollView.contentOffset.x / self.categoryLabelsScrollView.bounds.size.width);
    
    if (scrollIndex == container.count - 1) {
        [self addNewCategoryLabelPressed:[container objectAtIndex:scrollIndex]];
    } else if (scrollIndex < container.count - 1){
        [self categoryLabelPressed:[container objectAtIndex:scrollIndex]];
    }
}

- (IBAction)addNewConceptButtonRelease:(UIButton *)button
{
   // [[IAEAnimationManager sharedManager] buttonReleasedEffect:button];
}

- (void)categoryLabelPressed:(UILabel *)label
{
    [[IAEAnimationManager sharedManager] keyPressEffectForAnimation:label withDuration:0.35];

    IAECategory *category = [[IAECategoryStore sharedCategoryStore] findCategoryByTag:label.text];
    
    NSDecimalNumber *actualAmount = [NSDecimalNumber decimalNumberWithString:self.actualAmount locale:[NSLocale currentLocale]];
    
    if ([actualAmount compare:[NSDecimalNumber zero]] != NSOrderedSame)
    {
        [[self.dataSource actualSelectedMonth] addConceptWithAmount:actualAmount
                                                        category:category
                                                            date:[[NSDate date] timeIntervalSince1970]
                                                    andDescription:@""];
        
        [[IAEAnimationManager sharedManager] destroyViewGosthEffect:self.numericPannel withDuration:0.6 andDisplacement:-44.0];

        [self resetAmountPannel];
    }
}

- (void)addNewCategoryLabelPressed:(UILabel *)categoryLabel
{
    self.addNewCategoryFromInputController = YES;
    
    IAECategoriesConfigAddViewController *categoriesConfigAddViewController = [[IAECategoriesConfigAddViewController alloc] initWithCategoryType:self.editModeCategory andRenamingCategory:nil fromInputPanel:YES];

    IAEConfigNavigationControllerViewController *navController = [[IAEConfigNavigationControllerViewController alloc] initWithRootViewController:categoriesConfigAddViewController];

    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        UITextField *textField = [self.categoryAlertViewNameInput textFieldAtIndex:0];
        ValidTagCheckResult finishOk = [IAECategory isAValidTag:textField.text];
        
        if (finishOk == ValidTag) {
            // TODO: Metodo qe permita crear categoria sin que dentro vuelva a realizar llamada isAValidTag
            [[IAECategoryStore sharedCategoryStore] createCategoryOfType:self.editModeCategory andTag:textField.text withValidityTagCheck:NO];
        }
    }
}

#pragma mark - UIScrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateAddCategoryCheckButtonVisibility];
}

#pragma mark - NotificationCenter

- (void)categoryCreatedNotification:(NSNotification *)notification
{
    // Hallamos la seccion donde estamos antes de proceder a alterar contenedores
    // Creamos el boton asociado a la categoria
    // Lo metemos dentro del scrollview
    // Intercambiamos luego:
    // - Posicion y frame con el ultimo boton, pues es el de añadir nuevas categorias
    // Aumentamos ContentSize
    
    NSMutableArray *actualCategorySectionContainer = self.editModeCategory == IncomeCategory ? self.incomeCategoryLabels : self.expenseCategoryLabels;
    NSUInteger scrollIndex = floor(self.categoryLabelsScrollView.contentOffset.x / self.categoryLabelsScrollView.bounds.size.width);
    BOOL wasInAddNewCategory = scrollIndex == actualCategorySectionContainer.count - 1;
    UILabel *actualCategoryLabelSelected = [actualCategorySectionContainer objectAtIndex:scrollIndex];
    
    NSDictionary *userInfo = [notification userInfo];
    
    IAECategory *category = [userInfo objectForKey:@"Category"];
    
    [self createCategoryLabelOfType:category.categoryType andTag:[category localizedTag]];
    
    NSMutableArray *container = category.categoryType == IncomeCategory ? self.incomeCategoryLabels : self.expenseCategoryLabels;
    
    NSUInteger addNewCategoryButtonIndex = container.count-2;
    NSUInteger newCategoryButtonIndex = container.count-1;
    
    UILabel *addNewCategory = [container objectAtIndex:addNewCategoryButtonIndex];
    UILabel *newCategory = [container objectAtIndex:newCategoryButtonIndex];
    
    CGRect tmpFrame = addNewCategory.frame;
    addNewCategory.frame = newCategory.frame;
    newCategory.frame = tmpFrame;
    
    [container exchangeObjectAtIndex:addNewCategoryButtonIndex withObjectAtIndex:newCategoryButtonIndex];
    [self sortCategoryLabels:category.categoryType];
    
    [self updateCategoryScrollViewContentSize];
    [self.categoryLabelsScrollView addSubview:newCategory];
    
    newCategory.hidden = self.editModeCategory == category.categoryType ? NO : YES;
    
    CGRect rectToScroll;
    if (wasInAddNewCategory) {
        NSUInteger indexToTravel = self.addNewCategoryFromInputController ? [container indexOfObject:newCategory] : container.count - 1;
        rectToScroll = CGRectMake(self.categoryLabelsScrollView.bounds.size.width * indexToTravel, 0.0, self.categoryLabelsScrollView.bounds.size.width, self.categoryLabelsScrollView.bounds.size.height);
        
        self.addNewCategoryFromInputController = NO;
    } else {
        NSUInteger newIndexForActualCategoryLabelSelected = [container indexOfObject:actualCategoryLabelSelected];
        rectToScroll = CGRectMake(self.categoryLabelsScrollView.bounds.size.width * newIndexForActualCategoryLabelSelected, 0.0, self.categoryLabelsScrollView.bounds.size.width, self.categoryLabelsScrollView.bounds.size.height);
    }
    [self.categoryLabelsScrollView scrollRectToVisible:rectToScroll animated:NO];
}

- (void)categoryRemoveNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    NSString *categoryTag = [userInfo objectForKey:@"CategoryTag"];
    NSNumber *categoryType = [userInfo objectForKey:@"CategoryType"];
    
    NSMutableArray *controlContainer = categoryType.intValue == IncomeCategory ? self.incomeCategoryLabels : self.expenseCategoryLabels;
    
    NSUInteger labelCategoryIndex = [controlContainer indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        UILabel *categorylabel = obj;
        *stop = [categorylabel.text compare:categoryTag] == NSOrderedSame;
        return *stop;
    }];
    
    UILabel *label = [controlContainer objectAtIndex:labelCategoryIndex];
    
    [label removeFromSuperview];
    [controlContainer removeObject:label];
    
    [self recalculeLabelFramesOfType:categoryType.intValue];
    
    [self updateCategoryScrollViewContentSize];
}

- (void)categoryRenamedNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    NSString *oldTag = [userInfo objectForKey:@"OldTag"];
    IAECategory *category = [userInfo objectForKey:@"Category"];
    
    NSMutableArray *controlContainer = category.categoryType == IncomeCategory ? self.incomeCategoryLabels : self.expenseCategoryLabels;
    
    for (UILabel *categoryLabel in controlContainer) {
        if ([categoryLabel.text isEqualToString:oldTag]) {
            categoryLabel.text = [category localizedTag];
            break;
        }
    }
    
    [self sortCategoryLabels:category.categoryType];
}

@end
