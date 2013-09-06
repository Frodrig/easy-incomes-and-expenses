//
//  IAESettingsAboutAndOptionsCollectionViewCell.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 17/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAESettingsAboutAndOptionsCollectionViewCell.h"
#import "IAENibUtils.h"

@interface IAESettingsAboutAndOptionsCollectionViewCell()

@property (weak, nonatomic) IBOutlet UILabel *dayModeInformationLabel;
@property (weak, nonatomic) IBOutlet UISwitch *dayModeSwitch;

@end

@implementation IAESettingsAboutAndOptionsCollectionViewCell

static NSString * const kUserDefaultsDayModeActive = @"dayModeActive";

static NSString * const kFamilyFontForInformationLabelsName = @"HelveticaNeue-UltraLight";
static const NSUInteger kFamilyFontForInformationLabelSize = 24;
static const CGFloat kKernValueForInformationLabels = 1.0;

static NSString * const kTagDayModeLabelText = @"LTEXT_ABOUTANDOPTIONS_DAYMODELABEL_TEXT";

static NSString * const kNotificationDayModeOnName = @"dayModeToOn";
static NSString * const kNotificationDayModeOffName = @"dayModeToOff";

static NSString * const kNibName = @"IAESettingsAboutAndOptionsCollectionViewCell";

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
    _dayModeInformationLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(kTagDayModeLabelText, @"")
                                                                              attributes:[self createAttributesForInformationLabels]];
}

- (NSDictionary *)createAttributesForInformationLabels
{
    NSDictionary *attributes = @{NSFontAttributeName: [self createFontForInformationLabels],
                                 NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSKernAttributeName: [NSNumber numberWithInteger: kKernValueForInformationLabels]};
    
    return attributes;
}

- (UIFont *)createFontForInformationLabels
{
    UIFont *font = [UIFont fontWithName:kFamilyFontForInformationLabelsName size:kFamilyFontForInformationLabelSize];
    return font;
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
    [self notifyDayModeChanged];
}

- (void)notifyDayModeChanged
{
    // ToDo: Seria mas eficiente que llegara la notificacion solo cuando se va a cerrar el dialogo para evitar cambios continuados

    NSString *notificationName = self.dayModeSwitch.on ? kNotificationDayModeOnName : kNotificationDayModeOffName;
    NSNotification *notification = [NSNotification notificationWithName:notificationName object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

#pragma mark - Acciones directas

- (void)setDaySwitchValueOn:(BOOL)on
{
    self.dayModeSwitch.on = on;
}

@end
