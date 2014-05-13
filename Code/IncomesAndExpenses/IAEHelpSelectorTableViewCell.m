//
//  IAEHelpSelectorTableViewCell.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 13/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEHelpSelectorTableViewCell.h"
#import "IAEHelpThemeDefs.h"

#pragma mark - Constants

static const NSUInteger kAllVersionSegmentedControlSection = 0;
static const NSUInteger kProVersionSegmentedControlSection = 1;

#pragma mark - Interface

@interface IAEHelpSelectorTableViewCell()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end

#pragma mark - Implementation

@implementation IAEHelpSelectorTableViewCell

- (void)awakeFromNib
{
    [self configureSegmentedControl];
}

- (void)configureSegmentedControl
{
    self.segmentedControl.selectedSegmentIndex = kAllVersionSegmentedControlSection;
    [self.segmentedControl setTitle:NSLocalizedString(@"LTEXT_HELPSELECTOR_ALLVERSIONS", @"") forSegmentAtIndex:kAllVersionSegmentedControlSection];
    [self.segmentedControl setTitle:NSLocalizedString(@"LTEXT_HELPSELECTOR_PROVERSION", @"") forSegmentAtIndex:kProVersionSegmentedControlSection];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - Segmented Control

- (IBAction)onSegmentedControlPressed:(id)sender
{
    [self.delegate helpSelectorTableViewCell:self didChangeSelectorIndexToHelpThemeType:[self convertSegmentedControlSectionToHelpThemeType]];
}

- (IAEHelpThemeType)convertSegmentedControlSectionToHelpThemeType
{
    return self.segmentedControl.selectedSegmentIndex == kAllVersionSegmentedControlSection ? HelpThemeAllVersion :HelpThemeProVersion;
}

@end
