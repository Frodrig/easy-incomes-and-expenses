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

@property (weak, nonatomic) IBOutlet UIButton *monthButton;

@end

@implementation IAEMonthSelectorCollectionViewCell

#pragma mark - Properties

- (void)setMonth:(MonthType)month
{
    _month = month;
    [self configureCellBasedInMonthValue];
}

#pragma mark - Init

- (void)awakeFromNib
{
    [self configureCellGeneralAspect];
    self.month = InvalidMonth;
}

#pragma mark - Month

- (void)configureCellGeneralAspect
{
    // ...
    
}

- (void)configureCellBasedInMonthValue
{
    [self.monthButton setTitle:[self findMonthNameString] forState:UIControlStateNormal];
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
