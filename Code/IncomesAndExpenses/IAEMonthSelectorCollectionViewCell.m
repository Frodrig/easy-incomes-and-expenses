//
//  IAEMonthSelectorCollectionViewCell.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 12/04/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEMonthSelectorCollectionViewCell.h"
#import "IAEDateHelper.h"

@interface IAEMonthSelectorCollectionViewCell()

@property (weak, nonatomic) IBOutlet UILabel *monthLabel;

@end

@implementation IAEMonthSelectorCollectionViewCell

#pragma mark - Properties

- (void)setMonth:(MonthType)month
{
    _month = month;
    [self configureCellBasedInMonthValue];
}

- (void)setDisabledAspect:(BOOL)disabledAspect
{
    _disabledAspect = disabledAspect;
    _monthLabel.enabled = !disabledAspect;
}

#pragma mark - Init

- (void)awakeFromNib
{
    [self configureCellGeneralAspect];
    self.month = InvalidMonth;
    self.disabledAspect = NO;
}

#pragma mark - Month

- (void)configureCellGeneralAspect
{
    // ...
    
}

- (void)configureCellBasedInMonthValue
{
    self.monthLabel.text = [self findMonthNameString];
}

- (NSString *)findMonthNameString
{
    NSString *monthNameString = self.month == InvalidMonth ? @"" : [IAEDateHelper findMonthNameStringWithMonthIndex:self.month inShortForm:YES];
    return monthNameString;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
