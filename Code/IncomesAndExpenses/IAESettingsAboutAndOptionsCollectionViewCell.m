//
//  IAESettingsAboutAndOptionsCollectionViewCell.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 17/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAESettingsAboutAndOptionsCollectionViewCell.h"

@interface IAESettingsAboutAndOptionsCollectionViewCell()
@property (weak, nonatomic) IBOutlet UILabel *dayModeInformationLabel;
@property (weak, nonatomic) IBOutlet UISwitch *dayModeSwitch;

@end

@implementation IAESettingsAboutAndOptionsCollectionViewCell

static NSString * const userDefaultsDayModeActive = @"dayModeActive";

static NSString * const familyFontForInformationLabelsName = @"HelveticaNeue-UltraLight";
static NSUInteger familyFontForInformationLabelSize = 24;
static CGFloat kernValueForInformationLabels = 1.0;

static NSString * const tagDayModeLabelText = @"LTEXT_ABOUTANDOPTIONS_DAYMODELABEL_TEXT";

static NSString * const notificationDayModeOnName = @"dayModeToOn";
static NSString * const notificationDayModeOffName = @"dayModeToOff";

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
    _dayModeInformationLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(tagDayModeLabelText, @"")
                                                                              attributes:[self createAttributesForInformationLabels]];
}

- (NSDictionary *)createAttributesForInformationLabels
{
    NSDictionary *attributes = @{NSFontAttributeName: [self createFontForInformationLabels],
                                 NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSKernAttributeName: [NSNumber numberWithInteger: kernValueForInformationLabels]};
    
    return attributes;
}

- (UIFont *)createFontForInformationLabels
{
    UIFont *font = [UIFont fontWithName:familyFontForInformationLabelsName size:familyFontForInformationLabelSize];
    return font;
}

- (void)initDayModeInformationSwitch
{
    _dayModeSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:userDefaultsDayModeActive];
}

#pragma mark - Control Events

- (IBAction)daySwitchValueChanged:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:self.dayModeSwitch.on forKey:userDefaultsDayModeActive];
    [self notifyDayModeChanged];
}

- (void)notifyDayModeChanged
{
    NSString *notificationName = self.dayModeSwitch.on ? notificationDayModeOnName : notificationDayModeOffName;
    NSNotification *notification = [NSNotification notificationWithName:notificationName object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

#pragma mark - Acciones directas

- (void)setDaySwitchValueOn:(BOOL)on
{
    self.dayModeSwitch.on = on;
}

@end
