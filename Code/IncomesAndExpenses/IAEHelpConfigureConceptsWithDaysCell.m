//
//  IAESettingsAboutAndOptionsCollectionViewCell.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 17/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEHelpConfigureConceptsWithDaysCell.h"
#import "IAENibUtils.h"
#import "NSUserDefaults+EasyIncAndExp.h"

@interface IAEHelpConfigureConceptsWithDaysCell()

@property (weak, nonatomic) IBOutlet UILabel *dayModeInformationLabel;
@property (weak, nonatomic) IBOutlet UISwitch *dayModeSwitch;

@end

@implementation IAEHelpConfigureConceptsWithDaysCell

static NSString * const kTagDayModeLabelText = @"LTEXT_ABOUTANDOPTIONS_DAYMODELABEL_TEXT";
static NSString * const kNibName = @"IAEHelpConfigureConceptsWithDaysCell";

#pragma mark - Class

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
    [super awakeFromNib];

    [self initDayModeSetting];
}

- (void)initDayModeSetting
{
    [self initDayModeInformationLabel];
    [self initDayModeInformationSwitch];
}

- (void)initDayModeInformationLabel
{
    _dayModeInformationLabel.text = NSLocalizedString(kTagDayModeLabelText, @"");
}

- (void)initDayModeInformationSwitch
{
    _dayModeSwitch.on = [[NSUserDefaults standardUserDefaults] isDayModeActiveForConcepts];
}

#pragma mark - Control Events

- (IBAction)daySwitchValueChanged:(id)sender
{
    [[NSUserDefaults standardUserDefaults] changeDayModeActiveForConcepts];
}

#pragma mark - Acciones directas

- (void)setDaySwitchValueOn:(BOOL)on
{
    self.dayModeSwitch.on = on;
}

@end
