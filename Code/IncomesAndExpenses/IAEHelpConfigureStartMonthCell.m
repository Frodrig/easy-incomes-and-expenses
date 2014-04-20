//
//  IAEHelpConfigureStartMonthCell.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 29/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEHelpConfigureStartMonthCell.h"
#import "IAENibUtils.h"
#import "NSUserDefaults+EasyIncAndExp.h"
#import "MonthDefs.h"
#import "IAEDateHelper.h"

@interface IAEHelpConfigureStartMonthCell()

@property (weak, nonatomic) IBOutlet UILabel *informationLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthValueLabel;

@end

@implementation IAEHelpConfigureStartMonthCell

#pragma mark - Constants

static NSString * const kNibName = @"IAEHelpConfigureStartMonthCell";
static NSString * const kUserDefaultInitialMonth = @"initialMonth";
static NSString * const kLTextStartLabelBaseText = @"LTEXT_ABOUTANDOPTIONS_STARTMONTHBUTTON_TEXT";

#pragma mark - Static

+ (CGSize)sizeOfItem
{
    static CGSize size;
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        size = [IAENibUtils findSizeOfTheBaseViewOfNibNamed:kNibName];
    }
    
    return size;
}

#pragma mark - Init

- (void)awakeFromNib
{
    [self initStartMonthSettings];
}

- (void)initStartMonthSettings
{
    self.informationLabel.text = NSLocalizedString(kLTextStartLabelBaseText, @"");
    self.monthValueLabel.text = [IAEDateHelper findMonthNameStringWithMonthIndex:[[[NSUserDefaults standardUserDefaults] valueForKey:kUserDefaultInitialMonth] integerValue] inShortForm:NO];
}

@end
