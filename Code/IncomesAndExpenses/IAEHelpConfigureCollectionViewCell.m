//
//  IAESettingsAboutAndOptionsCollectionViewCell.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 17/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEHelpConfigureCollectionViewCell.h"
#import <Crashlytics/Crashlytics.h>
#import "Flurry.h"
#import "IAENibUtils.h"

@interface IAEHelpConfigureCollectionViewCell()

@property (weak, nonatomic) IBOutlet UILabel *dayModeInformationLabel;
@property (weak, nonatomic) IBOutlet UISwitch *dayModeSwitch;

@end

@implementation IAEHelpConfigureCollectionViewCell

static NSString * const kUserDefaultsDayModeActive = @"dayModeActive";

static NSString * const kTagDayModeLabelText = @"LTEXT_ABOUTANDOPTIONS_DAYMODELABEL_TEXT";

static NSString * const kNibName = @"IAEHelpConfigureCollectionViewCell";

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
    _dayModeSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsDayModeActive];
}

#pragma mark - Control Events

- (IBAction)daySwitchValueChanged:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:self.dayModeSwitch.on forKey:kUserDefaultsDayModeActive];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [Crashlytics setObjectValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"dayModeActive"] forKey:@"Days Mode"];
    [Flurry logEvent:@"daymode_activation" withParameters:@{@"DayMode" : [NSNumber numberWithBool:self.dayModeSwitch.on]}];
}

#pragma mark - Acciones directas

- (void)setDaySwitchValueOn:(BOOL)on
{
    self.dayModeSwitch.on = on;
}

@end
