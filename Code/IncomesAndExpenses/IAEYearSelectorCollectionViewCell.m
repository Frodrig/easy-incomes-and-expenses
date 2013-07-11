//
//  IAEYearSelectorCollectionViewCell.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 11/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEYearSelectorCollectionViewCell.h"
#import "IAEValueDecoratorView.h"
#import "IAEEconomicValueTypeHelper.h"
#import "UIView+RoundedCorners.h"
#import "IAECurrencyManager.h"


@interface IAEYearSelectorCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIView *cellContainerView;

@property (weak, nonatomic) IBOutlet IAEValueDecoratorView *economicDecoratorView;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;

@end

@implementation IAEYearSelectorCollectionViewCell

static NSString * const fontFamilyForYearDateLabel = @"HelveticaNeue-UltraLight";
static NSString * const fontFamilyForBalanceLabel = @"HelveticaNeue-Italic";
static NSUInteger fontFamilySizeForYearDateLabel = 55;
static NSUInteger fontFamilySizeForBalanceLabel = 21;

static NSUInteger containerViewRoundRectSize = 10;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
/*- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)configureContainerViewRoundRects
{
    [self addRoundedCorners:UIRectCornerAllCorners withRadius:containerViewRoundRectSize];
}

#pragma mark - Public Methods

- (void)configureWithYearDate:(NSUInteger)yearDate andBalance:(NSDecimalNumber *)balance
{
    NSAssert(yearDate > 0, @"");
    
    [self configureContainerViewRoundRects];

    [self showControlsAssociatedWithConcepts:YES];
    self.yearLabel.attributedText = [[NSAttributedString alloc] initWithString:[self yearStringFromYearDate:yearDate]
                                                                    attributes:[self createAttributeDictionaryForYearLabelWithColor:[UIColor blackColor]]];
    self.economicDecoratorView.economicValueType = [IAEEconomicValueTypeHelper economicValueTypeFromEconomicValue:balance];
    NSString *balanceString = [[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:balance];
    self.balanceLabel.attributedText = [[NSAttributedString alloc] initWithString:balanceString
                                                                       attributes:[self createAttributeDictionaryForBalanceYearLabel]];
}

- (void)configureWithYearDate:(NSUInteger)yearDate
{
    NSAssert(yearDate > 0, @"");
    
    [self configureContainerViewRoundRects];

    [self showControlsAssociatedWithConcepts:NO];
    self.yearLabel.attributedText = [[NSAttributedString alloc] initWithString:[self yearStringFromYearDate:yearDate]
                                                                    attributes:[self createAttributeDictionaryForYearLabelWithColor:[UIColor colorWithWhite:0.85 alpha:1.0]]];
}

- (void)showControlsAssociatedWithConcepts:(BOOL)show
{
    BOOL hide = !show;
    
    self.economicDecoratorView.hidden = hide;
    self.balanceLabel.hidden = hide;
}

- (NSString *)yearStringFromYearDate:(NSUInteger)yearDate
{
    NSString *yearString = [NSString stringWithFormat:@"%d", yearDate];
    
    return yearString;
}

- (NSDictionary *)createAttributeDictionaryForYearLabelWithColor:(UIColor *)color
{
    NSDictionary *attributes =  @{NSFontAttributeName: [UIFont fontWithName:fontFamilyForYearDateLabel size:fontFamilySizeForYearDateLabel],
                                  NSForegroundColorAttributeName: color,
                                  NSKernAttributeName: [NSNumber numberWithInteger:20.0]};

    return attributes;
}

- (NSDictionary *)createAttributeDictionaryForBalanceYearLabel
{
    NSDictionary *attributes =  @{NSFontAttributeName: [UIFont fontWithName:fontFamilyForBalanceLabel size:fontFamilySizeForBalanceLabel],
                                  NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                  NSKernAttributeName: [NSNumber numberWithInteger:1.0]};
    
    return attributes;    
}

@end
